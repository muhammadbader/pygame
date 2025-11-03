import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'high_scores_screen.dart';
import '../utils/storage_service.dart';

/// Main menu screen
class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  int? _highScore;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
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
    _animationController.dispose();
    super.dispose();
  }

  void _startGame() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
  }

  void _showHighScores() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const HighScoresScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1B2A), // Deep midnight blue
              Color(0xFF1A237E), // Rich indigo
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildTitle(),
                      ),

                      const SizedBox(height: 60),

                      // High score display
                      if (_highScore != null && _highScore! > 0)
                        _buildHighScoreDisplay(),

                      const SizedBox(height: 40),

                      // Menu buttons
                      _buildMenuButton(
                        'PLAY',
                        Icons.play_arrow_rounded,
                        _startGame,
                      ),

                      const SizedBox(height: 20),

                      _buildMenuButton(
                        'HIGH SCORES',
                        Icons.emoji_events_rounded,
                        _showHighScores,
                      ),

                      const SizedBox(height: 60),

                      // Footer
                      _buildFooter(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        // Arabian ornamental icon with 8-pointed star
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFFD4AF37).withOpacity(0.2), // Rich gold
                const Color(0xFF00695C).withOpacity(0.1), // Emerald
              ],
            ),
            border: Border.all(
              color: const Color(0xFFD4AF37), // Rich gold
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: const Color(0xFF00BCD4).withOpacity(0.3), // Turquoise glow
                blurRadius: 50,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.stars_rounded, // 8-pointed star representing Islamic art
            size: 60,
            color: Color(0xFFD4AF37), // Rich gold
          ),
        ),
        const SizedBox(height: 35),
        // Title text with Arabian aesthetic
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFFFFD700), // Golden
              Color(0xFFD4AF37), // Rich gold
              Color(0xFF00BCD4), // Turquoise accent
            ],
            stops: [0.0, 0.6, 1.0],
          ).createShader(bounds),
          child: const Text(
            'DESERT SERPENT',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 58,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 6,
              height: 1.1,
              shadows: [
                Shadow(
                  color: Color(0xFFD4AF37),
                  blurRadius: 25,
                ),
                Shadow(
                  color: Color(0xFF00BCD4),
                  blurRadius: 40,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Ornamental divider
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOrnamentalDivider(),
            const SizedBox(width: 15),
            Icon(
              Icons.circle,
              size: 6,
              color: const Color(0xFFD4AF37).withOpacity(0.6),
            ),
            const SizedBox(width: 15),
            _buildOrnamentalDivider(),
          ],
        ),
        const SizedBox(height: 12),
        // Subtitle with Arabian theme
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF00BCD4), // Turquoise
              Color(0xFF00695C), // Emerald
            ],
          ).createShader(bounds),
          child: const Text(
            'ARABIAN JOURNEY',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrnamentalDivider() {
    return Container(
      width: 40,
      height: 2,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0x00D4AF37),
            Color(0xFFD4AF37),
            Color(0x00D4AF37),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.5),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildHighScoreDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 18),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.6), // Rich gold
          width: 2.5,
        ),
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFD4AF37).withOpacity(0.08), // Gold glow
            const Color(0xFF00695C).withOpacity(0.05), // Emerald tint
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events_rounded,
                size: 16,
                color: const Color(0xFFFFD700).withOpacity(0.8),
              ),
              const SizedBox(width: 8),
              Text(
                'BEST SCORE',
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFFD4AF37).withOpacity(0.9),
                  letterSpacing: 3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.emoji_events_rounded,
                size: 16,
                color: const Color(0xFFFFD700).withOpacity(0.8),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFFFFD700), // Golden
                Color(0xFFFFC107), // Amber
              ],
            ).createShader(bounds),
            child: Text(
              _highScore.toString().padLeft(4, '0'),
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFeatures: [FontFeature.tabularFigures()],
                shadows: [
                  Shadow(
                    color: Color(0xFFFFD700),
                    blurRadius: 15,
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
    return Container(
      width: 300,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFD4AF37).withOpacity(0.1), // Gold tint
            const Color(0xFF00BCD4).withOpacity(0.05), // Turquoise tint
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFFD4AF37), // Rich gold
          side: const BorderSide(
            color: Color(0xFFD4AF37), // Rich gold border
            width: 2.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
          shadowColor: const Color(0xFFD4AF37),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFFFD700), // Golden
                  Color(0xFF00BCD4), // Turquoise
                ],
              ).createShader(bounds),
              child: Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 18),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFFFD700), // Golden
                  Color(0xFFD4AF37), // Rich gold
                ],
              ).createShader(bounds),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Decorative ornament
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star,
              size: 8,
              color: const Color(0xFFD4AF37).withOpacity(0.4),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.circle,
              size: 4,
              color: const Color(0xFF00BCD4).withOpacity(0.3),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.star,
              size: 8,
              color: const Color(0xFFD4AF37).withOpacity(0.4),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              const Color(0xFFD4AF37).withOpacity(0.5),
              const Color(0xFF00BCD4).withOpacity(0.4),
            ],
          ).createShader(bounds),
          child: const Text(
            'Built with Flutter',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }
}
