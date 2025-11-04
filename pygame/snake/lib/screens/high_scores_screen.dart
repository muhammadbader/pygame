import 'package:flutter/material.dart';
import '../utils/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/particle_effects.dart';

/// High scores screen with iconic modern design
class HighScoresScreen extends StatefulWidget {
  const HighScoresScreen({Key? key}) : super(key: key);

  @override
  State<HighScoresScreen> createState() => _HighScoresScreenState();
}

class _HighScoresScreenState extends State<HighScoresScreen>
    with SingleTickerProviderStateMixin {
  int? _highScore;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadHighScore();

    // Pulse animation for trophy
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadHighScore() async {
    final score = await StorageService.getHighScore();
    setState(() {
      _highScore = score;
    });
  }

  Future<void> _clearHighScore() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.richIndigo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          side: BorderSide(
            color: AppTheme.desertGold.withOpacity(0.6),
            width: 2.5,
          ),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => AppTheme.goldGradient.createShader(bounds),
          child: Text(
            'Reset Legendary Score?',
            style: AppTheme.headlineMedium.copyWith(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        content: Text(
          'This will erase your greatest achievement from the sands of time.',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.turquoise.withOpacity(0.9),
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.turquoise,
            ),
            child: Text(
              'KEEP IT',
              style: AppTheme.labelLarge.copyWith(
                color: AppTheme.turquoise,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF6B6B),
            ),
            child: Text(
              'RESET',
              style: AppTheme.labelLarge.copyWith(
                color: const Color(0xFFFF6B6B),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.clearHighScore();
      _loadHighScore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(AppTheme.spacingSmall),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.glassLight,
            ),
            child: ShaderMask(
              shaderCallback: (bounds) => AppTheme.mysticalGradient.createShader(bounds),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.stars_rounded,
              color: AppTheme.desertGold.withOpacity(0.9),
              size: 20,
            ),
            const SizedBox(width: AppTheme.spacingSmall),
            Flexible(
              child: ShaderMask(
                shaderCallback: (bounds) => AppTheme.richGoldGradient.createShader(bounds),
                child: Text(
                  'HALL OF LEGENDS',
                  style: AppTheme.headlineMedium.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSmall),
            Icon(
              Icons.stars_rounded,
              color: AppTheme.desertGold.withOpacity(0.9),
              size: 20,
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Star constellation background
            const Positioned.fill(
              child: StarConstellation(
                starCount: 180,
                color: AppTheme.paleGold,
              ),
            ),

            // Floating particles
            const Positioned.fill(
              child: ParticleBackground(
                particleCount: 25,
                colors: [
                  AppTheme.neonGold,
                  AppTheme.turquoise,
                  AppTheme.desertGold,
                ],
                minSize: 2.0,
                maxSize: 4.0,
                speed: 0.6,
              ),
            ),

            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLarge,
                    vertical: AppTheme.spacingXXLarge,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Legendary trophy icon with pulse animation
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: PulsingGlow(
                              glowColor: AppTheme.neonGold,
                              duration: const Duration(milliseconds: 2000),
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppTheme.goldenAmber.withOpacity(0.3),
                                      AppTheme.desertGold.withOpacity(0.2),
                                      AppTheme.deepMidnight.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => AppTheme.richGoldGradient.createShader(bounds),
                                    child: const Icon(
                                      Icons.emoji_events_rounded,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: AppTheme.spacingXXLarge),

                      // High score display
                      if (_highScore != null && _highScore! > 0)
                        GlowingGlassContainer(
                          width: 320,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingXXLarge,
                            vertical: AppTheme.spacingXLarge,
                          ),
                          borderRadius: AppTheme.radiusXLarge,
                          glowColor: AppTheme.goldenAmber,
                          glowIntensity: 1.0,
                          child: Column(
                            children: [
                              // Label
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.stars_rounded,
                                    size: 20,
                                    color: AppTheme.turquoise.withOpacity(0.9),
                                  ),
                                  const SizedBox(width: AppTheme.spacingSmall),
                                  Flexible(
                                    child: ShaderMask(
                                      shaderCallback: (bounds) => AppTheme.emeraldGradient.createShader(bounds),
                                      child: Text(
                                        'LEGENDARY RECORD',
                                        style: AppTheme.labelLarge.copyWith(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spacingSmall),
                                  Icon(
                                    Icons.stars_rounded,
                                    size: 20,
                                    color: AppTheme.turquoise.withOpacity(0.9),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spacingLarge),

                              // Score value
                              ShaderMask(
                                shaderCallback: (bounds) => AppTheme.richGoldGradient.createShader(bounds),
                                child: Text(
                                  _highScore.toString().padLeft(4, '0'),
                                  style: AppTheme.displayLarge.copyWith(
                                    fontSize: 88,
                                    color: Colors.white,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                    shadows: [
                                      Shadow(
                                        color: AppTheme.goldenAmber,
                                        blurRadius: 30,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ShaderMask(
                          shaderCallback: (bounds) => AppTheme.emeraldGradient.createShader(bounds),
                          child: Text(
                            'No legend yet... Begin your journey',
                            textAlign: TextAlign.center,
                            style: AppTheme.bodyLarge.copyWith(
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),

                      const SizedBox(height: AppTheme.spacingXXLarge),

                      // Reset button
                      if (_highScore != null && _highScore! > 0)
                        GlassContainer(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingLarge,
                            vertical: AppTheme.spacingMedium,
                          ),
                          borderRadius: AppTheme.radiusMedium,
                          borderColor: const Color(0xFFFF6B6B).withOpacity(0.5),
                          shadows: [
                            BoxShadow(
                              color: const Color(0xFFFF6B6B).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _clearHighScore,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.restart_alt_rounded,
                                    color: Color(0xFFFF6B6B),
                                    size: 22,
                                  ),
                                  const SizedBox(width: AppTheme.spacingSmall),
                                  Text(
                                    'Reset Legend',
                                    style: AppTheme.labelLarge.copyWith(
                                      color: const Color(0xFFFF6B6B),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
