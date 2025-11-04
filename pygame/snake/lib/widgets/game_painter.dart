import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/position.dart';

/// Theme color palette for dynamic theme switching
class ThemeColors {
  final Color backgroundColor1;
  final Color backgroundColor2;
  final Color patternColor;
  final Color gridColor;
  final Color gridAccentColor;
  final Color snakeHeadColor;
  final Color snakeTailColor;
  final Color snakeGlowColor;
  final Color snakePatternColor;
  final Color foodColor;
  final Color foodAccentColor;
  final Color foodGlowColor;
  final Color starColor;
  final Color moonColor;
  final String themeName;

  const ThemeColors({
    required this.backgroundColor1,
    required this.backgroundColor2,
    required this.patternColor,
    required this.gridColor,
    required this.gridAccentColor,
    required this.snakeHeadColor,
    required this.snakeTailColor,
    required this.snakeGlowColor,
    required this.snakePatternColor,
    required this.foodColor,
    required this.foodAccentColor,
    required this.foodGlowColor,
    required this.starColor,
    required this.moonColor,
    required this.themeName,
  });

  // Theme 0: Midnight Desert (default - deep blues and gold)
  static const midnight = ThemeColors(
    backgroundColor1: Color(0xFF0D1B2A),
    backgroundColor2: Color(0xFF1A237E),
    patternColor: Color(0xFF1A237E),
    gridColor: Color(0xFFD4AF37),
    gridAccentColor: Color(0xFF00BCD4),
    snakeHeadColor: Color(0xFF00695C),
    snakeTailColor: Color(0xFF00BCD4),
    snakeGlowColor: Color(0x8000BCD4),
    snakePatternColor: Color(0xFFD4AF37),
    foodColor: Color(0xFFFFD700),
    foodAccentColor: Color(0xFFFFC107),
    foodGlowColor: Color(0x80FFD700),
    starColor: Color(0x40D4AF37),
    moonColor: Color(0xFFFFFAF0),
    themeName: 'Midnight Desert',
  );

  // Theme 1: Desert Sunset (warm oranges, purples, and gold)
  static const sunset = ThemeColors(
    backgroundColor1: Color(0xFF2D1B4E),
    backgroundColor2: Color(0xFF4A1E3C),
    patternColor: Color(0xFF3E2C5A),
    gridColor: Color(0xFFFF8C42),
    gridAccentColor: Color(0xFFFF6B9D),
    snakeHeadColor: Color(0xFFFF6347),
    snakeTailColor: Color(0xFFFF8C42),
    snakeGlowColor: Color(0x80FF6347),
    snakePatternColor: Color(0xFFFFD700),
    foodColor: Color(0xFFFF6B9D),
    foodAccentColor: Color(0xFFFF1493),
    foodGlowColor: Color(0x80FF6B9D),
    starColor: Color(0x40FF8C42),
    moonColor: Color(0xFFFFB347),
    themeName: 'Desert Sunset',
  );

  // Theme 2: Emerald Oasis (greens and jade)
  static const oasis = ThemeColors(
    backgroundColor1: Color(0xFF0A2E2E),
    backgroundColor2: Color(0xFF1B4D3E),
    patternColor: Color(0xFF2C5F4F),
    gridColor: Color(0xFF50C878),
    gridAccentColor: Color(0xFF40E0D0),
    snakeHeadColor: Color(0xFF00D084),
    snakeTailColor: Color(0xFF7FFFD4),
    snakeGlowColor: Color(0x8000D084),
    snakePatternColor: Color(0xFFFFD700),
    foodColor: Color(0xFF7FFFD4),
    foodAccentColor: Color(0xFF00CED1),
    foodGlowColor: Color(0x807FFFD4),
    starColor: Color(0x4050C878),
    moonColor: Color(0xFFE0FFE0),
    themeName: 'Emerald Oasis',
  );

  // Theme 3: Royal Purple (deep purples and gold)
  static const royal = ThemeColors(
    backgroundColor1: Color(0xFF1A0033),
    backgroundColor2: Color(0xFF2E1A47),
    patternColor: Color(0xFF4B0082),
    gridColor: Color(0xFFFFD700),
    gridAccentColor: Color(0xFFDA70D6),
    snakeHeadColor: Color(0xFF9370DB),
    snakeTailColor: Color(0xFFBA55D3),
    snakeGlowColor: Color(0x809370DB),
    snakePatternColor: Color(0xFFFFD700),
    foodColor: Color(0xFFFFD700),
    foodAccentColor: Color(0xFFFFA500),
    foodGlowColor: Color(0x80FFD700),
    starColor: Color(0x40FFD700),
    moonColor: Color(0xFFFFFFE0),
    themeName: 'Royal Purple',
  );

  // Theme 4: Sapphire Night (deep blues and silver)
  static const sapphire = ThemeColors(
    backgroundColor1: Color(0xFF000033),
    backgroundColor2: Color(0xFF001A4D),
    patternColor: Color(0xFF003366),
    gridColor: Color(0xFFC0C0C0),
    gridAccentColor: Color(0xFF4169E1),
    snakeHeadColor: Color(0xFF0F52BA),
    snakeTailColor: Color(0xFF6495ED),
    snakeGlowColor: Color(0x800F52BA),
    snakePatternColor: Color(0xFFE8E8E8),
    foodColor: Color(0xFFE8E8E8),
    foodAccentColor: Color(0xFFC0C0C0),
    foodGlowColor: Color(0x80E8E8E8),
    starColor: Color(0x40C0C0C0),
    moonColor: Color(0xFFFFFFFF),
    themeName: 'Sapphire Night',
  );

  static const List<ThemeColors> themes = [
    midnight,
    sunset,
    oasis,
    royal,
    sapphire,
  ];
}

/// Custom painter for rendering the snake game
class GamePainter extends CustomPainter {
  final GameState gameState;
  final double cellSize;
  final Animation<double>? foodAnimation;
  final double? shimmerAnimation;
  final double? backgroundAnimation;
  final bool treasureCollected;
  final int? collectionFrame;

  GamePainter({
    required this.gameState,
    required this.cellSize,
    this.foodAnimation,
    this.shimmerAnimation,
    this.backgroundAnimation,
    this.treasureCollected = false,
    this.collectionFrame,
  });

  // Get current theme colors based on game state
  ThemeColors get theme => ThemeColors.themes[gameState.currentTheme];

  @override
  void paint(Canvas canvas, Size size) {
    // Draw dynamic background gradient
    _drawDynamicBackground(canvas, size);

    // Draw atmospheric particles and celestial elements
    _drawAtmosphericEffects(canvas, size);

    // Draw Islamic geometric star patterns in background
    _drawIslamicPatterns(canvas, size);

    // Draw ornamental grid with shimmer
    _drawGrid(canvas, size);

    // Draw food (golden treasure)
    if (gameState.food != null) {
      _drawFood(canvas, gameState.food!);
    }

    // Draw serpent trail effect
    _drawSerpentTrail(canvas);

    // Draw snake (desert serpent)
    _drawSnake(canvas);

    // Draw collection burst effect
    if (treasureCollected && collectionFrame != null) {
      _drawCollectionBurst(canvas, size);
    }
  }

  /// Draw dynamic background with shifting gradient
  void _drawDynamicBackground(Canvas canvas, Size size) {
    final bgTime = backgroundAnimation ?? 0.0;

    // Animated gradient with subtle shift
    final gradientShift = sin(bgTime * 0.5) * 0.1;

    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(0, -1.0 + gradientShift),
        end: Alignment(0, 1.0 - gradientShift),
        colors: [theme.backgroundColor1, theme.backgroundColor2],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );
  }

  /// Draw atmospheric effects: stars, crescent moon, dust particles
  void _drawAtmosphericEffects(Canvas canvas, Size size) {
    final bgTime = backgroundAnimation ?? 0.0;

    // Draw twinkling stars
    final starPaint = Paint()
      ..color = theme.starColor
      ..style = PaintingStyle.fill;

    final random = Random(42); // Fixed seed for consistent positions
    for (int i = 0; i < 80; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final twinkle = sin(bgTime * 2 + i * 0.5) * 0.5 + 0.5;
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

    // Draw crescent moon in top right
    final moonCenter = Offset(size.width * 0.85, size.height * 0.15);
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
      ..color = theme.backgroundColor1.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(moonCenter.dx + moonRadius * 0.4, moonCenter.dy - moonRadius * 0.2),
      moonRadius * 0.85,
      shadowPaint,
    );

    // Floating dust particles
    final dustRandom = Random(123);
    for (int i = 0; i < 40; i++) {
      final baseX = dustRandom.nextDouble() * size.width;
      final baseY = dustRandom.nextDouble() * size.height;

      // Floating motion
      final floatOffset = sin(bgTime * 0.5 + i * 0.3) * 10;
      final x = baseX + floatOffset;
      final y = baseY + (bgTime * 5 + i * 3) % size.height;

      final dustPaint = Paint()
        ..color = theme.gridColor.withOpacity(0.05 + sin(bgTime + i) * 0.05);

      canvas.drawCircle(Offset(x, y), 1.0, dustPaint);
    }
  }

  /// Draw Islamic geometric patterns in background
  void _drawIslamicPatterns(Canvas canvas, Size size) {
    final patternPaint = Paint()
      ..color = theme.patternColor
      ..style = PaintingStyle.fill;

    final starPaint = Paint()
      ..color = theme.starColor
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
      ..color = theme.patternColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Diagonal pattern lines creating diamond shapes
    final maxDimension = max(GameState.gridWidth, GameState.gridHeight);
    for (int i = -maxDimension; i < maxDimension * 2; i++) {
      final x1 = i * cellSize * 2;
      final path = Path();
      path.moveTo(x1, 0);
      path.lineTo(x1 + size.height, size.height);
      canvas.drawPath(
        path,
        Paint()
          ..color = theme.patternColor.withOpacity(0.1)
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

  /// Draw ornamental grid with Arabian aesthetic and shimmer
  void _drawGrid(Canvas canvas, Size size) {
    final shimmerTime = shimmerAnimation ?? 0.0;

    // Sand texture shimmer effect on grid cells
    for (int x = 0; x < GameState.gridWidth; x++) {
      for (int y = 0; y < GameState.gridHeight; y++) {
        final cellRect = Rect.fromLTWH(
          x * cellSize,
          y * cellSize,
          cellSize,
          cellSize,
        );

        // Subtle shimmer wave across the grid
        final shimmerPhase = (x + y) * 0.2 + shimmerTime * 2;
        final shimmerIntensity = (sin(shimmerPhase) * 0.5 + 0.5) * 0.03;

        final shimmerPaint = Paint()
          ..color = theme.gridColor.withOpacity(shimmerIntensity)
          ..style = PaintingStyle.fill;

        canvas.drawRect(cellRect, shimmerPaint);
      }
    }

    // Enhanced grid lines with glow
    // Main grid lines
    final mainGridPaint = Paint()
      ..color = theme.gridColor.withOpacity(0.35)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Accent lines (every 5th line) - more prominent
    final accentGridPaint = Paint()
      ..color = theme.gridAccentColor.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Grid line glow effect
    final glowPaint = Paint()
      ..color = theme.gridAccentColor.withOpacity(0.15)
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
      ..style = PaintingStyle.stroke;

    // Vertical lines
    for (int i = 0; i <= GameState.gridWidth; i++) {
      final x = i * cellSize;
      final isAccent = i % 5 == 0;

      // Draw glow for accent lines
      if (isAccent) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), glowPaint);
      }

      final paint = isAccent ? accentGridPaint : mainGridPaint;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (int i = 0; i <= GameState.gridHeight; i++) {
      final y = i * cellSize;
      final isAccent = i % 5 == 0;

      // Draw glow for accent lines
      if (isAccent) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), glowPaint);
      }

      final paint = isAccent ? accentGridPaint : mainGridPaint;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw ripple effects at serpent head
    _drawGridRipple(canvas, size);

    // Draw corner ornaments
    _drawCornerOrnaments(canvas, size);
  }

  /// Draw energy ripple effect at serpent head position
  void _drawGridRipple(Canvas canvas, Size size) {
    if (gameState.snake.isEmpty) return;

    final head = gameState.snake.first;
    final headCenter = Offset(
      head.x * cellSize + cellSize / 2,
      head.y * cellSize + cellSize / 2,
    );

    final shimmerTime = shimmerAnimation ?? 0.0;
    final ripplePhase = (shimmerTime * 3) % 1.0;

    // Draw expanding ripple rings
    for (int i = 0; i < 2; i++) {
      final rippleOffset = i * 0.5;
      final rippleProgress = ((ripplePhase + rippleOffset) % 1.0);
      final rippleRadius = cellSize * (0.5 + rippleProgress * 2);
      final rippleOpacity = (1.0 - rippleProgress) * 0.3;

      final ripplePaint = Paint()
        ..color = theme.snakeHeadColor.withOpacity(rippleOpacity)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(headCenter, rippleRadius, ripplePaint);
    }
  }

  /// Draw decorative corner ornaments
  void _drawCornerOrnaments(Canvas canvas, Size size) {
    final ornamentPaint = Paint()
      ..color = theme.gridColor.withOpacity(0.5)
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

  /// Draw glowing trail effect behind the serpent
  void _drawSerpentTrail(Canvas canvas) {
    if (gameState.snake.length < 2) return;

    final shimmerTime = shimmerAnimation ?? 0.0;

    // Draw trail behind each segment with fade-out effect
    for (int i = 1; i < gameState.snake.length; i++) {
      final segment = gameState.snake[i];
      final center = Offset(
        segment.x * cellSize + cellSize / 2,
        segment.y * cellSize + cellSize / 2,
      );

      // Trail fades from head to tail
      final trailFade = 1.0 - (i / gameState.snake.length);
      final trailRadius = cellSize * 0.6;

      // Animated pulsing trail
      final pulsePhase = shimmerTime * 2 - i * 0.1;
      final pulseIntensity = (sin(pulsePhase) * 0.5 + 0.5) * 0.2;

      final trailPaint = Paint()
        ..color = theme.snakeGlowColor.withOpacity(trailFade * (0.15 + pulseIntensity))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(center, trailRadius, trailPaint);
    }
  }

  /// Draw the desert serpent with Arabian patterns and gradient
  void _drawSnake(Canvas canvas) {
    final shimmerTime = shimmerAnimation ?? 0.0;

    for (int i = 0; i < gameState.snake.length; i++) {
      final segment = gameState.snake[i];
      final rect = Rect.fromLTWH(
        segment.x * cellSize + 1,
        segment.y * cellSize + 1,
        cellSize - 2,
        cellSize - 2,
      );

      // Enhanced gradient position with smoother color transition
      final gradientPosition = i / gameState.snake.length;

      // Multi-color gradient: head -> middle -> tail
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

      // Enhanced multi-layer glow effect
      final glowRect = Rect.fromLTWH(
        segment.x * cellSize - 3,
        segment.y * cellSize - 3,
        cellSize + 6,
        cellSize + 6,
      );

      // Outer glow with pulse
      final pulseAmount = sin(shimmerTime * 3 - i * 0.2) * 0.5 + 0.5;
      final outerGlowPaint = Paint()
        ..color = theme.snakeGlowColor.withOpacity(0.5 * (1 - gradientPosition) * (0.7 + pulseAmount * 0.3))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawRRect(
        RRect.fromRectAndRadius(glowRect, Radius.circular(8)),
        outerGlowPaint,
      );

      // Inner glow
      final innerGlowPaint = Paint()
        ..color = segmentColor.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawRRect(
        RRect.fromRectAndRadius(glowRect, Radius.circular(8)),
        innerGlowPaint,
      );

      // Motion blur effect - draw shadow in direction of movement
      if (i < gameState.snake.length - 1) {
        final nextSegment = gameState.snake[i + 1];
        final dx = segment.x - nextSegment.x;
        final dy = segment.y - nextSegment.y;

        final blurOffset = Offset(dx * cellSize * 0.3, dy * cellSize * 0.3);
        final blurRect = rect.shift(blurOffset);

        final motionBlurPaint = Paint()
          ..color = segmentColor.withOpacity(0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

        canvas.drawRRect(
          RRect.fromRectAndRadius(blurRect, Radius.circular(7)),
          motionBlurPaint,
        );
      }

      // Draw main segment with enhanced gradient
      final segmentPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            Colors.white.withOpacity(0.3),
            segmentColor,
            segmentColor.withOpacity(0.7),
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(rect)
        ..style = PaintingStyle.fill;

      final radius = i == 0 ? 9.0 : 7.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        segmentPaint,
      );

      // Draw subtle Islamic geometric pattern on segments
      if (i % 2 == 0) {
        _drawSegmentPattern(canvas, rect, gradientPosition);
      }

      // Enhanced head decorations
      if (i == 0) {
        final center = rect.center;

        // Animated head glow pulse
        final headPulse = sin(shimmerTime * 4) * 0.5 + 0.5;
        final headGlowPaint = Paint()
          ..color = Colors.white.withOpacity(0.3 + headPulse * 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

        canvas.drawCircle(center, cellSize * 0.4, headGlowPaint);

        // Main highlight
        final highlightPaint = Paint()
          ..color = Colors.white.withOpacity(0.6)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(
            rect.left + rect.width * 0.35,
            rect.top + rect.height * 0.35,
          ),
          cellSize * 0.15,
          highlightPaint,
        );

        // Accent ring on head - animated
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
  }

  /// Draw geometric pattern on snake segment
  void _drawSegmentPattern(Canvas canvas, Rect rect, double fadeAmount) {
    final patternPaint = Paint()
      ..color = theme.snakePatternColor.withOpacity(0.3 * (1 - fadeAmount))
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

  /// Draw golden treasure (food) with Arabian lantern aesthetic and floating effect
  void _drawFood(Canvas canvas, Position food) {
    final pulseValue = foodAnimation?.value ?? 0.5;
    final shimmerTime = shimmerAnimation ?? 0.0;

    // Floating effect - subtle vertical oscillation
    final floatOffset = sin(shimmerTime * 2) * 2;

    final center = Offset(
      food.x * cellSize + cellSize / 2,
      food.y * cellSize + cellSize / 2 + floatOffset,
    );

    final baseRadius = cellSize * 0.35;
    final radius = baseRadius * (0.9 + pulseValue * 0.2);

    // Draw shadow/glow beneath to emphasize floating
    final shadowPaint = Paint()
      ..color = theme.foodColor.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, food.y * cellSize + cellSize / 2 + cellSize * 0.4),
        width: cellSize * 0.6,
        height: cellSize * 0.2,
      ),
      shadowPaint,
    );

    // Magnetic attraction effect to serpent
    _drawMagneticField(canvas, center, radius);

    // Enhanced multi-layer glow
    final outerGlowPaint = Paint()
      ..color = theme.foodGlowColor.withOpacity(0.4 + pulseValue * 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(center, radius * 3.0, outerGlowPaint);

    // Middle glow
    final middleGlowPaint = Paint()
      ..color = theme.foodGlowColor.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(center, radius * 1.8, middleGlowPaint);

    // Inner glow
    final innerGlowPaint = Paint()
      ..color = theme.foodColor.withOpacity(0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(center, radius * 1.2, innerGlowPaint);

    // Draw ornamental frame around treasure (rotating)
    _drawTreasureFrame(canvas, center, radius * 1.8, pulseValue);

    // Main treasure orb with enhanced gradient
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

    // Draw Islamic star pattern on treasure
    _drawTreasureStar(canvas, center, radius * 0.6, pulseValue);

    // Enhanced bright highlight with pulse
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.85 + pulseValue * 0.15)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(
        center.dx - radius * 0.35,
        center.dy - radius * 0.35,
      ),
      radius * 0.28,
      highlightPaint,
    );

    // Secondary highlight
    final secondHighlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(
        center.dx + radius * 0.25,
        center.dy + radius * 0.30,
      ),
      radius * 0.15,
      secondHighlightPaint,
    );

    // Enhanced sparkle particles around treasure
    _drawTreasureSparkles(canvas, center, pulseValue, radius);
  }

  /// Draw subtle magnetic field effect between treasure and serpent
  void _drawMagneticField(Canvas canvas, Offset treasurePos, double treasureRadius) {
    if (gameState.snake.isEmpty) return;

    final head = gameState.snake.first;
    final headCenter = Offset(
      head.x * cellSize + cellSize / 2,
      head.y * cellSize + cellSize / 2,
    );

    final distance = (treasurePos - headCenter).distance;

    // Only show effect when serpent is relatively close
    if (distance < cellSize * 6) {
      final strength = (1.0 - distance / (cellSize * 6)).clamp(0.0, 1.0);

      // Draw subtle energy lines
      final linePaint = Paint()
        ..color = theme.foodColor.withOpacity(strength * 0.15)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      // Draw connecting energy arc
      final path = Path();
      path.moveTo(headCenter.dx, headCenter.dy);

      final controlPoint = Offset(
        (headCenter.dx + treasurePos.dx) / 2 + sin(shimmerAnimation ?? 0) * 10,
        (headCenter.dy + treasurePos.dy) / 2 + cos(shimmerAnimation ?? 0) * 10,
      );

      path.quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        treasurePos.dx,
        treasurePos.dy,
      );

      canvas.drawPath(path, linePaint);

      // Draw pulsing connection points
      final connectionPaint = Paint()
        ..color = theme.foodColor.withOpacity(strength * 0.3);

      canvas.drawCircle(treasurePos, treasureRadius * 1.3, connectionPaint);
    }
  }

  /// Draw ornamental frame around treasure
  void _drawTreasureFrame(Canvas canvas, Offset center, double size, double animation) {
    final framePaint = Paint()
      ..color = theme.foodAccentColor.withOpacity(0.6 + animation * 0.2)
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
      ..color = theme.snakeHeadColor.withOpacity(0.4)
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
      ..color = theme.foodColor.withOpacity(0.8)
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

    // Add subtle trail effect
    final trailPaint = Paint()
      ..color = theme.foodAccentColor.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, baseRadius * (2.0 + animation * 0.5), trailPaint);
  }

  /// Draw explosion burst effect when treasure is collected
  void _drawCollectionBurst(Canvas canvas, Size size) {
    if (gameState.snake.isEmpty || collectionFrame == null) return;

    final head = gameState.snake.first;
    final center = Offset(
      head.x * cellSize + cellSize / 2,
      head.y * cellSize + cellSize / 2,
    );

    final progress = (collectionFrame! / 10.0).clamp(0.0, 1.0);

    // Burst radius expands outward
    final burstRadius = cellSize * progress * 3;

    // Burst wave
    final burstPaint = Paint()
      ..color = theme.foodColor.withOpacity((1 - progress) * 0.6)
      ..strokeWidth = 3.0 * (1 - progress * 0.5)
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, burstRadius, burstPaint);

    // Inner burst wave
    final innerBurstPaint = Paint()
      ..color = theme.foodColor.withOpacity((1 - progress) * 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, burstRadius * 0.6, innerBurstPaint);

    // Expanding glow
    final glowPaint = Paint()
      ..color = theme.foodColor.withOpacity((1 - progress) * 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(center, burstRadius * 0.8, glowPaint);

    // Dust particles explosion
    final random = Random(42);
    for (int i = 0; i < 20; i++) {
      final angle = (i / 20) * pi * 2;
      final particleDistance = burstRadius * 1.2;
      final particlePos = Offset(
        center.dx + cos(angle) * particleDistance,
        center.dy + sin(angle) * particleDistance,
      );

      final particleSize = (3.0 * (1 - progress)) * (0.5 + random.nextDouble() * 0.5);

      final particlePaint = Paint()
        ..color = theme.gridColor.withOpacity((1 - progress) * 0.7);

      canvas.drawCircle(particlePos, particleSize, particlePaint);

      // Particle trail
      final trailPaint = Paint()
        ..color = theme.gridColor.withOpacity((1 - progress) * 0.3)
        ..strokeWidth = particleSize * 0.5
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        center,
        Offset(
          center.dx + cos(angle) * particleDistance * 0.5,
          center.dy + sin(angle) * particleDistance * 0.5,
        ),
        trailPaint,
      );
    }

    // Star burst particles
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * pi * 2 + pi / 8;
      final sparkleDistance = burstRadius * 1.5;
      final sparklePos = Offset(
        center.dx + cos(angle) * sparkleDistance,
        center.dy + sin(angle) * sparkleDistance,
      );

      final sparkleSize = 4.0 * (1 - progress);

      // Draw diamond sparkle
      final sparklePath = Path();
      sparklePath.moveTo(sparklePos.dx, sparklePos.dy - sparkleSize);
      sparklePath.lineTo(sparklePos.dx + sparkleSize * 0.4, sparklePos.dy);
      sparklePath.lineTo(sparklePos.dx, sparklePos.dy + sparkleSize);
      sparklePath.lineTo(sparklePos.dx - sparkleSize * 0.4, sparklePos.dy);
      sparklePath.close();

      final sparklePaint = Paint()
        ..color = Colors.white.withOpacity((1 - progress) * 0.9)
        ..style = PaintingStyle.fill;

      canvas.drawPath(sparklePath, sparklePaint);
    }
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) {
    return oldDelegate.gameState != gameState ||
        oldDelegate.foodAnimation != foodAnimation ||
        oldDelegate.shimmerAnimation != shimmerAnimation ||
        oldDelegate.backgroundAnimation != backgroundAnimation ||
        oldDelegate.treasureCollected != treasureCollected ||
        oldDelegate.collectionFrame != collectionFrame;
  }
}
