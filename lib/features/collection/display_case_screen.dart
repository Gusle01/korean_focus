import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/duration_format.dart';
import '../../data/models/collectible_category.dart';
import '../../data/models/owned_collectible.dart';
import '../../data/models/transport_type.dart';
import '../../data/repositories/collection_repository.dart';
import '../../data/static/collectibles.dart';

/// 진열장: 도착으로 모은 컬렉션을 도시별로 모아 보여준다.
class DisplayCaseScreen extends ConsumerWidget {
  const DisplayCaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(collectionRepositoryProvider);
    final byCity = repo.byCity();
    final cities = byCity.keys.toList();
    final distinct = repo.distinctCount;
    final total = allCollectibles.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('진열장'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: byCity.isEmpty
            ? const _Empty()
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                children: [
                  _ProgressCard(
                          owned: repo.count, distinct: distinct, total: total)
                      .animate()
                      .fadeIn(duration: 420.ms)
                      .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 24),
                  for (final (i, city) in cities.indexed) ...[
                    _CitySection(city: city, items: byCity[city]!)
                        .animate(delay: (120 + i * 90).ms)
                        .fadeIn(duration: 420.ms)
                        .slideY(
                            begin: 0.12, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard(
      {required this.owned, required this.distinct, required this.total});
  final int owned;
  final int distinct;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : distinct / total;
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
          Text('도감 진행도', style: AppText.label(size: 12)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$distinct', style: AppText.number(size: 34)),
              Text(' / $total 종',
                  style: const TextStyle(
                      fontSize: 16, color: AppColors.textSecondary)),
              const Spacer(),
              Text('총 $owned개 수집',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: AppColors.line,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CitySection extends StatelessWidget {
  const _CitySection({required this.city, required this.items});
  final String city;
  final List<OwnedCollectible> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(city, style: AppText.display(size: 16)),
            const SizedBox(width: 6),
            Text('${items.length}',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textTertiary)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [for (final it in items) _CollectibleChip(item: it)],
        ),
      ],
    );
  }
}

class _CollectibleChip extends StatelessWidget {
  const _CollectibleChip({required this.item});
  final OwnedCollectible item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => _DetailSheet(item: item),
      ),
      child: Container(
        width: 84,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            Text(item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

/// 컬렉션 상세: 획득 날짜 · 출발 지역 · 이동 수단 · 소요 시간.
class _DetailSheet extends StatelessWidget {
  const _DetailSheet({required this.item});
  final OwnedCollectible item;

  @override
  Widget build(BuildContext context) {
    final category = CollectibleCategory.values[item.categoryIndex];
    final transport = TransportType.values[item.transportIndex];
    final def = collectibleDefById(item.defId);
    final dateStr = DateFormat('yyyy년 M월 d일').format(item.acquiredAt);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 44)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item.city} · ${category.label}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(item.name, style: AppText.display(size: 20)),
                    ],
                  ),
                ),
              ],
            ),
            if (def != null) ...[
              const SizedBox(height: 14),
              Text(def.description,
                  style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 22),
            const Divider(color: AppColors.line, height: 1),
            const SizedBox(height: 18),
            _InfoRow(
                icon: Icons.event_rounded, label: '획득 날짜', value: dateStr),
            _InfoRow(
                icon: Icons.my_location_rounded,
                label: '출발 지역',
                value: item.originName),
            _InfoRow(
                icon: Icons.flag_rounded,
                label: '도착 지역',
                value: item.destName),
            _InfoRow(
                icon: Icons.directions_transit_rounded,
                label: '이동 수단',
                value: '${transport.emoji} ${transport.label}'),
            _InfoRow(
                icon: Icons.timer_outlined,
                label: '소요 시간',
                value: formatDurationKo(item.durationSeconds)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary)),
          const Spacer(),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🗺️', style: TextStyle(fontSize: 48)),
          SizedBox(height: 16),
          Text('아직 모은 컬렉션이 없어요',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          SizedBox(height: 8),
          Text('여정을 완주하면 도착 지역의 특산품·음식·전통·명소를\n하나씩 모을 수 있어요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}
