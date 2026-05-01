import 'dart:math';

import 'package:flutter/material.dart';

class Star {
  final double x, y, radius, speed, offset;
  final Color color;

  Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.offset,
    required this.color,
  });
}

class StarfieldPainter extends CustomPainter {
  final List<Star> stars;
  final double phase;

  StarfieldPainter(this.stars, this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final opacity = 0.3 + 0.7 * ((sin(phase * s.speed + s.offset) + 1) / 2);

      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.radius,
        Paint()
          ..color = s.color.withOpacity(opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.radius * 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(StarfieldPainter old) => old.phase != phase;
}
