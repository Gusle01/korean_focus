import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/transport_icon.dart';
import '../../data/models/transport_type.dart';

/// 2차 베지에 곡선 위 한 점.
Offset _bezier(Offset p0, Offset p1, Offset p2, double t) {
  final u = 1 - t;
  return p0 * (u * u) + p1 * (2 * u * t) + p2 * (t * t);
}

/// 집중 진행을 한국적 여정으로 시각화하는 양식화 지도.
/// 곡선 경로 + 지나온(실선)/남은(점선) 구간 + 곡선 위를 이동하는 교통수단 마커.
class JourneyMap extends StatefulWidget {
  const JourneyMap({
    super.key,
    required this.progress,
    required this.transport,
    required this.originName,
    required this.destName,
  });

  final double progress;
  final TransportType transport;
  final String originName;
  final String destName;

  @override
  State<JourneyMap> createState() => _JourneyMapState();
}

class _JourneyMapState extends State<JourneyMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
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
          final p0 = Offset(size.width * 0.15, size.height * 0.78);
          final p1 = Offset(size.width * 0.52, size.height * 0.08);
          final p2 = Offset(size.width * 0.85, size.height * 0.26);
          final t = widget.progress.clamp(0.0, 1.0);
          final pos = _bezier(p0, p1, p2, t);

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _RoutePainter(p0: p0, p1: p1, p2: p2, progress: t),
                ),
              ),
              _label(p0, widget.originName, size, isOrigin: true),
              _label(p2, widget.destName, size, isOrigin: false),
              Positioned(
                left: pos.dx - 22,
                top: pos.dy - 22,
                child: AnimatedBuilder(
                  animation: _bob,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, (_bob.value - 0.5) * 6),
                    child: child,
                  ),
                  child: _VehicleMarker(icon: transportIcon(widget.transport)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _label(Offset at, String text, Size size, {required bool isOrigin}) {
    return Positioned(
      left: isOrigin ? at.dx + 14 : null,
      right: isOrigin ? null : (size.width - at.dx) + 14,
      top: at.dy - 9,
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

class _RoutePainter extends CustomPainter {
  _RoutePainter({
    required this.p0,
    required this.p1,
    required this.p2,
    required this.progress,
  });

  final Offset p0;
  final Offset p1;
  final Offset p2;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..quadraticBezierTo(p1.dx, p1.dy, p2.dx, p2.dy);

    // 남은 경로 (점선)
    canvas.drawPath(
      _dashPath(path, dash: 4, gap: 7),
      Paint()
        ..color = AppColors.textTertiary.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // 지나온 경로 (실선)
    final metric = path.computeMetrics().first;
    final traveled = metric.extractPath(0, metric.length * progress);
    canvas.drawPath(
      traveled,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // 출발 점 (채움)
    canvas.drawCircle(p0, 5.5, Paint()..color = AppColors.primaryDark);
    // 도착 점 (외곽선)
    canvas.drawCircle(p2, 6.5, Paint()..color = AppColors.surface);
    canvas.drawCircle(
      p2,
      6.5,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  /// 경로를 점선으로 변환.
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
  bool shouldRepaint(_RoutePainter old) =>
      old.progress != progress || old.p0 != p0 || old.p2 != p2;
}
