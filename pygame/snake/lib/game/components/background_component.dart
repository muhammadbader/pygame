import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../widgets/game_painter.dart';

/// Background component with animated gradient and atmospheric effects
class BackgroundComponent extends Component with HasGameRef {
  int currentTheme = 0;
  double time = 0;

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

    // Draw dynamic background gradient
    _drawDynamicBackground(canvas, size);

    // Draw atmospheric effects (stars, moon, dust)
    _drawAtmosphericEffects(canvas, size);
  }

  void _drawDynamicBackground(Canvas canvas, Vector2 size) {
    final gradientShift = sin(time * 0.5) * 0.1;

    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(0, -1.0 + gradientShift),
        end: Alignment(0, 1.0 - gradientShift),
        colors: [theme.backgroundColor1, theme.backgroundColor2],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      backgroundPaint,
    );
  }

  void _drawAtmosphericEffects(Canvas canvas, Vector2 size) {
    // Draw twinkling stars
    final starPaint = Paint()
      ..color = theme.starColor
      ..style = PaintingStyle.fill;

    final random = Random(42);
    for (int i = 0; i < 80; i++) {
      final x = random.nextDouble() * size.x;
      final y = random.nextDouble() * size.y;
      final twinkle = sin(time * 2 + i * 0.5) * 0.5 + 0.5;
      final starSize = random.nextDouble() * 1.5 + 0.5;

      starPaint.color = theme.starColor.withOpacity(0.3 + twinkle * 0.5);
      canvas.drawCircle(Offset(x, y), starSize, starPaint);

      // Add cross sparkle to some stars
      if (i % 4 == 0) {
        final sparklePaint = Paint()
          ..color = theme.starColor.withOpacity(0.2 + twinkle * 0.3)
          ..strokeWidth = 0.5
          ..style = PaintingStyle.stroke;

        canvas.drawLine(
          Offset(x - starSize * 2, y),
          Offset(x + starSize * 2, y),
          sparklePaint,
        );
        canvas.drawLine(
          Offset(x, y - starSize * 2),
          Offset(x, y + starSize * 2),
          sparklePaint,
        );
      }
    }

    // Draw crescent moon
    final cellSize = size.x / 15;
    final moonCenter = Offset(size.x * 0.85, size.y * 0.15);
    final moonRadius = cellSize * 1.2;

    // Moon glow
    final moonGlowPaint = Paint()
      ..color = theme.moonColor.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(moonCenter, moonRadius * 2.5, moonGlowPaint);

    // Main moon
    final moonPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.moonColor,
          theme.moonColor.withOpacity(0.8),
        ],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: moonRadius));
    canvas.drawCircle(moonCenter, moonRadius, moonPaint);

    // Crescent shadow
    final shadowPaint = Paint()
      ..color = theme.backgroundColor1.withOpacity(0.7);
    canvas.drawCircle(
      Offset(moonCenter.dx + moonRadius * 0.4, moonCenter.dy - moonRadius * 0.2),
      moonRadius * 0.85,
      shadowPaint,
    );

    // Floating dust particles
    final dustRandom = Random(123);
    for (int i = 0; i < 40; i++) {
      final baseX = dustRandom.nextDouble() * size.x;
      final baseY = dustRandom.nextDouble() * size.y;

      final floatOffset = sin(time * 0.5 + i * 0.3) * 10;
      final x = baseX + floatOffset;
      final y = baseY + (time * 20 + i * 3) % size.y;

      final dustPaint = Paint()
        ..color = theme.gridColor.withOpacity(0.05 + sin(time + i) * 0.05);

      canvas.drawCircle(Offset(x, y), 1.0, dustPaint);
    }
  }
}
