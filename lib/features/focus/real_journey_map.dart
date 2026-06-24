import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/transport_icon.dart';
import '../../data/models/place.dart';
import '../../data/models/transport_type.dart';

double _lerp(double a, double b, double t) => a + (b - a) * t;

/// OpenStreetMap 타일 기반 실제 지도. 출발/도착을 잇는 직선 경로 위를
/// 진행률만큼 교통수단 마커가 이동한다. (API 키 불필요)
class RealJourneyMap extends StatelessWidget {
  const RealJourneyMap({
    super.key,
    required this.progress,
    required this.transport,
    required this.origin,
    required this.destination,
  });

  final double progress;
  final TransportType transport;
  final Place origin;
  final Place destination;

  @override
  Widget build(BuildContext context) {
    final o = LatLng(origin.lat, origin.lng);
    final d = LatLng(destination.lat, destination.lng);
    final t = progress.clamp(0.0, 1.0);
    final cur = LatLng(
      _lerp(o.latitude, d.latitude, t),
      _lerp(o.longitude, d.longitude, t),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: FlutterMap(
        options: MapOptions(
          initialCameraFit: CameraFit.coordinates(
            coordinates: [o, d],
            padding: const EdgeInsets.all(56),
          ),
          interactionOptions:
              const InteractionOptions(flags: InteractiveFlag.none),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.gusle01.korean_focus',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: [o, d],
                strokeWidth: 4,
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
              Polyline(
                points: [o, cur],
                strokeWidth: 4,
                color: AppColors.primary,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(point: o, width: 16, height: 16, child: _dot(filled: true)),
              Marker(
                  point: d, width: 16, height: 16, child: _dot(filled: false)),
              Marker(
                point: cur,
                width: 44,
                height: 44,
                child: _vehicle(transportIcon(transport)),
              ),
            ],
          ),
          const RichAttributionWidget(
            alignment: AttributionAlignment.bottomLeft,
            attributions: [
              TextSourceAttribution('© OpenStreetMap contributors'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vehicle(IconData icon) => Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.surface, width: 3),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      );

  Widget _dot({required bool filled}) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? AppColors.primaryDark : AppColors.surface,
          border: Border.all(color: AppColors.primaryDark, width: 3),
        ),
      );
}
