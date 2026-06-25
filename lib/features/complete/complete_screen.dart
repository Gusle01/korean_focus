import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/duration_format.dart';
import '../../data/models/collectible_category.dart';
import '../../data/models/owned_collectible.dart';
import '../../data/repositories/session_repository.dart';
import '../journey/journey_selection_provider.dart';
import 'last_session_provider.dart';

class CompleteScreen extends ConsumerStatefulWidget {
  const CompleteScreen({super.key});

  @override
  ConsumerState<CompleteScreen> createState() => _CompleteScreenState();
}

class _CompleteScreenState extends ConsumerState<CompleteScreen> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  void _goHome() {
    ref.read(journeySelectionProvider.notifier).reset();
    context.go('/');
  }

  void _newJourney() {
    ref.read(journeySelectionProvider.notifier).reset();
    context.go('/transport');
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(lastCompletedSessionProvider);
    final awarded = ref.watch(lastAwardedCollectibleProvider);
    if (session == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('완료된 여정이 없습니다'),
                const SizedBox(height: 16),
                FilledButton(onPressed: _goHome, child: const Text('홈으로')),
              ],
            ),
          ),
        ),
      );
    }
    final todaySeconds = ref.read(sessionRepositoryProvider).todaySeconds();
    final stampLabel = awarded?.city ?? session.destName;
    final stampDate = DateFormat('yyyy.MM.dd').format(session.startedAt);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goHome();
      },
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Spacer(),
                    _ArrivalStamp(label: stampLabel, date: stampDate)
                        .animate()
                        .fadeIn(duration: 200.ms, delay: 300.ms)
                        .scale(
                          begin: const Offset(1.8, 1.8),
                          end: const Offset(1, 1),
                          duration: 500.ms,
                          delay: 300.ms,
                          curve: Curves.easeOutBack,
                        ),
                    const SizedBox(height: 28),
                    Text('${session.destName}에 도착했습니다',
                            textAlign: TextAlign.center,
                            style: AppText.display(size: 24))
                        .animate()
                        .fadeIn(delay: 650.ms, duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, delay: 650.ms),
                    const SizedBox(height: 8),
                    const Text('집중 여정 완료',
                            style: TextStyle(
                                fontSize: 15, color: AppColors.textSecondary))
                        .animate()
                        .fadeIn(delay: 780.ms, duration: 400.ms),
                    if (awarded != null) ...[
                      const SizedBox(height: 28),
                      _AwardCard(item: awarded)
                          .animate()
                          .fadeIn(delay: 950.ms, duration: 450.ms)
                          .slideY(begin: 0.25, end: 0, delay: 950.ms)
                          .scale(
                            begin: const Offset(0.94, 0.94),
                            end: const Offset(1, 1),
                            delay: 950.ms,
                            curve: Curves.easeOut,
                          ),
                    ],
                    const SizedBox(height: 36),
                    Row(
                      children: [
                        Expanded(
                            child: _Stat(
                                label: '이번 집중',
                                value:
                                    formatDurationKo(session.focusedSeconds))),
                        Expanded(
                            child: _Stat(
                                label: '오늘 누적',
                                value: formatDurationKo(todaySeconds))),
                      ],
                    ).animate().fadeIn(delay: 1150.ms, duration: 450.ms),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _goHome,
                        child: const Text('홈으로',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => context.push('/collection'),
                            icon: const Icon(Icons.inventory_2_outlined,
                                size: 18),
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.textSecondary),
                            label: const Text('진열장'),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: _newJourney,
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.textSecondary),
                            child: const Text('새 여정 시작'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 12,
                maxBlastForce: 12,
                minBlastForce: 6,
                gravity: 0.3,
                emissionFrequency: 0.05,
                colors: const [
                  AppColors.primary,
                  AppColors.primaryDark,
                  Color(0xFFEFC07A),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 도착 보상으로 획득한 컬렉션을 보여주는 카드.
class _AwardCard extends StatelessWidget {
  const _AwardCard({required this.item});
  final OwnedCollectible item;

  @override
  Widget build(BuildContext context) {
    final category = CollectibleCategory.values[item.categoryIndex];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.line),
            ),
            child: Text(item.emoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.city} ${category.label} 획득!',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(item.name,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                const Text('진열장에 보관되었어요',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppText.label(size: 12)),
        const SizedBox(height: 6),
        Text(value, style: AppText.number(size: 20)),
      ],
    );
  }
}

/// 도착 도장(印) — 단청빛 원형 스탬프.
class _ArrivalStamp extends StatelessWidget {
  const _ArrivalStamp({required this.label, required this.date});
  final String label;
  final String date;

  @override
  Widget build(BuildContext context) {
    const ink = AppColors.danchung;
    return Transform.rotate(
      angle: -0.16,
      child: Container(
        width: 118,
        height: 118,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ink.withValues(alpha: 0.85), width: 2.5),
        ),
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ink.withValues(alpha: 0.5), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('도착', style: AppText.label(size: 10, color: ink)),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(label,
                      maxLines: 1,
                      style: AppText.display(size: 26, color: ink)),
                ),
              ),
              const SizedBox(height: 3),
              Text(date,
                  style:
                      AppText.number(size: 10, color: ink, letterSpacing: 0)),
            ],
          ),
        ),
      ),
    );
  }
}
