import 'package:flutter/material.dart';
import 'dart:ui';

/// Modern Desert Serpent Theme
/// Inspired by Journey, Monument Valley, and Arabian mysticism
class AppTheme {
  // ============================================
  // MODERN COLOR PALETTE
  // ============================================

  // Deep Mystical Blues
  static const deepMidnight = Color(0xFF0A0E1A);
  static const richIndigo = Color(0xFF1A1F3A);
  static const mysticBlue = Color(0xFF0D1B2A);
  static const twilightPurple = Color(0xFF2D1B3D);

  // Desert Golds
  static const desertGold = Color(0xFFD4AF37);
  static const goldenAmber = Color(0xFFFFD700);
  static const paleGold = Color(0xFFF5E6CC);
  static const bronzeGold = Color(0xFFCD7F32);

  // Vibrant Accents
  static const turquoise = Color(0xFF00BCD4);
  static const deepTurquoise = Color(0xFF00838F);
  static const emeraldGreen = Color(0xFF00695C);
  static const mintGreen = Color(0xFF4ECDC4);

  // Neon Glows
  static const neonGold = Color(0xFFFFE55C);
  static const neonTurquoise = Color(0xFF5CFFE5);
  static const neonPurple = Color(0xFFB967FF);

  // Glassmorphic Overlays
  static const glassLight = Color(0x1AFFFFFF);
  static const glassMedium = Color(0x33FFFFFF);
  static const glassDark = Color(0x0DFFFFFF);

  // ============================================
  // GRADIENTS
  // ============================================

  // Background Gradients
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      deepMidnight,
      richIndigo,
      mysticBlue,
      twilightPurple,
    ],
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  static const subtleBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0A0E1A),
      Color(0xFF0D1B2A),
    ],
  );

  // Gold Gradients
  static const goldGradient = LinearGradient(
    colors: [
      goldenAmber,
      desertGold,
      bronzeGold,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const richGoldGradient = LinearGradient(
    colors: [
      neonGold,
      goldenAmber,
      desertGold,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Turquoise Gradients
  static const turquoiseGradient = LinearGradient(
    colors: [
      neonTurquoise,
      turquoise,
      deepTurquoise,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const emeraldGradient = LinearGradient(
    colors: [
      mintGreen,
      turquoise,
      emeraldGreen,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Mystical Gradients
  static const mysticalGradient = LinearGradient(
    colors: [
      neonPurple,
      deepTurquoise,
      desertGold,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass Gradients
  static const glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      glassMedium,
      glassLight,
      glassDark,
    ],
  );

  // ============================================
  // SHADOWS & GLOWS
  // ============================================

  static List<BoxShadow> goldGlow({double intensity = 1.0}) => [
    BoxShadow(
      color: goldenAmber.withOpacity(0.3 * intensity),
      blurRadius: 20 * intensity,
      spreadRadius: 2 * intensity,
    ),
    BoxShadow(
      color: desertGold.withOpacity(0.2 * intensity),
      blurRadius: 40 * intensity,
      spreadRadius: 4 * intensity,
    ),
  ];

  static List<BoxShadow> turquoiseGlow({double intensity = 1.0}) => [
    BoxShadow(
      color: turquoise.withOpacity(0.4 * intensity),
      blurRadius: 20 * intensity,
      spreadRadius: 2 * intensity,
    ),
    BoxShadow(
      color: neonTurquoise.withOpacity(0.2 * intensity),
      blurRadius: 40 * intensity,
      spreadRadius: 4 * intensity,
    ),
  ];

  static List<BoxShadow> mysticalGlow({double intensity = 1.0}) => [
    BoxShadow(
      color: neonPurple.withOpacity(0.3 * intensity),
      blurRadius: 25 * intensity,
      spreadRadius: 2 * intensity,
    ),
    BoxShadow(
      color: turquoise.withOpacity(0.2 * intensity),
      blurRadius: 45 * intensity,
      spreadRadius: 4 * intensity,
    ),
  ];

  static List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: Colors.white.withOpacity(0.05),
      blurRadius: 10,
      spreadRadius: 0,
      offset: const Offset(0, -5),
    ),
  ];

  // ============================================
  // TYPOGRAPHY
  // ============================================

  static const String primaryFont = 'Poppins'; // Modern sans-serif
  static const String displayFont = 'Orbitron'; // Futuristic display

  static TextStyle displayLarge = const TextStyle(
    fontSize: 72,
    fontWeight: FontWeight.w800,
    letterSpacing: 6,
    height: 1.0,
  );

  static TextStyle displayMedium = const TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: 4,
    height: 1.1,
  );

  static TextStyle displaySmall = const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 3,
    height: 1.2,
  );

  static TextStyle headlineLarge = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 2,
    height: 1.3,
  );

  static TextStyle headlineMedium = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.3,
  );

  static TextStyle bodyLarge = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 1,
    height: 1.5,
  );

  static TextStyle bodyMedium = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static TextStyle labelLarge = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 2,
    height: 1.2,
  );

  // ============================================
  // ANIMATION DURATIONS
  // ============================================

  static const Duration veryFastAnimation = Duration(milliseconds: 150);
  static const Duration fastAnimation = Duration(milliseconds: 300);
  static const Duration normalAnimation = Duration(milliseconds: 500);
  static const Duration slowAnimation = Duration(milliseconds: 800);
  static const Duration verySlowAnimation = Duration(milliseconds: 1200);

  // ============================================
  // BORDER RADIUS
  // ============================================

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;

  // ============================================
  // SPACING
  // ============================================

  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;

  // ============================================
  // BLUR & OPACITY
  // ============================================

  static const double glassBlur = 10.0;
  static const double glassOpacity = 0.1;
  static const double glassStrongOpacity = 0.15;

  // ============================================
  // MATERIAL THEME
  // ============================================

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepMidnight,
      primaryColor: desertGold,
      fontFamily: primaryFont,

      colorScheme: const ColorScheme.dark(
        primary: desertGold,
        secondary: turquoise,
        tertiary: emeraldGreen,
        surface: richIndigo,
        background: deepMidnight,
        onPrimary: deepMidnight,
        onSecondary: deepMidnight,
        onSurface: paleGold,
        onBackground: paleGold,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: desertGold),
        titleTextStyle: TextStyle(
          color: desertGold,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 3,
          fontFamily: primaryFont,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: desertGold,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingXLarge,
            vertical: spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
            side: const BorderSide(
              color: desertGold,
              width: 2.5,
            ),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: turquoise,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Creates a shader mask for gradient text
  static Widget gradientText(
    String text,
    TextStyle style,
    Gradient gradient,
  ) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }

  /// Creates a pulsing animation value
  static double getPulseValue(Animation<double> animation) {
    return 0.9 + (animation.value * 0.2);
  }

  /// Creates a breathing animation value (slower pulse)
  static double getBreathingValue(Animation<double> animation) {
    return 0.95 + (animation.value * 0.1);
  }
}
