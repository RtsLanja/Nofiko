import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/color.dart';

class HexLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = size.width  * 0.16;
    final gap = r * 0.25;
    final d  = r * 2 + gap;

    final paintSat = Paint()..color = ColorPalette.teal    ..style = PaintingStyle.fill;
    final paintCtr = Paint()..color = ColorPalette.tealLight..style = PaintingStyle.fill;

    final positions = [
      Offset(cx, cy),
      Offset(cx,             cy - d),
      Offset(cx + d * 0.866, cy - d * 0.5),
      Offset(cx + d * 0.866, cy + d * 0.5),
      Offset(cx,             cy + d),
      Offset(cx - d * 0.866, cy + d * 0.5),
      Offset(cx - d * 0.866, cy - d * 0.5),
    ];

    for (int i = 0; i < positions.length; i++) {
      canvas.drawPath(_hexPath(positions[i], r), i == 0 ? paintCtr : paintSat);
    }
  }

  Path _hexPath(Offset center, double r) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_) => false;
}