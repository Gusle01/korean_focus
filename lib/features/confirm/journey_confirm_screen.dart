import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/transport_icon.dart';
import '../../core/utils/duration_format.dart';
import '../../data/models/transport_type.dart';
import '../../data/static/route_durations.dart';
import '../focus/focus_timer_provider.dart';
import '../journey/journey_selection_provider.dart';

class JourneyConfirmScreen extends ConsumerStatefulWidget {
  const JourneyConfirmScreen({super.key});

  @override
  ConsumerState<JourneyConfirmScreen> createState() =>
      _JourneyConfirmScreenState();
}

class _JourneyConfirmScreenState extends ConsumerState<JourneyConfirmScreen> {
  int _selectedMinutes = 25;

  @override
  Widget build(BuildContext context) {
    final sel = ref.watch(journeySelectionProvider);
    if (!sel.isComplete) {
      return Scaffold(
        appBar: AppBar(title: const Text('여정 확인')),
        body: const Center(child: Text('여정 정보가 없습니다')),
      );
    }
    final route = buildRoute(sel.origin!, sel.destination!, sel.transport!);
    final actual = route.durationMinutes;
    final options = <(int, String)>[
      (25, '25분'),
      (50, '50분'),
      (90, '90분'),
      (actual, '실제 ${formatMinutesKo(actual)}'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('여정 확인')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TicketCard(
                transportLabel: route.transport.label,
                icon: transportIcon(route.transport),
                grade: route.grade,
                originName: route.origin.name,
                destName: route.destination.name,
                durationText: formatMinutesKo(route.durationMinutes),
              ),
              const SizedBox(height: 28),
              const Text('집중 시간을 선택하세요',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final (m, label) in options)
                    _DurationChip(
                      label: label,
                      selected: _selectedMinutes == m,
                      onTap: () => setState(() => _selectedMinutes = m),
                    ),
                ],
              ),
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
                  onPressed: () {
                    ref
                        .read(focusTimerProvider.notifier)
                        .start(Duration(minutes: _selectedMinutes));
                    context.go('/focus');
                  },
                  child: const Text('집중 시작',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.14)
          : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.line),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color:
                  selected ? AppColors.primaryDark : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.transportLabel,
    required this.icon,
    required this.grade,
    required this.originName,
    required this.destName,
    required this.durationText,
  });

  final String transportLabel;
  final IconData icon;
  final String grade;
  final String originName;
  final String destName;
  final String durationText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryDark, size: 22),
              const SizedBox(width: 8),
              Text(transportLabel,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(grade,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryDark)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _Endpoint(
                    label: '출발',
                    name: originName,
                    align: CrossAxisAlignment.start),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward_rounded,
                    color: AppColors.textTertiary),
              ),
              Expanded(
                child: _Endpoint(
                    label: '도착',
                    name: destName,
                    align: CrossAxisAlignment.end),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.line, height: 1),
          const SizedBox(height: 16),
          const Text('예상 소요 시간',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
          const SizedBox(height: 4),
          Text(durationText,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _Endpoint extends StatelessWidget {
  const _Endpoint(
      {required this.label, required this.name, required this.align});
  final String label;
  final String name;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
        const SizedBox(height: 4),
        Text(name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ],
    );
  }
}
