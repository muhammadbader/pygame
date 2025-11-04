import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'menu_screen.dart';
import '../utils/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/particle_effects.dart';

/// Game over screen with dramatic presentation and modern design
class GameOverScreen extends StatefulWidget {
  final int score;
  final int foodEaten;

  const GameOverScreen({
    Key? key,
    required this.score,
    required this.foodEaten,
  }) : super(key: key);

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _badgeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _badgeAnimation;
  int? _highScore;
  bool _isNewHighScore = false;

  @override
  void initState() {
    super.initState();

    // Main entrance animation
    _fadeController = AnimationController(
      vsync: this,
      duration: AppTheme.slowAnimation,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutBack,
      ),
    );

    // Badge pulse animation
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _badgeAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _badgeController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeController.forward();
    _checkHighScore();
  }

  Future<void> _checkHighScore() async {
    final currentHighScore = await StorageService.getHighScore();
    final isNew = widget.score > currentHighScore;

    if (isNew) {
      await StorageService.saveHighScore(widget.score);
    }

    setState(() {
      _highScore = isNew ? widget.score : currentHighScore;
      _isNewHighScore = isNew;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  void _playAgain() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const GameScreen(),
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

  void _goToMenu() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MenuScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.1),
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
                starCount: 120,
                color: AppTheme.paleGold,
              ),
            ),

            // Floating particles with slower movement
            const Positioned.fill(
              child: ParticleBackground(
                particleCount: 20,
                colors: [
                  AppTheme.neonGold,
                  AppTheme.turquoise,
                  AppTheme.desertGold,
                ],
                minSize: 2.0,
                maxSize: 4.0,
                speed: 0.5,
              ),
            ),

            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLarge,
                    vertical: AppTheme.spacingXLarge,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Game Over title
                            _buildGameOverTitle(),

                            const SizedBox(height: AppTheme.spacingXXLarge),

                            // Stats
                            _buildStats(),

                            const SizedBox(height: AppTheme.spacingXLarge),

                            // New high score badge
                            if (_isNewHighScore) ...[
                              _buildNewHighScoreBadge(),
                              const SizedBox(height: AppTheme.spacingXLarge),
                            ],

                            // Buttons
                            _buildButton(
                              'PLAY AGAIN',
                              Icons.refresh_rounded,
                              _playAgain,
                            ),

                            const SizedBox(height: AppTheme.spacingMedium),

                            _buildButton(
                              'MENU',
                              Icons.home_rounded,
                              _goToMenu,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverTitle() {
    return Column(
      children: [
        // Mystical crescent moon with glow
        PulsingGlow(
          glowColor: AppTheme.desertGold,
          duration: const Duration(milliseconds: 2000),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.desertGold.withOpacity(0.3),
                  AppTheme.twilightPurple.withOpacity(0.2),
                  AppTheme.deepMidnight.withOpacity(0.1),
                ],
              ),
            ),
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) => AppTheme.goldGradient.createShader(bounds),
                child: const Icon(
                  Icons.nightlight_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingXLarge),

        // Title
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.mysticalGradient.createShader(bounds),
          child: Text(
            'JOURNEY ENDS',
            style: AppTheme.displayLarge.copyWith(
              fontSize: 48,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: AppTheme.desertGold.withOpacity(0.6),
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

        // Subtitle
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.turquoise.withOpacity(0.6),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.turquoise.withOpacity(0.8),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacingMedium),
            ShaderMask(
              shaderCallback: (bounds) => AppTheme.emeraldGradient.createShader(bounds),
              child: Text(
                'The serpent rests beneath the stars',
                style: AppTheme.bodyLarge.copyWith(
                  fontSize: 14,
                  color: Colors.white,
                  letterSpacing: 3,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMedium),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.turquoise.withOpacity(0.6),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.turquoise.withOpacity(0.8),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Column(
      children: [
        // Final score
        StatCard(
          label: 'TREASURES',
          value: widget.score.toString().padLeft(4, '0'),
          icon: Icons.star_rounded,
          gradient: AppTheme.goldGradient,
          glowColor: AppTheme.goldenAmber,
        ),

        const SizedBox(height: AppTheme.spacingMedium),

        // Food eaten
        StatCard(
          label: 'GEMS',
          value: widget.foodEaten.toString().padLeft(2, '0'),
          icon: Icons.diamond_rounded,
          gradient: AppTheme.turquoiseGradient,
          glowColor: AppTheme.turquoise,
        ),

        const SizedBox(height: AppTheme.spacingMedium),

        // High score
        if (_highScore != null)
          StatCard(
            label: 'LEGENDARY',
            value: _highScore.toString().padLeft(4, '0'),
            icon: Icons.emoji_events_rounded,
            gradient: AppTheme.richGoldGradient,
            glowColor: AppTheme.neonGold,
          ),
      ],
    );
  }

  Widget _buildNewHighScoreBadge() {
    return AnimatedBuilder(
      animation: _badgeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _badgeAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLarge,
              vertical: AppTheme.spacingMedium,
            ),
            decoration: BoxDecoration(
              gradient: AppTheme.richGoldGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.goldenAmber.withOpacity(0.6),
                  blurRadius: 35,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: AppTheme.neonGold.withOpacity(0.4),
                  blurRadius: 60,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars_rounded,
                  color: AppTheme.deepMidnight,
                  size: 28,
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Flexible(
                  child: Text(
                    'LEGENDARY ACHIEVEMENT!',
                    style: AppTheme.headlineMedium.copyWith(
                      fontSize: 16,
                      color: AppTheme.deepMidnight,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Icon(
                  Icons.stars_rounded,
                  color: AppTheme.deepMidnight,
                  size: 28,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton(String label, IconData icon, VoidCallback onPressed) {
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
}
