import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../widgets/game_painter.dart';

/// Grid component with shimmer effects and ornamental design
class GridComponent extends Component with HasGameRef {
  final int gridWidth;
  final int gridHeight;
  int currentTheme = 0;
  double time = 0;

  GridComponent({
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

    // Draw shimmer effect on cells
    for (int x = 0; x < gridWidth; x++) {
      for (int y = 0; y < gridHeight; y++) {
        final cellRect = Rect.fromLTWH(
          x * cellSize,
          y * cellSize,
          cellSize,
          cellSize,
        );

        final shimmerPhase = (x + y) * 0.2 + time * 2;
        final shimmerIntensity = (sin(shimmerPhase) * 0.5 + 0.5) * 0.03;

        final shimmerPaint = Paint()
          ..color = theme.gridColor.withOpacity(shimmerIntensity);

        canvas.drawRect(cellRect, shimmerPaint);
      }
    }

    // Draw grid lines
    final mainGridPaint = Paint()
      ..color = theme.gridColor.withOpacity(0.35)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final accentGridPaint = Paint()
      ..color = theme.gridAccentColor.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = theme.gridAccentColor.withOpacity(0.15)
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
      ..style = PaintingStyle.stroke;

    // Vertical lines
    for (int i = 0; i <= gridWidth; i++) {
      final x = i * cellSize;
      final isAccent = i % 5 == 0;

      if (isAccent) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.y), glowPaint);
      }

      final paint = isAccent ? accentGridPaint : mainGridPaint;
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), paint);
    }

    // Horizontal lines
    for (int i = 0; i <= gridHeight; i++) {
      final y = i * cellSize;
      final isAccent = i % 5 == 0;

      if (isAccent) {
        canvas.drawLine(Offset(0, y), Offset(size.x, y), glowPaint);
      }

      final paint = isAccent ? accentGridPaint : mainGridPaint;
      canvas.drawLine(Offset(0, y), Offset(size.x, y), paint);
    }

    // Draw corner ornaments
    _drawCornerOrnaments(canvas, size, cellSize);
  }

  void _drawCornerOrnaments(Canvas canvas, Vector2 size, double cellSize) {
    final ornamentPaint = Paint()
      ..color = theme.gridColor.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final ornamentSize = cellSize * 1.5;

    // Draw ornaments at each corner
    _drawOrnament(canvas, Offset(0, 0), ornamentSize, ornamentPaint, true, true);
    _drawOrnament(
        canvas, Offset(size.x, 0), ornamentSize, ornamentPaint, false, true);
    _drawOrnament(
        canvas, Offset(0, size.y), ornamentSize, ornamentPaint, true, false);
    _drawOrnament(
        canvas, Offset(size.x, size.y), ornamentSize, ornamentPaint, false, false);
  }

  void _drawOrnament(
      Canvas canvas, Offset corner, double size, Paint paint, bool isLeft, bool isTop) {
    final path = Path();
    final xDir = isLeft ? 1 : -1;
    final yDir = isTop ? 1 : -1;

    path.moveTo(corner.dx + (size * xDir), corner.dy);
    path.quadraticBezierTo(
      corner.dx + (size * 0.5 * xDir),
      corner.dy + (size * 0.5 * yDir),
      corner.dx,
      corner.dy + (size * yDir),
    );

    canvas.drawPath(path, paint);
  }
}
