import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/duration_format.dart';
import '../../data/models/transport_type.dart';
import '../../data/repositories/collection_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../achievements/achievement.dart';

/// 통계: 누적 집중·완주율·연속 집중일·최근 7일 그래프·교통수단 분포.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(sessionRepositoryProvider);
    final total = repo.totalSeconds();
    final streak = repo.streak();
    final completed = repo.completedCount();
    final started = repo.totalCount();
    final week = repo.recentDays();
    final transport = repo.transportCounts();
    final achievementStat = AchievementStat.from(
        repo.all(),
        ref.watch(collectionRepositoryProvider).distinctCount,
        DateTime.now());
    final achieved = unlockedCount(achievementStat);

    final hasData = started > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('집중 통계'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: !hasData
            ? const _Empty()
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: '연속 집중',
                          value: '$streak',
                          unit: '일',
                          accent: AppColors.danchung,
                          emoji: '🔥',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: '완주 여정',
                          value: '$completed',
                          unit: '회',
                          accent: AppColors.celadon,
                          emoji: '🎫',
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 420.ms)
                      .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 12),
                  _TotalCard(seconds: total, completed: completed, started: started)
                      .animate(delay: 100.ms)
                      .fadeIn(duration: 420.ms)
                      .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 12),
                  _AchievementsTile(
                    achieved: achieved,
                    total: achievements.length,
                    onTap: () => context.push('/achievements'),
                  )
                      .animate(delay: 150.ms)
                      .fadeIn(duration: 420.ms)
                      .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 24),
                  Text('최근 7일', style: AppText.display(size: 16))
                      .animate(delay: 180.ms)
                      .fadeIn(duration: 420.ms),
                  const SizedBox(height: 12),
                  _WeeklyChart(days: week)
                      .animate(delay: 220.ms)
                      .fadeIn(duration: 420.ms)
                      .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 24),
                  Text('교통수단', style: AppText.display(size: 16))
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 420.ms),
                  const SizedBox(height: 12),
                  _TransportBreakdown(counts: transport, total: completed)
                      .animate(delay: 340.ms)
                      .fadeIn(duration: 420.ms)
                      .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
                ],
              ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.accent,
    required this.emoji,
  });
  final String label;
  final String value;
  final String unit;
  final Color accent;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(label, style: AppText.label(size: 11)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: AppText.number(size: 32, color: accent)),
              const SizedBox(width: 4),
              Text(unit,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard(
      {required this.seconds, required this.completed, required this.started});
  final int seconds;
  final int completed;
  final int started;

  @override
  Widget build(BuildContext context) {
    final rate = started == 0 ? 0.0 : completed / started;
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
          Text('누적 집중 시간', style: AppText.label(size: 12)),
          const SizedBox(height: 8),
          Text(formatDurationKo(seconds), style: AppText.number(size: 30)),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('완주율', style: AppText.label(size: 11)),
              const SizedBox(width: 8),
              Text('${(rate * 100).round()}%',
                  style: AppText.number(
                      size: 14, color: AppColors.primaryDark)),
              const Spacer(),
              Text('$completed / $started회',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 8,
              backgroundColor: AppColors.kraft,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.days});
  final List<DaySeconds> days;

  static const _weekdayKo = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final maxSeconds =
        days.fold<int>(0, (m, d) => d.seconds > m ? d.seconds : m);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
        boxShadow: AppColors.cardShadow,
      ),
      child: SizedBox(
        height: 140,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final d in days)
              Expanded(
                child: _Bar(
                  ratio: maxSeconds == 0 ? 0 : d.seconds / maxSeconds,
                  minutes: d.seconds ~/ 60,
                  weekday: _weekdayKo[d.day.weekday - 1],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar(
      {required this.ratio, required this.minutes, required this.weekday});
  final double ratio;
  final int minutes;
  final String weekday;

  @override
  Widget build(BuildContext context) {
    const trackHeight = 96.0;
    final hasValue = minutes > 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          hasValue ? '$minutes' : '',
          style: AppText.number(
              size: 10, color: AppColors.textSecondary, weight: FontWeight.w400),
        ),
        const SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: ratio),
          duration: 520.ms,
          curve: Curves.easeOutCubic,
          builder: (context, v, _) => Container(
            width: 18,
            height: (trackHeight * v).clamp(hasValue ? 4.0 : 0.0, trackHeight),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(weekday,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textTertiary)),
      ],
    );
  }
}

class _TransportBreakdown extends StatelessWidget {
  const _TransportBreakdown({required this.counts, required this.total});
  final Map<TransportType, int> counts;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          for (final (i, t) in TransportType.values.indexed) ...[
            if (i > 0) const SizedBox(height: 14),
            _TransportRow(
              type: t,
              count: counts[t] ?? 0,
              ratio: total == 0 ? 0 : (counts[t] ?? 0) / total,
            ),
          ],
        ],
      ),
    );
  }
}

class _TransportRow extends StatelessWidget {
  const _TransportRow(
      {required this.type, required this.count, required this.ratio});
  final TransportType type;
  final int count;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(type.emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        SizedBox(
          width: 44,
          child: Text(type.label,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textPrimary)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio),
              duration: 520.ms,
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 10,
                backgroundColor: AppColors.kraft,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.celadon),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text('$count회',
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _AchievementsTile extends StatelessWidget {
  const _AchievementsTile(
      {required this.achieved, required this.total, required this.onTap});
  final int achieved;
  final int total;
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            children: [
              const Icon(Icons.workspace_premium_outlined,
                  color: AppColors.primaryDark, size: 22),
              const SizedBox(width: 12),
              Text('칭호 · 업적', style: AppText.display(size: 15)),
              const Spacer(),
              Text('$achieved / $total',
                  style: AppText.number(
                      size: 14, color: AppColors.textSecondary)),
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

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📊', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 12),
          Text('아직 기록이 없어요', style: AppText.display(size: 16)),
          const SizedBox(height: 6),
          const Text('첫 여정을 떠나면 통계가 쌓여요',
              style: TextStyle(color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}
