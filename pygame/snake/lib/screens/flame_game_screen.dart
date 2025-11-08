import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/snake_game.dart';
import 'game_over_screen.dart';

/// Flame-powered game screen with enhanced effects
class FlameGameScreen extends StatefulWidget {
  const FlameGameScreen({Key? key}) : super(key: key);

  @override
  State<FlameGameScreen> createState() => _FlameGameScreenState();
}

class _FlameGameScreenState extends State<FlameGameScreen> {
  late SnakeFlameGame _game;
  int _score = 0;
  int _length = 3;

  @override
  void initState() {
    super.initState();

    _game = SnakeFlameGame()
      ..onGameOver = _handleGameOver
      ..onScoreUpdate = _handleScoreUpdate;
  }

  void _handleGameOver(int score, int foodEaten) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GameOverScreen(
            score: score,
            foodEaten: foodEaten,
          ),
        ),
      );
    });
  }

  void _handleScoreUpdate(int score, int length) {
    if (mounted) {
      setState(() {
        _score = score;
        _length = length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Flame game
          GameWidget(
            game: _game,
          ),

          // HUD overlay
          SafeArea(
            child: _buildHUD(),
          ),

          // Controls hint
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: _buildControlsHint(),
          ),
        ],
      ),
    );
  }

  Widget _buildHUD() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BCD4).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHUDItem(
            label: 'TREASURES',
            value: _score.toString().padLeft(4, '0'),
            icon: Icons.star_rounded,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.5),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD4AF37).withOpacity(0.15),
                  const Color(0xFF00BCD4).withOpacity(0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.stars_rounded,
              size: 24,
              color: const Color(0xFFD4AF37).withOpacity(0.9),
            ),
          ),
          _buildHUDItem(
            label: 'SERPENT',
            value: _length.toString().padLeft(3, '0'),
            icon: Icons.trending_up_rounded,
            align: CrossAxisAlignment.end,
          ),
        ],
      ),
    );
  }

  Widget _buildHUDItem({
    required String label,
    required String value,
    required IconData icon,
    CrossAxisAlignment align = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: const Color(0xFF00BCD4).withOpacity(0.7),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: const Color(0xFF00BCD4).withOpacity(0.8),
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFFFFD700),
              Color(0xFFD4AF37),
            ],
          ).createShader(bounds),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
              shadows: [
                Shadow(
                  color: Color(0xFFFFD700),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlsHint() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.swipe_rounded,
            size: 16,
            color: const Color(0xFF00BCD4).withOpacity(0.5),
          ),
          const SizedBox(width: 8),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                const Color(0xFF00BCD4).withOpacity(0.6),
                const Color(0xFFD4AF37).withOpacity(0.5),
              ],
            ).createShader(bounds),
            child: const Text(
              'Swipe to guide the serpent',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
