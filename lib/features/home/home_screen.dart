import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/ui/pressable.dart';
import '../../core/ui/ticket_card.dart';
import '../../core/utils/duration_format.dart';
import '../../data/models/focus_session.dart';
import '../../data/models/transport_type.dart';
import '../../data/repositories/collection_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../journey/journey_selection_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(sessionRepositoryProvider);
    final todaySeconds = repo.todaySeconds();
    final streak = repo.streak();
    final recent = repo.recent();
    final collectionCount = ref.watch(collectionRepositoryProvider).count;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          children: [
            Text('오늘도 좋은 여정 되세요', style: AppText.display(size: 20))
                .animate()
                .fadeIn(duration: 420.ms)
                .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
            const SizedBox(height: 16),
            _TodayCard(
              seconds: todaySeconds,
              streak: streak,
              onTap: () => context.push('/stats'),
            )
                .animate(delay: 80.ms)
                .fadeIn(duration: 420.ms)
                .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
            const SizedBox(height: 24),
            _StartButton(onTap: () {
              ref.read(journeySelectionProvider.notifier).reset();
              context.push('/transport');
            })
                .animate(delay: 160.ms)
                .fadeIn(duration: 420.ms)
                .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
            const SizedBox(height: 12),
            _CollectionTile(
              count: collectionCount,
              onTap: () => context.push('/collection'),
            )
                .animate(delay: 240.ms)
                .fadeIn(duration: 420.ms)
                .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
            const SizedBox(height: 32),
            Text('최근 여정', style: AppText.display(size: 16))
                .animate(delay: 320.ms)
                .fadeIn(duration: 420.ms)
                .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
            const SizedBox(height: 12),
            if (recent.isEmpty)
              const _EmptyRecent()
                  .animate(delay: 380.ms)
                  .fadeIn(duration: 420.ms)
            else
              ...recent.indexed.map((e) => _RecentTile(session: e.$2)
                  .animate(delay: (380 + e.$1 * 70).ms)
                  .fadeIn(duration: 420.ms)
                  .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic)),
          ],
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard(
      {required this.seconds, required this.streak, required this.onTap});
  final int seconds;
  final int streak;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('오늘 집중 시간', style: AppText.label(size: 12)),
                  const Spacer(),
                  if (streak > 0) _StreakBadge(days: streak),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    formatDurationKo(seconds),
                    style: AppText.number(size: 34),
                  ),
                  const Spacer(),
                  Text('통계 보기',
                      style: AppText.label(
                          size: 11, color: AppColors.textTertiary)),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textTertiary, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.danchung.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.danchung.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text('$days일 연속',
              style: AppText.number(
                  size: 13,
                  color: AppColors.danchung,
                  weight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const cream = Color(0xFFFFF7E9);
    return Pressable(
      onTap: onTap,
      child: TicketCard(
        color: AppColors.primary,
        borderColor: const Color(0x55FFF7E9),
        notchColor: AppColors.background,
        radius: 18,
        padding: const EdgeInsets.all(18),
        header: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('승차권 · BOARDING',
                      style: AppText.label(
                          size: 10, color: const Color(0xCCFFF7E9))),
                  const SizedBox(height: 6),
                  Text('새 여정 시작',
                      style: AppText.display(size: 19, color: cream)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: cream),
          ],
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('목적지를 정하고 떠나요',
                style: TextStyle(fontSize: 12, color: Color(0xCCFFF7E9))),
            Text('KF·01',
                style: AppText.label(size: 10, color: const Color(0x99FFF7E9))),
          ],
        ),
      ),
    );
  }
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              const Icon(Icons.inventory_2_outlined,
                  color: AppColors.primaryDark, size: 22),
              const SizedBox(width: 12),
              const Text('진열장',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
              const Spacer(),
              Text(count > 0 ? '$count개 수집' : '비어 있음',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: const Text('아직 완료한 여정이 없어요',
          style: TextStyle(color: AppColors.textTertiary)),
    );
  }
}

class _RecentTile extends StatelessWidget {
  const _RecentTile({required this.session});
  final FocusSession session;

  @override
  Widget build(BuildContext context) {
    final type = TransportType.values[session.transportIndex];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Text(type.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session.originName} → ${session.destName}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  formatDurationKo(session.focusedSeconds),
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
                if (session.note?.trim().isNotEmpty ?? false) ...[
                  const SizedBox(height: 5),
                  Text(
                    '“${session.note!.trim()}”',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.3,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textTertiary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
