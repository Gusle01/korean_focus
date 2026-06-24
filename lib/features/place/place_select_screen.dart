import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/transport_icon.dart';
import '../../data/models/place.dart';
import '../../data/models/transport_type.dart';
import '../../data/repositories/place_repository.dart';
import '../journey/journey_selection_provider.dart';

/// 출발지/도착지 선택 화면. mode = 'origin' | 'destination'.
class PlaceSelectScreen extends ConsumerStatefulWidget {
  const PlaceSelectScreen({super.key, required this.mode});

  final String mode;

  @override
  ConsumerState<PlaceSelectScreen> createState() => _PlaceSelectScreenState();
}

class _PlaceSelectScreenState extends ConsumerState<PlaceSelectScreen> {
  String _query = '';

  bool get _isOrigin => widget.mode == 'origin';

  void _onSelect(Place p) {
    final notifier = ref.read(journeySelectionProvider.notifier);
    if (_isOrigin) {
      notifier.selectOrigin(p);
      context.push('/place/destination');
    } else {
      notifier.selectDestination(p);
      context.push('/confirm');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sel = ref.watch(journeySelectionProvider);
    final transport = sel.transport;
    if (transport == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('교통수단을 먼저 선택해주세요')),
      );
    }

    final repo = ref.read(placeRepositoryProvider);
    var list = repo.search(transport, _query);
    if (!_isOrigin && sel.origin != null) {
      list = list.where((p) => p.id != sel.origin!.id).toList();
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isOrigin ? '어디서 출발할까요?' : '어디로 갈까요?')),
      body: SafeArea(
        child: Column(
          children: [
            if (!_isOrigin && sel.origin != null)
              _OriginBanner(name: sel.origin!.name),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: _SearchField(
                hint: '${transport.spotLabel} 또는 지역 검색',
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const Center(
                      child: Text('검색 결과가 없어요',
                          style: TextStyle(color: AppColors.textTertiary)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, i) =>
                          _PlaceTile(place: list[i], onTap: () => _onSelect(list[i])),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OriginBanner extends StatelessWidget {
  const _OriginBanner({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.trip_origin, size: 16, color: AppColors.primaryDark),
          const SizedBox(width: 8),
          Text('출발  $name',
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hint, required this.onChanged});
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c),
        );
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon:
            const Icon(Icons.search_rounded, color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        border: border(AppColors.line),
        enabledBorder: border(AppColors.line),
        focusedBorder: border(AppColors.primary),
      ),
    );
  }
}

class _PlaceTile extends StatelessWidget {
  const _PlaceTile({required this.place, required this.onTap});
  final Place place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Icon(transportIcon(place.type),
                  size: 20, color: AppColors.textTertiary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(place.city,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textTertiary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
