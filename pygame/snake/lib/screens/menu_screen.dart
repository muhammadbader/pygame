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
              Color(0xFF000000),
              Color(0xFF001a1a),
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
        // Snake emoji/icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF00FFFF).withOpacity(0.1),
            border: Border.all(
              color: const Color(0xFF00FFFF),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFFF).withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.grid_4x4_rounded,
            size: 50,
            color: Color(0xFF00FFFF),
          ),
        ),
        const SizedBox(height: 30),
        // Title text
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF00FFFF),
              Color(0xFF00CCCC),
            ],
          ).createShader(bounds),
          child: const Text(
            'SNAKE',
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 8,
              shadows: [
                Shadow(
                  color: Color(0xFF00FFFF),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'RETRO EDITION',
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF00FFFF).withOpacity(0.6),
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildHighScoreDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFFF00FF).withOpacity(0.5),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFFF00FF).withOpacity(0.05),
      ),
      child: Column(
        children: [
          Text(
            'HIGH SCORE',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFFFF00FF).withOpacity(0.7),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _highScore.toString().padLeft(4, '0'),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF00FF),
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String label, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 280,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF00FFFF),
          side: const BorderSide(
            color: Color(0xFF00FFFF),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          shadowColor: const Color(0xFF00FFFF),
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

  Widget _buildFooter() {
    return Text(
      'Built with Flutter',
      style: TextStyle(
        fontSize: 12,
        color: Colors.cyan.withOpacity(0.3),
        letterSpacing: 1,
      ),
    );
  }
}
