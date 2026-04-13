import 'package:flutter/material.dart';

enum FilterType { makeup, hair, accessory, look }

class ARFilter {
  final String id;
  final String name;
  final String icon;
  final FilterType type;
  final Color? primaryColor;
  final String? assetPath;
  final Map<String, Color>? composition; // e.g., {'lips': Colors.red, 'hair': Colors.blonde}

  const ARFilter({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.primaryColor,
    this.assetPath,
    this.composition,
  });
}

class ARMakeupEngine {
  static void drawLipstick(Canvas canvas, Path path, Color color, double opacity) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(path, paint);

    // Gloss effect
    final glossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
    canvas.drawPath(path, glossPaint);
  }

  static void drawBlush(Canvas canvas, Offset center, double radius, Color color, double opacity) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);
  }

  static void drawEyeliner(Canvas canvas, Path path, Color color, double opacity) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
  }
}
