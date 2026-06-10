import 'package:flutter/material.dart';

import '../../core/theme/trace_colors.dart';

/// Operational TRACE mark from UI/trace_operational_logo.
class TraceLogo extends StatelessWidget {
  const TraceLogo({
    super.key,
    this.size = 88,
    this.color = TraceColors.primary,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TraceLogoPainter(color: color),
      ),
    );
  }
}

class _TraceLogoPainter extends CustomPainter {
  const _TraceLogoPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100;
    canvas.scale(scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.square;

    final fill = Paint()
      ..color = TraceColors.background
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(15, 15, 70, 70),
      const Radius.circular(4),
    );
    canvas.drawRRect(rrect, stroke);

    canvas.drawLine(const Offset(35, 35), const Offset(65, 35), stroke);
    canvas.drawLine(const Offset(50, 35), const Offset(50, 75), stroke);

    canvas.drawRect(const Rect.fromLTWH(75, 45, 15, 10), fill);
  }

  @override
  bool shouldRepaint(covariant _TraceLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}
