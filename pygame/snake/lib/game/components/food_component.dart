import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../../models/position.dart';
import '../../widgets/game_painter.dart';

/// Food component with floating animation and glow effects
class FoodComponent extends Component with HasGameRef {
  final Position position;
  final int gridWidth;
  final int gridHeight;
  int currentTheme = 0;
  double time = 0;

  FoodComponent({
    required this.position,
    required this.gridWidth,
    required this.gridHeight,
  });

  ThemeColors get theme => ThemeColors.themes[currentTheme];

  void updateTheme(int newTheme) {
    currentTheme = newTheme;
  }

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;
  }

  @override
  void render(Canvas canvas) {
    if (!gameRef.hasLayout) return;

    final size = gameRef.size;
    final cellWidth = size.x / gridWidth;
    final cellHeight = size.y / gridHeight;
    final cellSize = min(cellWidth, cellHeight);

    // Floating effect
    final floatOffset = sin(time * 2) * 2;

    final center = Offset(
      position.x * cellSize + cellSize / 2,
      position.y * cellSize + cellSize / 2 + floatOffset,
    );

    final pulseValue = (sin(time * 3) * 0.5 + 0.5);
    final baseRadius = cellSize * 0.35;
    final radius = baseRadius * (0.9 + pulseValue * 0.2);

    // Draw shadow beneath
    final shadowPaint = Paint()
      ..color = theme.foodColor.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, position.y * cellSize + cellSize / 2 + cellSize * 0.4),
        width: cellSize * 0.6,
        height: cellSize * 0.2,
      ),
      shadowPaint,
    );

    // Multi-layer glow
    final outerGlowPaint = Paint()
      ..color = theme.foodGlowColor.withOpacity(0.4 + pulseValue * 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(center, radius * 3.0, outerGlowPaint);

    final middleGlowPaint = Paint()
      ..color = theme.foodGlowColor.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(center, radius * 1.8, middleGlowPaint);

    // Draw ornamental frame
    _drawFrame(canvas, center, radius * 1.8, pulseValue);

    // Main food orb
    final foodPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          Colors.white,
          Color.lerp(Colors.white, theme.foodColor, 0.5)!,
          theme.foodColor,
          theme.foodAccentColor,
        ],
        stops: const [0.0, 0.2, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, foodPaint);

    // Draw star pattern
    _drawStar(canvas, center, radius * 0.6, pulseValue);

    // Highlights
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.85 + pulseValue * 0.15);

    canvas.drawCircle(
      Offset(center.dx - radius * 0.35, center.dy - radius * 0.35),
      radius * 0.28,
      highlightPaint,
    );

    // Sparkles
    _drawSparkles(canvas, center, pulseValue, radius);
  }

  void _drawFrame(Canvas canvas, Offset center, double size, double animation) {
    final framePaint = Paint()
      ..color = theme.foodAccentColor.withOpacity(0.6 + animation * 0.2)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(animation * pi * 2);

    final path = Path();
    final halfSize = size / 2;

    path.moveTo(0, -halfSize);
    path.lineTo(halfSize, 0);
    path.lineTo(0, halfSize);
    path.lineTo(-halfSize, 0);
    path.close();

    canvas.drawPath(path, framePaint);
    canvas.restore();
  }

  void _drawStar(Canvas canvas, Offset center, double size, double animation) {
    final starPaint = Paint()
      ..color = theme.snakeHeadColor.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(animation * pi);

    final path = Path();
    const points = 8;
    final outerRadius = size;
    final innerRadius = size * 0.5;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * pi / points);
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = cos(angle) * radius;
      final y = sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, starPaint);
    canvas.restore();
  }

  void _drawSparkles(Canvas canvas, Offset center, double animation, double baseRadius) {
    final sparklePaint = Paint()
      ..color = theme.foodColor.withOpacity(0.8);

    for (int i = 0; i < 6; i++) {
      final angle = (i * pi / 3) + (animation * pi * 2);
      final distance = baseRadius * (1.8 + sin(animation * pi * 2) * 0.3);
      final sparklePos = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance,
      );

      final sparkleSize = 2.5 * (0.6 + animation * 0.4);

      final path = Path();
      path.moveTo(sparklePos.dx, sparklePos.dy - sparkleSize);
      path.lineTo(sparklePos.dx + sparkleSize * 0.4, sparklePos.dy);
      path.lineTo(sparklePos.dx, sparklePos.dy + sparkleSize);
      path.lineTo(sparklePos.dx - sparkleSize * 0.4, sparklePos.dy);
      path.close();

      canvas.drawPath(path, sparklePaint);

      final sparkleHighlight = Paint()
        ..color = Colors.white.withOpacity(0.7 * animation);

      canvas.drawCircle(sparklePos, sparkleSize * 0.3, sparkleHighlight);
    }
  }
}
