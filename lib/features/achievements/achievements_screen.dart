import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/repositories/collection_repository.dart';
import '../../data/repositories/session_repository.dart';
import 'achievement.dart';

/// 칭호·업적: 완주·지역·시간대·교통수단·스트릭·수집에서 도출한 배지.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionRepositoryProvider).all();
    final collectibles = ref.watch(collectionRepositoryProvider).distinctCount;
    final stat = AchievementStat.from(sessions, collectibles, DateTime.now());
    final items = evaluateAchievements(stat);
    final unlocked = items.where((e) => e.unlocked).length;

    return Scaffold(
      appBar: AppBar(
          title: const Text('칭호'), backgroundColor: AppColors.background),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            _Header(unlocked: unlocked, total: items.length)
                .animate()
                .fadeIn(duration: 420.ms)
                .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.82,
              children: [
                for (final (i, e) in items.indexed)
                  _Badge(status: e)
                      .animate(delay: (80 + i * 45).ms)
                      .fadeIn(duration: 380.ms)
                      .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.unlocked, required this.total});
  final int unlocked;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : unlocked / total;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('획득한 칭호', style: AppText.label(size: 12)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$unlocked', style: AppText.number(size: 34)),
              Text(' / $total 개',
                  style: const TextStyle(
                      fontSize: 16, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: AppColors.kraft,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.status});
  final AchievementStatus status;

  @override
  Widget build(BuildContext context) {
    final a = status.achievement;
    final on = status.unlocked;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: on
                ? AppColors.celadon.withValues(alpha: 0.30)
                : AppColors.line),
        boxShadow: on ? AppColors.cardShadow : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: on ? 1 : 0.4,
            child: Text(a.emoji, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(height: 8),
          Text(a.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.display(
                  size: 15,
                  color: on ? AppColors.textPrimary : AppColors.textSecondary)),
          const SizedBox(height: 3),
          Text(a.desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 11.5, height: 1.35, color: AppColors.textTertiary)),
          const Spacer(),
          if (on)
            _DonePill()
          else if (a.target <= 1)
            Row(
              children: [
                const Icon(Icons.lock_outline_rounded,
                    size: 13, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text('잠김', style: AppText.label(size: 10)),
              ],
            )
          else
            _Progress(progress: status.progress, target: a.target),
        ],
      ),
    );
  }
}

class _DonePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.celadon.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_rounded, size: 13, color: Color(0xFF3F6450)),
          const SizedBox(width: 3),
          Text('달성',
              style: AppText.number(
                  size: 11, color: const Color(0xFF3F6450), letterSpacing: 0)),
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.progress, required this.target});
  final int progress;
  final int target;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: target == 0 ? 0 : progress / target,
            minHeight: 5,
            backgroundColor: AppColors.kraft,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 5),
        Text('$progress / $target',
            style: AppText.number(
                size: 10,
                color: AppColors.textTertiary,
                letterSpacing: 0)),
      ],
    );
  }
}
