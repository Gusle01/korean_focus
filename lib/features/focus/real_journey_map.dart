import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/transport_icon.dart';
import '../../data/models/place.dart';
import '../../data/models/transport_type.dart';
import 'region_boundaries.dart';

double _lerp(double a, double b, double t) => a + (b - a) * t;

/// 줌이 이 값 이상이면 시·군·구 경계, 미만이면 시·도 경계를 표시.
const _muniZoomThreshold = 9.0;

/// OpenStreetMap 타일 기반 실제 지도.
/// - 출발/도착을 잇는 경로 위로 진행률만큼 교통수단 마커가 이동
/// - 행정구역 경계선 표시(줌에 따라 시·도 ↔ 시·군·구 전환)
/// - 핀치 줌 / 드래그로 확대·축소·이동 가능
class RealJourneyMap extends StatefulWidget {
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
  State<RealJourneyMap> createState() => _RealJourneyMapState();
}

class _RealJourneyMapState extends State<RealJourneyMap> {
  final _controller = MapController();
  double _zoom = 7;

  List<Polygon> _provincePolys = const [];
  List<Polygon> _muniPolys = const [];

  @override
  void initState() {
    super.initState();
    _loadBoundaries();
  }

  Future<void> _loadBoundaries() async {
    final provinces = await KoreaBoundaries.provinces();
    final munis = await KoreaBoundaries.municipalities();
    if (!mounted) return;
    setState(() {
      _provincePolys = _toPolygons(provinces, alpha: 0.30);
      _muniPolys = _toPolygons(munis, alpha: 0.22);
    });
  }

  List<Polygon> _toPolygons(List<BoundaryPolygon> src, {required double alpha}) {
    return [
      for (final b in src)
        Polygon(
          points: b.outer,
          holePointsList: b.holes.isEmpty ? null : b.holes,
          color: Colors.transparent,
          borderColor: AppColors.primary.withValues(alpha: alpha),
          borderStrokeWidth: 1.0,
        ),
    ];
  }

  void _onEvent(MapEvent event) {
    final z = event.camera.zoom;
    if ((z >= _muniZoomThreshold) != (_zoom >= _muniZoomThreshold)) {
      setState(() => _zoom = z);
    } else {
      _zoom = z;
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = LatLng(widget.origin.lat, widget.origin.lng);
    final d = LatLng(widget.destination.lat, widget.destination.lng);
    final t = widget.progress.clamp(0.0, 1.0);
    final cur = LatLng(
      _lerp(o.latitude, d.latitude, t),
      _lerp(o.longitude, d.longitude, t),
    );

    final boundary = _zoom >= _muniZoomThreshold ? _muniPolys : _provincePolys;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCameraFit: CameraFit.coordinates(
                coordinates: [o, d],
                padding: const EdgeInsets.all(56),
              ),
              onMapReady: () => setState(() => _zoom = _controller.camera.zoom),
              onMapEvent: _onEvent,
              interactionOptions: const InteractionOptions(
                // 회전은 막고 확대·축소·이동만 허용.
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.gusle01.korean_focus',
              ),
              if (boundary.isNotEmpty) PolygonLayer(polygons: boundary),
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
                  Marker(
                      point: o, width: 16, height: 16, child: _dot(filled: true)),
                  Marker(
                      point: d,
                      width: 16,
                      height: 16,
                      child: _dot(filled: false)),
                  Marker(
                    point: cur,
                    width: 44,
                    height: 44,
                    child: _vehicle(transportIcon(widget.transport)),
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
          // 확대/축소 버튼.
          Positioned(
            right: 12,
            bottom: 12,
            child: Column(
              children: [
                _ZoomButton(
                  icon: Icons.add_rounded,
                  onTap: () => _controller.move(
                      _controller.camera.center, _controller.camera.zoom + 1),
                ),
                const SizedBox(height: 8),
                _ZoomButton(
                  icon: Icons.remove_rounded,
                  onTap: () => _controller.move(
                      _controller.camera.center, _controller.camera.zoom - 1),
                ),
              ],
            ),
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

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 22, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
