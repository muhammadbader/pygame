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
              Color(0xFF000000),
              Color(0xFF1a0000),
            ],
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
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFFFF0000),
              Color(0xFFFF00FF),
            ],
          ).createShader(bounds),
          child: const Text(
            'GAME OVER',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 4,
              shadows: [
                Shadow(
                  color: Color(0xFFFF00FF),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Better luck next time',
          style: TextStyle(
            fontSize: 16,
            color: Colors.red.withOpacity(0.6),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF00FFFF).withOpacity(0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(15),
        color: const Color(0xFF00FFFF).withOpacity(0.05),
      ),
      child: Column(
        children: [
          // Score
          _buildStatRow('FINAL SCORE', widget.score.toString().padLeft(4, '0'),
              const Color(0xFF00FFFF)),

          const SizedBox(height: 25),

          // Food eaten
          _buildStatRow('FOOD EATEN', widget.foodEaten.toString(),
              const Color(0xFFFF00FF)),

          const SizedBox(height: 25),

          // High score
          if (_highScore != null)
            _buildStatRow(
              'HIGH SCORE',
              _highScore.toString().padLeft(4, '0'),
              const Color(0xFFFFFF00),
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.6),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildNewHighScoreBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFD700),
            Color(0xFFFFA500),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.emoji_events_rounded,
            color: Colors.black,
            size: 24,
          ),
          SizedBox(width: 10),
          Text(
            'NEW HIGH SCORE!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      String label, IconData icon, VoidCallback onPressed, Color color) {
    return SizedBox(
      width: 280,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: color,
          side: BorderSide(
            color: color,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 15),
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
