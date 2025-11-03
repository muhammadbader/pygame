import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'menu_screen.dart';
import '../utils/storage_service.dart';

/// Game over screen with score display and options
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
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int? _highScore;
  bool _isNewHighScore = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
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
    _animationController.dispose();
    super.dispose();
  }

  void _playAgain() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
  }

  void _goToMenu() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MenuScreen()),
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
              Color(0xFF0D1B2A), // Back to deep blue
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Game Over text
                    _buildGameOverTitle(),

                    const SizedBox(height: 60),

                    // Stats
                    _buildStats(),

                    const SizedBox(height: 40),

                    // New high score badge
                    if (_isNewHighScore) _buildNewHighScoreBadge(),

                    if (_isNewHighScore) const SizedBox(height: 40),

                    // Buttons
                    _buildButton(
                      'PLAY AGAIN',
                      Icons.refresh_rounded,
                      _playAgain,
                      const Color(0xFF00FFFF),
                    ),

                    const SizedBox(height: 20),

                    _buildButton(
                      'MENU',
                      Icons.home_rounded,
                      _goToMenu,
                      const Color(0xFF00FFFF),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverTitle() {
    return Column(
      children: [
        // Ornamental icon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: Icon(
            Icons.nightlight_rounded,
            size: 40,
            color: const Color(0xFFD4AF37).withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 25),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFFD4AF37), // Rich gold
              Color(0xFF00BCD4), // Turquoise
              Color(0xFFD4AF37), // Rich gold
            ],
            stops: [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: const Text(
            'JOURNEY ENDS',
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 5,
              shadows: [
                Shadow(
                  color: Color(0xFFD4AF37),
                  blurRadius: 25,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star,
              size: 8,
              color: const Color(0xFF00BCD4).withOpacity(0.6),
            ),
            const SizedBox(width: 10),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  const Color(0xFF00BCD4).withOpacity(0.8),
                  const Color(0xFF00695C).withOpacity(0.8),
                ],
              ).createShader(bounds),
              child: const Text(
                'The serpent rests',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.star,
              size: 8,
              color: const Color(0xFF00BCD4).withOpacity(0.6),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.5), // Rich gold
          width: 2.5,
        ),
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFD4AF37).withOpacity(0.1), // Gold tint
            const Color(0xFF00695C).withOpacity(0.05), // Emerald tint
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            blurRadius: 25,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Final score
          _buildStatRow(
            'TREASURES COLLECTED',
            widget.score.toString().padLeft(4, '0'),
            Icons.star_rounded,
            [const Color(0xFFFFD700), const Color(0xFFD4AF37)], // Golden gradient
          ),

          const SizedBox(height: 30),

          // Food eaten
          _buildStatRow(
            'GEMS GATHERED',
            widget.foodEaten.toString(),
            Icons.diamond_rounded,
            [const Color(0xFF00BCD4), const Color(0xFF00695C)], // Turquoise-Emerald
          ),

          const SizedBox(height: 30),

          // High score
          if (_highScore != null)
            _buildStatRow(
              'LEGENDARY SCORE',
              _highScore.toString().padLeft(4, '0'),
              Icons.emoji_events_rounded,
              [const Color(0xFFFFC107), const Color(0xFFFFD700)], // Amber-Gold
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, List<Color> gradientColors) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: gradientColors,
              ).createShader(bounds),
              child: Icon(
                icon,
                size: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  gradientColors[0].withOpacity(0.8),
                  gradientColors[1].withOpacity(0.8),
                ],
              ).createShader(bounds),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: gradientColors,
          ).createShader(bounds),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
              shadows: [
                Shadow(
                  color: Color(0xFFD4AF37),
                  blurRadius: 15,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewHighScoreBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFD700), // Golden
            Color(0xFFFFC107), // Amber
            Color(0xFFFFD700), // Golden
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.6),
            blurRadius: 30,
            spreadRadius: 3,
          ),
          BoxShadow(
            color: const Color(0xFFFFC107).withOpacity(0.4),
            blurRadius: 50,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.stars_rounded,
            color: Color(0xFF1A237E),
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'LEGENDARY ACHIEVEMENT!',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.stars_rounded,
            color: Color(0xFF1A237E),
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      String label, IconData icon, VoidCallback onPressed, Color color) {
    return Container(
      width: 300,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFD4AF37).withOpacity(0.1),
            const Color(0xFF00BCD4).withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            blurRadius: 15,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFFD4AF37),
          side: const BorderSide(
            color: Color(0xFFD4AF37),
            width: 2.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFFFD700),
                  Color(0xFF00BCD4),
                ],
              ).createShader(bounds),
              child: Icon(
                icon,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 18),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFFFD700),
                  Color(0xFFD4AF37),
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
}
