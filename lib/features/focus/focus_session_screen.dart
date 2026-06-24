import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/duration_format.dart';
import '../../data/models/focus_session.dart';
import '../../data/repositories/session_repository.dart';
import '../complete/last_session_provider.dart';
import '../journey/journey_selection_provider.dart';
import 'focus_timer_provider.dart';
import 'journey_map.dart';
import 'map_style_provider.dart';
import 'real_journey_map.dart';

class FocusSessionScreen extends ConsumerStatefulWidget {
  const FocusSessionScreen({super.key});

  @override
  ConsumerState<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends ConsumerState<FocusSessionScreen>
    with WidgetsBindingObserver {
  bool _handledFinish = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(focusTimerProvider.notifier).syncNow();
    }
  }

  Future<void> _onFinished() async {
    if (_handledFinish) return;
    _handledFinish = true;
    final timer = ref.read(focusTimerProvider);
    final sel = ref.read(journeySelectionProvider);
    if (timer == null || !sel.isComplete) return;
    final session = FocusSession(
      id: '${timer.startedAt.microsecondsSinceEpoch}',
      originName: sel.origin!.name,
      destName: sel.destination!.name,
      transportIndex: sel.transport!.index,
      plannedSeconds: timer.planned.inSeconds,
      focusedSeconds: timer.planned.inSeconds,
      startedAt: timer.startedAt,
      completed: true,
    );
    await ref.read(sessionRepositoryProvider).save(session);
    ref.read(lastCompletedSessionProvider.notifier).state = session;
    ref.read(focusTimerProvider.notifier).cancel();
    if (mounted) context.go('/complete');
  }

  Future<void> _onAbort() async {
    final timer = ref.read(focusTimerProvider);
    if (timer == null) {
      if (mounted) context.go('/');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('여정을 중단할까요?'),
        content: const Text('지금 내리면 이번 집중은 완료로 기록되지 않아요.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('계속 집중')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('중단')),
        ],
      ),
    );
    if (confirmed != true) return;
    final sel = ref.read(journeySelectionProvider);
    if (sel.isComplete) {
      await ref.read(sessionRepositoryProvider).save(FocusSession(
            id: '${timer.startedAt.microsecondsSinceEpoch}',
            originName: sel.origin!.name,
            destName: sel.destination!.name,
            transportIndex: sel.transport!.index,
            plannedSeconds: timer.planned.inSeconds,
            focusedSeconds: timer.elapsedAt(DateTime.now()).inSeconds,
            startedAt: timer.startedAt,
            completed: false,
          ));
    }
    ref.read(focusTimerProvider.notifier).cancel();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(focusTimerProvider, (prev, next) {
      if (next != null && next.finished) _onFinished();
    });

    final timer = ref.watch(focusTimerProvider);
    final sel = ref.watch(journeySelectionProvider);
    if (timer == null || !sel.isComplete) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('진행 중인 여정이 없습니다')),
      );
    }

    final now = DateTime.now();
    final remaining = timer.remainingAt(now);
    final progress = timer.progressAt(now);
    final useRealMap = ref.watch(useRealMapProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _onAbort();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => ref
                        .read(useRealMapProvider.notifier)
                        .update((v) => !v),
                    icon: Icon(
                        useRealMap
                            ? Icons.terrain_rounded
                            : Icons.map_outlined,
                        size: 18),
                    label: Text(useRealMap ? '실제 지도' : '감성 지도'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(sel.origin!.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _stationStyle),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 18, color: AppColors.textTertiary),
                    ),
                    Flexible(
                      child: Text(sel.destination!.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _stationStyle),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: useRealMap
                      ? RealJourneyMap(
                          progress: progress,
                          transport: sel.transport!,
                          origin: sel.origin!,
                          destination: sel.destination!,
                        )
                      : JourneyMap(
                          progress: progress,
                          transport: sel.transport!,
                          originName: sel.origin!.name,
                          destName: sel.destination!.name,
                        ),
                ),
                const SizedBox(height: 24),
                const Text('남은 집중 시간',
                    style:
                        TextStyle(fontSize: 13, color: AppColors.textTertiary)),
                const SizedBox(height: 8),
                Text(
                  formatClock(remaining.inSeconds),
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: AppColors.line,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 42,
                      child: Text('${(progress * 100).round()}%',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _onAbort,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(color: AppColors.line),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('그만두기'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          final n = ref.read(focusTimerProvider.notifier);
                          timer.isPaused ? n.resume() : n.pause();
                        },
                        child: Text(timer.isPaused ? '계속하기' : '잠시 정차'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _stationStyle = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
