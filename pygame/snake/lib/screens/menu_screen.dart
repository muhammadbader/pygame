import 'package:flutter/material.dart';
import 'flame_game_screen.dart';
import 'high_scores_screen.dart';
import '../utils/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/particle_effects.dart';

/// Main menu screen with modern minimalist design
class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _breathingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _breathingAnimation;
  int? _highScore;

  @override
  void initState() {
    super.initState();

    // Main entrance animation
    _fadeController = AnimationController(
      vsync: this,
      duration: AppTheme.verySlowAnimation,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Breathing animation for icon
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeController.forward();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final score = await StorageService.getHighScore();
    setState(() {
      _highScore = score;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  void _startGame() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const FlameGameScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: AppTheme.normalAnimation,
      ),
    );
  }

  void _showHighScores() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HighScoresScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
        transitionDuration: AppTheme.normalAnimation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Star constellation background
            const Positioned.fill(
              child: StarConstellation(
                starCount: 150,
                color: AppTheme.paleGold,
              ),
            ),

            // Floating particles
            const Positioned.fill(
              child: ParticleBackground(
                particleCount: 30,
                colors: [
                  AppTheme.neonGold,
                  AppTheme.turquoise,
                  AppTheme.desertGold,
                ],
                minSize: 2.0,
                maxSize: 5.0,
                speed: 0.8,
              ),
            ),

            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: AnimatedBuilder(
                    animation: _fadeController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingLarge,
                              vertical: AppTheme.spacingXLarge,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Title
                                _buildTitle(),

                                const SizedBox(height: AppTheme.spacingXXLarge),

                                // High score display
                                if (_highScore != null && _highScore! > 0) ...[
                                  _buildHighScoreDisplay(),
                                  const SizedBox(height: AppTheme.spacingXLarge),
                                ],

                                // Menu buttons
                                _buildMenuButton(
                                  'PLAY',
                                  Icons.play_arrow_rounded,
                                  _startGame,
                                ),

                                const SizedBox(height: AppTheme.spacingMedium),

                                _buildMenuButton(
                                  'HIGH SCORES',
                                  Icons.emoji_events_rounded,
                                  _showHighScores,
                                ),

                                const SizedBox(height: AppTheme.spacingXXLarge),

                                // Footer
                                _buildFooter(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        // Mystical serpent icon with breathing animation
        AnimatedBuilder(
          animation: _breathingAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _breathingAnimation.value,
              child: PulsingGlow(
                glowColor: AppTheme.neonGold,
                duration: const Duration(milliseconds: 2500),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.goldenAmber.withOpacity(0.3),
                        AppTheme.desertGold.withOpacity(0.2),
                        AppTheme.deepMidnight.withOpacity(0.1),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => AppTheme.mysticalGradient.createShader(bounds),
                      child: const Icon(
                        Icons.stars_rounded,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppTheme.spacingXLarge),

        // Title text with modern typography
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.richGoldGradient.createShader(bounds),
          child: Text(
            'DESERT SERPENT',
            textAlign: TextAlign.center,
            style: AppTheme.displayLarge.copyWith(
              fontSize: 52,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: AppTheme.goldenAmber.withOpacity(0.6),
                  blurRadius: 30,
                ),
                Shadow(
                  color: AppTheme.turquoise.withOpacity(0.4),
                  blurRadius: 50,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingMedium),

        // Modern ornamental divider
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildModernDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.goldGradient,
                  boxShadow: AppTheme.goldGlow(intensity: 0.8),
                ),
              ),
            ),
            _buildModernDivider(),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMedium),

        // Subtitle with elegant typography
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.turquoiseGradient.createShader(bounds),
          child: Text(
            'ARABIAN JOURNEY',
            style: AppTheme.labelLarge.copyWith(
              fontSize: 15,
              color: Colors.white,
              letterSpacing: 6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDivider() {
    return Container(
      width: 50,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.desertGold.withOpacity(0.0),
            AppTheme.desertGold.withOpacity(0.8),
            AppTheme.desertGold.withOpacity(0.0),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.desertGold.withOpacity(0.6),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildHighScoreDisplay() {
    return GlowingGlassContainer(
      width: 280,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingXLarge,
        vertical: AppTheme.spacingLarge,
      ),
      borderRadius: AppTheme.radiusLarge,
      glowColor: AppTheme.goldenAmber,
      glowIntensity: 0.8,
      child: Column(
        children: [
          // Label
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events_rounded,
                size: 18,
                color: AppTheme.neonGold.withOpacity(0.9),
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              Text(
                'LEGENDARY SCORE',
                style: AppTheme.labelLarge.copyWith(
                  color: AppTheme.desertGold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              Icon(
                Icons.emoji_events_rounded,
                size: 18,
                color: AppTheme.neonGold.withOpacity(0.9),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // Score value
          ShaderMask(
            shaderCallback: (bounds) => AppTheme.richGoldGradient.createShader(bounds),
            child: Text(
              _highScore.toString().padLeft(4, '0'),
              style: AppTheme.displayMedium.copyWith(
                fontSize: 48,
                color: Colors.white,
                fontFeatures: const [FontFeature.tabularFigures()],
                shadows: [
                  Shadow(
                    color: AppTheme.goldenAmber,
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String label, IconData icon, VoidCallback onPressed) {
    return GlassContainer(
      width: 300,
      height: 70,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      borderRadius: AppTheme.radiusLarge,
      borderColor: AppTheme.desertGold.withOpacity(0.4),
      borderWidth: 2,
      shadows: AppTheme.goldGlow(intensity: 0.6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          splashColor: AppTheme.goldenAmber.withOpacity(0.2),
          highlightColor: AppTheme.desertGold.withOpacity(0.1),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => AppTheme.goldGradient.createShader(bounds),
                  child: Icon(
                    icon,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                ShaderMask(
                  shaderCallback: (bounds) => AppTheme.richGoldGradient.createShader(bounds),
                  child: Text(
                    label,
                    style: AppTheme.headlineMedium.copyWith(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Modern ornamental divider
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.desertGold.withOpacity(0.4),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.desertGold.withOpacity(0.6),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacingMedium),
            Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.turquoise.withOpacity(0.3),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMedium),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.desertGold.withOpacity(0.4),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.desertGold.withOpacity(0.6),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              AppTheme.desertGold.withOpacity(0.4),
              AppTheme.turquoise.withOpacity(0.3),
            ],
          ).createShader(bounds),
          child: Text(
            'A Journey Through the Sands',
            style: AppTheme.bodyMedium.copyWith(
              fontSize: 11,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }
}
