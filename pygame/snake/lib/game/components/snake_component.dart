import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../../models/position.dart';
import '../../models/direction.dart';
import '../../widgets/game_painter.dart';

/// Snake component with trailing effects and animations
class SnakeComponent extends Component with HasGameRef {
  List<Position> snake;
  final int gridWidth;
  final int gridHeight;
  Direction currentDirection = Direction.right;
  int currentTheme = 0;
  double time = 0;

  SnakeComponent({
    required this.snake,
    required this.gridWidth,
    required this.gridHeight,
  });

  ThemeColors get theme => ThemeColors.themes[currentTheme];

  void updateSnake(List<Position> newSnake, Direction direction) {
    snake = newSnake;
    currentDirection = direction;
  }

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
    if (!gameRef.hasLayout || snake.isEmpty) return;

    final size = gameRef.size;
    final cellWidth = size.x / gridWidth;
    final cellHeight = size.y / gridHeight;
    final cellSize = min(cellWidth, cellHeight);

    // Draw trail effect
    _drawTrail(canvas, cellSize);

    // Draw snake segments
    for (int i = 0; i < snake.length; i++) {
      final segment = snake[i];
      final rect = Rect.fromLTWH(
        segment.x * cellSize + 1,
        segment.y * cellSize + 1,
        cellSize - 2,
        cellSize - 2,
      );

      final gradientPosition = i / snake.length;

      // Calculate segment color
      Color segmentColor;
      if (gradientPosition < 0.5) {
        segmentColor = Color.lerp(
          theme.snakeHeadColor,
          Color.lerp(theme.snakeHeadColor, theme.snakeTailColor, 0.5)!,
          gradientPosition * 2,
        )!;
      } else {
        segmentColor = Color.lerp(
          Color.lerp(theme.snakeHeadColor, theme.snakeTailColor, 0.5)!,
          theme.snakeTailColor,
          (gradientPosition - 0.5) * 2,
        )!;
      }

      // Multi-layer glow
      final glowRect = Rect.fromLTWH(
        segment.x * cellSize - 3,
        segment.y * cellSize - 3,
        cellSize + 6,
        cellSize + 6,
      );

      final pulseAmount = sin(time * 3 - i * 0.2) * 0.5 + 0.5;
      final outerGlowPaint = Paint()
        ..color = theme.snakeGlowColor
            .withOpacity(0.5 * (1 - gradientPosition) * (0.7 + pulseAmount * 0.3))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawRRect(
        RRect.fromRectAndRadius(glowRect, Radius.circular(8)),
        outerGlowPaint,
      );

      // Main segment
      final segmentPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            Colors.white.withOpacity(0.3),
            segmentColor,
            segmentColor.withOpacity(0.7),
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(rect);

      final radius = i == 0 ? 9.0 : 7.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        segmentPaint,
      );

      // Draw pattern on segments
      if (i % 2 == 0) {
        _drawSegmentPattern(canvas, rect, gradientPosition);
      }

      // Enhanced head decorations
      if (i == 0) {
        _drawHead(canvas, rect, cellSize);
      }
    }
  }

  void _drawTrail(Canvas canvas, double cellSize) {
    if (snake.length < 2) return;

    for (int i = 1; i < snake.length; i++) {
      final segment = snake[i];
      final center = Offset(
        segment.x * cellSize + cellSize / 2,
        segment.y * cellSize + cellSize / 2,
      );

      final trailFade = 1.0 - (i / snake.length);
      final trailRadius = cellSize * 0.6;

      final pulsePhase = time * 2 - i * 0.1;
      final pulseIntensity = (sin(pulsePhase) * 0.5 + 0.5) * 0.2;

      final trailPaint = Paint()
        ..color =
            theme.snakeGlowColor.withOpacity(trailFade * (0.15 + pulseIntensity))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(center, trailRadius, trailPaint);
    }
  }

  void _drawSegmentPattern(Canvas canvas, Rect rect, double fadeAmount) {
    final patternPaint = Paint()
      ..color = theme.snakePatternColor.withOpacity(0.3 * (1 - fadeAmount))
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final center = rect.center;
    final size = rect.width * 0.4;

    final path = Path();
    path.moveTo(center.dx, center.dy - size / 2);
    path.lineTo(center.dx + size / 2, center.dy);
    path.lineTo(center.dx, center.dy + size / 2);
    path.lineTo(center.dx - size / 2, center.dy);
    path.close();

    canvas.drawPath(path, patternPaint);
  }

  void _drawHead(Canvas canvas, Rect rect, double cellSize) {
    final center = rect.center;

    // Animated head glow pulse
    final headPulse = sin(time * 4) * 0.5 + 0.5;
    final headGlowPaint = Paint()
      ..color = Colors.white.withOpacity(0.3 + headPulse * 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(center, cellSize * 0.4, headGlowPaint);

    // Main highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.6);

    canvas.drawCircle(
      Offset(
        rect.left + rect.width * 0.35,
        rect.top + rect.height * 0.35,
      ),
      cellSize * 0.15,
      highlightPaint,
    );

    // Accent ring on head
    final accentPaint = Paint()
      ..color = theme.snakePatternColor.withOpacity(0.7 + headPulse * 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, cellSize * 0.32, accentPaint);

    // Inner accent
    final innerAccentPaint = Paint()
      ..color = theme.gridAccentColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, cellSize * 0.20, innerAccentPaint);
  }
}
