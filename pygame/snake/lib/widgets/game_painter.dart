import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/position.dart';

/// Custom painter for rendering the snake game
class GamePainter extends CustomPainter {
  final GameState gameState;
  final double cellSize;
  final Animation<double>? foodAnimation;

  GamePainter({
    required this.gameState,
    required this.cellSize,
    this.foodAnimation,
  });

  // Arabian/Islamic color palette
  static const Color backgroundColor = Color(0xFF0D1B2A); // Deep midnight blue
  static const Color patternColor = Color(0xFF1A237E); // Rich indigo for patterns
  static const Color gridColor = Color(0xFFD4AF37); // Rich gold
  static const Color gridAccentColor = Color(0xFF00BCD4); // Turquoise accent
  static const Color snakeHeadColor = Color(0xFF00695C); // Emerald green
  static const Color snakeTailColor = Color(0xFF00BCD4); // Turquoise
  static const Color snakeGlowColor = Color(0x8000BCD4); // Turquoise glow
  static const Color snakePatternColor = Color(0xFFD4AF37); // Gold pattern
  static const Color foodColor = Color(0xFFFFD700); // Golden amber
  static const Color foodAccentColor = Color(0xFFFFC107); // Amber
  static const Color foodGlowColor = Color(0x80FFD700); // Gold glow
  static const Color starColor = Color(0x40D4AF37); // Subtle gold stars

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background with Arabian patterns
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    // Draw Islamic geometric star patterns in background
    _drawIslamicPatterns(canvas, size);

    // Draw ornamental grid
    _drawGrid(canvas, size);

    // Draw food (golden treasure)
    if (gameState.food != null) {
      _drawFood(canvas, gameState.food!);
    }

    // Draw snake (desert serpent)
    _drawSnake(canvas);
  }

  /// Draw Islamic geometric patterns in background
  void _drawIslamicPatterns(Canvas canvas, Size size) {
    final patternPaint = Paint()
      ..color = patternColor
      ..style = PaintingStyle.fill;

    final starPaint = Paint()
      ..color = starColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw 8-pointed Islamic stars across the background
    final starSpacing = cellSize * 4;
    for (double x = starSpacing; x < size.width; x += starSpacing) {
      for (double y = starSpacing; y < size.height; y += starSpacing) {
        _draw8PointedStar(canvas, Offset(x, y), cellSize * 0.8, starPaint);
      }
    }

    // Draw subtle geometric pattern overlay
    final overlayPaint = Paint()
      ..color = patternColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Diagonal pattern lines creating diamond shapes
    for (int i = -GameState.gridSize; i < GameState.gridSize * 2; i++) {
      final x1 = i * cellSize * 2;
      final path = Path();
      path.moveTo(x1, 0);
      path.lineTo(x1 + size.height, size.height);
      canvas.drawPath(
        path,
        Paint()
          ..color = patternColor.withOpacity(0.1)
          ..strokeWidth = 0.3
          ..style = PaintingStyle.stroke,
      );
    }
  }

  /// Draw an 8-pointed Islamic star
  void _draw8PointedStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final points = 8;
    final outerRadius = size / 2;
    final innerRadius = outerRadius * 0.4;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * pi / points) - pi / 2;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  /// Draw ornamental grid with Arabian aesthetic
  void _drawGrid(Canvas canvas, Size size) {
    // Main grid lines in gold
    final mainGridPaint = Paint()
      ..color = gridColor.withOpacity(0.3)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Accent lines in turquoise (every 5th line)
    final accentGridPaint = Paint()
      ..color = gridAccentColor.withOpacity(0.4)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Vertical lines
    for (int i = 0; i <= GameState.gridSize; i++) {
      final x = i * cellSize;
      final paint = (i % 5 == 0) ? accentGridPaint : mainGridPaint;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (int i = 0; i <= GameState.gridSize; i++) {
      final y = i * cellSize;
      final paint = (i % 5 == 0) ? accentGridPaint : mainGridPaint;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw corner ornaments
    _drawCornerOrnaments(canvas, size);
  }

  /// Draw decorative corner ornaments
  void _drawCornerOrnaments(Canvas canvas, Size size) {
    final ornamentPaint = Paint()
      ..color = gridColor.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final ornamentSize = cellSize * 1.5;

    // Top-left corner
    _drawOrnament(canvas, Offset(0, 0), ornamentSize, ornamentPaint);

    // Top-right corner
    _drawOrnament(canvas, Offset(size.width, 0), ornamentSize, ornamentPaint);

    // Bottom-left corner
    _drawOrnament(canvas, Offset(0, size.height), ornamentSize, ornamentPaint);

    // Bottom-right corner
    _drawOrnament(canvas, Offset(size.width, size.height), ornamentSize, ornamentPaint);
  }

  /// Draw a single corner ornament
  void _drawOrnament(Canvas canvas, Offset corner, double size, Paint paint) {
    final path = Path();
    final isLeft = corner.dx == 0;
    final isTop = corner.dy == 0;

    final xDir = isLeft ? 1 : -1;
    final yDir = isTop ? 1 : -1;

    // Draw decorative arc
    path.moveTo(corner.dx + (size * xDir), corner.dy);
    path.quadraticBezierTo(
      corner.dx + (size * 0.5 * xDir),
      corner.dy + (size * 0.5 * yDir),
      corner.dx,
      corner.dy + (size * yDir),
    );

    canvas.drawPath(path, paint);
  }

  /// Draw the desert serpent with Arabian patterns and gradient
  void _drawSnake(Canvas canvas) {
    for (int i = 0; i < gameState.snake.length; i++) {
      final segment = gameState.snake[i];
      final rect = Rect.fromLTWH(
        segment.x * cellSize + 1,
        segment.y * cellSize + 1,
        cellSize - 2,
        cellSize - 2,
      );

      // Calculate gradient position (emerald to turquoise)
      final gradientPosition = i / gameState.snake.length;
      final segmentColor = Color.lerp(
        snakeHeadColor,
        snakeTailColor,
        gradientPosition,
      )!;

      // Draw glow effect
      final glowRect = Rect.fromLTWH(
        segment.x * cellSize - 2,
        segment.y * cellSize - 2,
        cellSize + 4,
        cellSize + 4,
      );

      final glowPaint = Paint()
        ..color = snakeGlowColor.withOpacity(0.4 * (1 - gradientPosition))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawRRect(
        RRect.fromRectAndRadius(glowRect, const Radius.circular(6)),
        glowPaint,
      );

      // Draw main segment with gradient
      final segmentPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            segmentColor,
            segmentColor.withOpacity(0.8),
          ],
          stops: const [0.3, 1.0],
        ).createShader(rect)
        ..style = PaintingStyle.fill;

      final radius = i == 0 ? 8.0 : 6.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        segmentPaint,
      );

      // Draw Islamic geometric pattern on segments
      if (i % 2 == 0) {
        _drawSegmentPattern(canvas, rect, gradientPosition);
      }

      // Add decorative highlights to head
      if (i == 0) {
        // Main highlight
        final highlightPaint = Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(
            rect.left + rect.width * 0.35,
            rect.top + rect.height * 0.35,
          ),
          cellSize * 0.12,
          highlightPaint,
        );

        // Gold accent on head
        final accentPaint = Paint()
          ..color = snakePatternColor.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

        canvas.drawCircle(
          Offset(
            rect.left + rect.width * 0.5,
            rect.top + rect.height * 0.5,
          ),
          cellSize * 0.3,
          accentPaint,
        );
      }
    }
  }

  /// Draw geometric pattern on snake segment
  void _drawSegmentPattern(Canvas canvas, Rect rect, double fadeAmount) {
    final patternPaint = Paint()
      ..color = snakePatternColor.withOpacity(0.3 * (1 - fadeAmount))
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final center = rect.center;
    final size = rect.width * 0.4;

    // Draw small diamond pattern
    final path = Path();
    path.moveTo(center.dx, center.dy - size / 2);
    path.lineTo(center.dx + size / 2, center.dy);
    path.lineTo(center.dx, center.dy + size / 2);
    path.lineTo(center.dx - size / 2, center.dy);
    path.close();

    canvas.drawPath(path, patternPaint);
  }

  /// Draw golden treasure (food) with Arabian lantern aesthetic
  void _drawFood(Canvas canvas, Position food) {
    final center = Offset(
      food.x * cellSize + cellSize / 2,
      food.y * cellSize + cellSize / 2,
    );

    // Animated pulse
    final pulseValue = foodAnimation?.value ?? 0.5;
    final baseRadius = cellSize * 0.35;
    final radius = baseRadius * (0.9 + pulseValue * 0.2);

    // Outer golden glow (larger for Arabian aesthetic)
    final outerGlowPaint = Paint()
      ..color = foodGlowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawCircle(center, radius * 2.5, outerGlowPaint);

    // Middle glow
    final middleGlowPaint = Paint()
      ..color = foodGlowColor.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(center, radius * 1.5, middleGlowPaint);

    // Draw ornamental frame around treasure
    _drawTreasureFrame(canvas, center, radius * 1.8, pulseValue);

    // Main golden treasure orb
    final foodPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.9),
          foodColor,
          foodAccentColor,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, foodPaint);

    // Draw Islamic star pattern on treasure
    _drawTreasureStar(canvas, center, radius * 0.6, pulseValue);

    // Bright highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(
        center.dx - radius * 0.35,
        center.dy - radius * 0.35,
      ),
      radius * 0.25,
      highlightPaint,
    );

    // Sparkle particles around treasure
    _drawTreasureSparkles(canvas, center, pulseValue, radius);
  }

  /// Draw ornamental frame around treasure
  void _drawTreasureFrame(Canvas canvas, Offset center, double size, double animation) {
    final framePaint = Paint()
      ..color = foodAccentColor.withOpacity(0.6 + animation * 0.2)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw rotating ornamental squares
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(animation * pi * 2);

    final path = Path();
    final halfSize = size / 2;

    // Decorative diamond frame
    path.moveTo(0, -halfSize);
    path.lineTo(halfSize, 0);
    path.lineTo(0, halfSize);
    path.lineTo(-halfSize, 0);
    path.close();

    canvas.drawPath(path, framePaint);
    canvas.restore();
  }

  /// Draw Islamic star on treasure
  void _drawTreasureStar(Canvas canvas, Offset center, double size, double animation) {
    final starPaint = Paint()
      ..color = snakeHeadColor.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(animation * pi);

    final path = Path();
    final points = 8;
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

  /// Draw sparkle particles around treasure
  void _drawTreasureSparkles(Canvas canvas, Offset center, double animation, double baseRadius) {
    final sparklePaint = Paint()
      ..color = foodColor.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    // Draw 6 sparkles rotating around the treasure
    for (int i = 0; i < 6; i++) {
      final angle = (i * pi / 3) + (animation * pi * 2);
      final distance = baseRadius * (1.8 + sin(animation * pi * 2) * 0.3);
      final sparklePos = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance,
      );

      final sparkleSize = 2.5 * (0.6 + animation * 0.4);

      // Draw diamond sparkle
      final path = Path();
      path.moveTo(sparklePos.dx, sparklePos.dy - sparkleSize);
      path.lineTo(sparklePos.dx + sparkleSize * 0.4, sparklePos.dy);
      path.lineTo(sparklePos.dx, sparklePos.dy + sparkleSize);
      path.lineTo(sparklePos.dx - sparkleSize * 0.4, sparklePos.dy);
      path.close();

      canvas.drawPath(path, sparklePaint);

      // Add small white highlight on sparkle
      final sparkleHighlight = Paint()
        ..color = Colors.white.withOpacity(0.7 * animation);

      canvas.drawCircle(sparklePos, sparkleSize * 0.3, sparkleHighlight);
    }

    // Add subtle golden trail effect
    final trailPaint = Paint()
      ..color = foodAccentColor.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, baseRadius * (2.0 + animation * 0.5), trailPaint);
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) {
    return oldDelegate.gameState != gameState ||
        oldDelegate.foodAnimation != foodAnimation;
  }
}
