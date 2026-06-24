import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/transport_icon.dart';
import '../../core/utils/duration_format.dart';
import '../../data/models/transport_type.dart';
import '../../data/static/route_durations.dart';
import '../journey/journey_selection_provider.dart';

class JourneyConfirmScreen extends ConsumerWidget {
  const JourneyConfirmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sel = ref.watch(journeySelectionProvider);
    if (!sel.isComplete) {
      return Scaffold(
        appBar: AppBar(title: const Text('여정 확인')),
        body: const Center(child: Text('여정 정보가 없습니다')),
      );
    }
    final route = buildRoute(sel.origin!, sel.destination!, sel.transport!);

    return Scaffold(
      appBar: AppBar(title: const Text('여정 확인')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _TicketCard(
                transportLabel: route.transport.label,
                icon: transportIcon(route.transport),
                grade: route.grade,
                originName: route.origin.name,
                destName: route.destination.name,
                durationText: formatMinutesKo(route.durationMinutes),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('집중 타이머는 Phase 3에서 구현됩니다')),
                    );
                  },
                  child: const Text('집중 시작',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
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
                child:
                    Icon(Icons.arrow_forward_rounded, color: AppColors.textTertiary),
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
