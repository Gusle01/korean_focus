import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 「승차권」 카드 — 따뜻한 종이 위 표 한 장.
///
/// [header]와 [body] 사이에 천공(notch)과 절취선(점선)을 그려 표의 물성을 준다.
/// [body]가 없으면 천공 없이 단순 카드로도 쓸 수 있다.
class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.header,
    this.body,
    this.color = AppColors.surface,
    this.borderColor,
    this.notchColor,
    this.padding = const EdgeInsets.all(20),
    this.radius = 20,
  });

  final Widget header;
  final Widget? body;
  final Color color;
  final Color? borderColor;

  /// 천공 구멍에 비치는 '뒤 배경' 색(보통 scaffold 종이색).
  final Color? notchColor;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final notch = notchColor ?? Theme.of(context).scaffoldBackgroundColor;
    final border = borderColor ?? AppColors.line;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(padding.left, padding.top,
                padding.right, body == null ? padding.bottom : 14),
            child: header,
          ),
          if (body != null) ...[
            _Perforation(notchColor: notch, lineColor: border),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  padding.left, 14, padding.right, padding.bottom),
              child: body!,
            ),
          ],
        ],
      ),
    );
  }
}

/// 좌우 가장자리 천공 + 가운데 절취 점선(풀-블리드).
class _Perforation extends StatelessWidget {
  const _Perforation({required this.notchColor, required this.lineColor});
  final Color notchColor;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      width: double.infinity,
      child: CustomPaint(painter: _PerforationPainter(notchColor, lineColor)),
    );
  }
}

class _PerforationPainter extends CustomPainter {
  _PerforationPainter(this.notchColor, this.lineColor);
  final Color notchColor;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    const r = 9.0;
    final notch = Paint()..color = notchColor;
    final rim = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    // 좌우 가장자리에 천공(구멍).
    for (final cx in [0.0, size.width]) {
      canvas.drawCircle(Offset(cx, cy), r, notch);
      canvas.drawCircle(Offset(cx, cy), r, rim);
    }
    // 가운데 절취 점선.
    final dash = Paint()
      ..color = lineColor
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    const gap = 7.0, len = 4.0;
    var x = r + 6;
    final end = size.width - r - 6;
    while (x < end) {
      canvas.drawLine(Offset(x, cy), Offset(math.min(x + len, end), cy), dash);
      x += len + gap;
    }
  }

  @override
  bool shouldRepaint(_PerforationPainter old) =>
      old.notchColor != notchColor || old.lineColor != lineColor;
}
