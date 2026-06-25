import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../core/theme/app_colors.dart';
import '../../core/ui/transport_icon.dart';
import '../../data/models/place.dart';
import '../../data/models/transport_type.dart';
import 'region_boundaries.dart';

/// 2차 베지에 곡선 위 한 점.
Offset _bezier(Offset p0, Offset p1, Offset p2, double t) {
  final u = 1 - t;
  return p0 * (u * u) + p1 * (2 * u * t) + p2 * (t * t);
}

/// 한국 대략 bbox(좌표) → 캔버스 좌표 투영(종횡비 보정, 가운데 정렬).
class _KoreaProjection {
  _KoreaProjection(Size size) {
    final geoW = (_lngMax - _lngMin) * _cosLat;
    const geoH = _latMax - _latMin;
    const pad = 14.0;
    _scale = math.min(
      (size.width - pad * 2) / geoW,
      (size.height - pad * 2) / geoH,
    );
    _ox = (size.width - geoW * _scale) / 2;
    _oy = (size.height - geoH * _scale) / 2;
  }

  static const _latMin = 33.2, _latMax = 38.45, _lngMin = 125.8, _lngMax = 129.75;
  static const _cosLat = 0.809; // cos(36°) 경도 보정
  late final double _scale, _ox, _oy;

  Offset project(double lat, double lng) => Offset(
        _ox + (lng - _lngMin) * _cosLat * _scale,
        _oy + (_latMax - lat) * _scale,
      );
  Offset of(LatLng p) => project(p.latitude, p.longitude);
}

/// 집중 진행을 한국 지도 위 여정으로 시각화하는 양식화(감성) 지도.
/// 시·도 행정구역 경계선 + 실제 좌표 기반 출발/도착 + 그 사이를 잇는 호 위로
/// 진행률만큼 이동하는 교통수단 마커.
class JourneyMap extends StatefulWidget {
  const JourneyMap({
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
  State<JourneyMap> createState() => _JourneyMapState();
}

class _JourneyMapState extends State<JourneyMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob;
  final TransformationController _zoom = TransformationController();
  Size _viewport = const Size(300, 300);
  List<BoundaryPolygon> _provinces = const [];

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _loadBoundaries();
  }

  Future<void> _loadBoundaries() async {
    try {
      final p = await KoreaBoundaries.provinces();
      if (mounted) setState(() => _provinces = p);
    } catch (_) {
      // 경계 로드 실패해도 경로/마커는 그대로 표시.
    }
  }

  @override
  void dispose() {
    _bob.dispose();
    _zoom.dispose();
    super.dispose();
  }

  /// 뷰포트 중심 기준으로 배율을 곱한다(핀치 줌과도 호환).
  void _zoomBy(double factor) {
    final current = _zoom.value.getMaxScaleOnAxis();
    final target = (current * factor).clamp(1.0, 6.0);
    if (target == current) return;
    final f = target / current;
    final c = _viewport.center(Offset.zero);
    // 중심 c 기준 배율 f 행렬: p' = f*(p-c)+c → 현재 변환에 합성.
    final s = Matrix4.identity()
      ..setEntry(0, 0, f)
      ..setEntry(1, 1, f)
      ..setEntry(0, 3, c.dx * (1 - f))
      ..setEntry(1, 3, c.dy * (1 - f));
    _zoom.value = s.multiplied(_zoom.value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4EEE3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, c) {
          final size = Size(c.maxWidth, c.maxHeight);
          _viewport = size;
          final proj = _KoreaProjection(size);
          final pA = proj.project(widget.origin.lat, widget.origin.lng);
          final pB = proj.project(widget.destination.lat, widget.destination.lng);
          // 두 점을 잇는 완만한 호의 제어점(수직 방향으로 살짝 띄움).
          final mid = (pA + pB) / 2;
          final d = pB - pA;
          final len = d.distance;
          final perp = len == 0 ? Offset.zero : Offset(d.dy, -d.dx) / len;
          final control = mid + perp * (len * 0.22);
          final t = widget.progress.clamp(0.0, 1.0);
          final pos = _bezier(pA, control, pB, t);

          return Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  transformationController: _zoom,
                  minScale: 1,
                  maxScale: 6,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _MapPainter(
                            provinces: _provinces,
                            proj: proj,
                            pA: pA,
                            pB: pB,
                            control: control,
                            progress: t,
                          ),
                        ),
                      ),
                      _label(widget.origin.name, pA, size, isOrigin: true),
                      _label(widget.destination.name, pB, size, isOrigin: false),
                      Positioned(
                        left: pos.dx - 22,
                        top: pos.dy - 22,
                        child: AnimatedBuilder(
                          animation: _bob,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(0, (_bob.value - 0.5) * 6),
                            child: child,
                          ),
                          child: _VehicleMarker(
                              icon: transportIcon(widget.transport)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Column(
                  children: [
                    _ZoomBtn(icon: Icons.add_rounded, onTap: () => _zoomBy(1.6)),
                    const SizedBox(height: 8),
                    _ZoomBtn(
                        icon: Icons.remove_rounded,
                        onTap: () => _zoomBy(1 / 1.6)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _label(String text, Offset at, Size size, {required bool isOrigin}) {
    final toRight = at.dx < size.width / 2;
    final top = (at.dy - 9).clamp(2.0, size.height - 24);
    return Positioned(
      left: toRight ? (at.dx + 14) : null,
      right: toRight ? null : (size.width - at.dx + 14),
      top: top,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.line),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _VehicleMarker extends StatelessWidget {
  const _VehicleMarker({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 3),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

class _ZoomBtn extends StatelessWidget {
  const _ZoomBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({
    required this.provinces,
    required this.proj,
    required this.pA,
    required this.pB,
    required this.control,
    required this.progress,
  });

  final List<BoundaryPolygon> provinces;
  final _KoreaProjection proj;
  final Offset pA;
  final Offset pB;
  final Offset control;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // 1) 행정구역(시·도) 경계 — 옅은 채움 + 외곽선.
    final fill = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeJoin = StrokeJoin.round;
    for (final poly in provinces) {
      final path = Path()..fillType = PathFillType.evenOdd;
      _addRing(path, poly.outer);
      for (final h in poly.holes) {
        _addRing(path, h);
      }
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
    }

    // 2) 경로(호): 남은 구간 점선 + 지나온 구간 실선.
    final route = Path()
      ..moveTo(pA.dx, pA.dy)
      ..quadraticBezierTo(control.dx, control.dy, pB.dx, pB.dy);
    canvas.drawPath(
      _dashPath(route, dash: 4, gap: 7),
      Paint()
        ..color = AppColors.textTertiary.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    final metric = route.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * progress),
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // 3) 출발(채움) / 도착(외곽선) 점.
    canvas.drawCircle(pA, 5.5, Paint()..color = AppColors.primaryDark);
    canvas.drawCircle(pB, 6.5, Paint()..color = AppColors.surface);
    canvas.drawCircle(
      pB,
      6.5,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  void _addRing(Path path, List<LatLng> ring) {
    if (ring.length < 2) return;
    final first = proj.of(ring.first);
    path.moveTo(first.dx, first.dy);
    for (final pt in ring.skip(1)) {
      final o = proj.of(pt);
      path.lineTo(o.dx, o.dy);
    }
    path.close();
  }

  Path _dashPath(Path source, {required double dash, required double gap}) {
    final result = Path();
    for (final metric in source.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final next = dist + dash;
        result.addPath(
          metric.extractPath(dist, next.clamp(0.0, metric.length)),
          Offset.zero,
        );
        dist = next + gap;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
      old.progress != progress ||
      old.provinces.length != provinces.length ||
      old.pA != pA ||
      old.pB != pB;
}
