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

  // Retro-future color palette
  static const Color gridColor = Color(0xFF0A4D4D); // Teal
  static const Color snakeColor = Color(0xFF00FFFF); // Cyan
  static const Color snakeGlowColor = Color(0x8000FFFF); // Cyan glow
  static const Color foodColor = Color(0xFFFF00FF); // Magenta
  static const Color foodGlowColor = Color(0x80FF00FF); // Magenta glow
  static const Color backgroundColor = Color(0xFF000000); // Black

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    // Draw grid
    _drawGrid(canvas, size);

    // Draw food
    if (gameState.food != null) {
      _drawFood(canvas, gameState.food!);
    }

    // Draw snake
    _drawSnake(canvas);
  }

  /// Draw grid lines
  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Vertical lines
    for (int i = 0; i <= GameState.gridSize; i++) {
      final x = i * cellSize;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (int i = 0; i <= GameState.gridSize; i++) {
      final y = i * cellSize;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  /// Draw the snake with glow effect
  void _drawSnake(Canvas canvas) {
    for (int i = 0; i < gameState.snake.length; i++) {
      final segment = gameState.snake[i];
      final rect = Rect.fromLTWH(
        segment.x * cellSize + 1,
        segment.y * cellSize + 1,
        cellSize - 2,
        cellSize - 2,
      );

      // Draw glow (larger rect behind)
      final glowRect = Rect.fromLTWH(
        segment.x * cellSize - 2,
        segment.y * cellSize - 2,
        cellSize + 4,
        cellSize + 4,
      );

      final glowPaint = Paint()
        ..color = snakeGlowColor.withOpacity(0.3 * (1 - i / gameState.snake.length))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawRRect(
        RRect.fromRectAndRadius(glowRect, const Radius.circular(4)),
        glowPaint,
      );

      // Draw segment
      final segmentPaint = Paint()
        ..color = snakeColor
        ..style = PaintingStyle.fill;

      // Head is slightly different
      final radius = i == 0 ? 6.0 : 4.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        segmentPaint,
      );

      // Add highlight to head
      if (i == 0) {
        final highlightPaint = Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(
            rect.left + rect.width * 0.3,
            rect.top + rect.height * 0.3,
          ),
          cellSize * 0.15,
          highlightPaint,
        );
      }
    }
  }

  /// Draw food with pulsing animation
  void _drawFood(Canvas canvas, Position food) {
    final center = Offset(
      food.x * cellSize + cellSize / 2,
      food.y * cellSize + cellSize / 2,
    );

    // Animated pulse
    final pulseValue = foodAnimation?.value ?? 0.5;
    final radius = cellSize * 0.3 * (0.8 + pulseValue * 0.4);

    // Outer glow
    final glowPaint = Paint()
      ..color = foodGlowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(center, radius * 2, glowPaint);

    // Main food orb
    final foodPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          foodColor,
          foodColor.withOpacity(0.6),
        ],
        stops: const [0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, foodPaint);

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(
        center.dx - radius * 0.3,
        center.dy - radius * 0.3,
      ),
      radius * 0.3,
      highlightPaint,
    );

    // Particles around food
    _drawFoodParticles(canvas, center, pulseValue);
  }

  /// Draw particles around food
  void _drawFoodParticles(Canvas canvas, Offset center, double animation) {
    final particlePaint = Paint()
      ..color = foodColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final angle = (i * pi / 2) + (animation * pi * 2);
      final distance = cellSize * 0.5 * (0.5 + animation * 0.3);
      final particlePos = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance,
      );

      canvas.drawCircle(
        particlePos,
        2 * (1 - animation),
        particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) {
    return oldDelegate.gameState != gameState ||
        oldDelegate.foodAnimation != foodAnimation;
  }
}
