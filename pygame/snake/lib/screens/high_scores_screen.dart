import 'package:flutter/material.dart';
import '../utils/storage_service.dart';

/// High scores screen
class HighScoresScreen extends StatefulWidget {
  const HighScoresScreen({Key? key}) : super(key: key);

  @override
  State<HighScoresScreen> createState() => _HighScoresScreenState();
}

class _HighScoresScreenState extends State<HighScoresScreen> {
  int? _highScore;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
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
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A237E), // Rich indigo
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Color(0xFFD4AF37), // Rich gold
            width: 2.5,
          ),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFD4AF37)],
          ).createShader(bounds),
          child: const Text(
            'Reset Legendary Score?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        content: Text(
          'This will erase your greatest achievement.',
          style: TextStyle(
            color: const Color(0xFF00BCD4).withOpacity(0.9),
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF00BCD4),
            ),
            child: const Text(
              'KEEP IT',
              style: TextStyle(
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF6B6B),
            ),
            child: const Text(
              'RESET',
              style: TextStyle(
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFF00BCD4)],
            ).createShader(bounds),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.stars_rounded,
              color: const Color(0xFFD4AF37).withOpacity(0.8),
              size: 20,
            ),
            const SizedBox(width: 10),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFFFD700),
                  Color(0xFFD4AF37),
                ],
              ).createShader(bounds),
              child: const Text(
                'HALL OF LEGENDS',
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.stars_rounded,
              color: const Color(0xFFD4AF37).withOpacity(0.8),
              size: 20,
            ),
          ],
        ),
        centerTitle: true,
      ),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Arabian ornamental trophy icon
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFD700).withOpacity(0.2),
                      const Color(0xFFD4AF37).withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFD4AF37), // Rich gold
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: const Color(0xFF00BCD4).withOpacity(0.3),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.stars_rounded,
                  size: 70,
                  color: const Color(0xFFFFD700),
                  shadows: [
                    Shadow(
                      color: const Color(0xFFFFD700).withOpacity(0.8),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 55),

              // Arabian-themed high score display
              if (_highScore != null && _highScore! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 45),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.6), // Rich gold
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFD4AF37).withOpacity(0.12),
                        const Color(0xFF00695C).withOpacity(0.08),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 3,
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
                            size: 18,
                            color: const Color(0xFF00BCD4).withOpacity(0.8),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFF00BCD4),
                                  Color(0xFF00695C),
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'LEGENDARY RECORD',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  letterSpacing: 2.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.emoji_events_rounded,
                            size: 18,
                            color: const Color(0xFF00BCD4).withOpacity(0.8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFFFD700),
                            Color(0xFFFFC107),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          _highScore.toString().padLeft(4, '0'),
                          style: const TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFeatures: [FontFeature.tabularFigures()],
                            shadows: [
                              Shadow(
                                color: Color(0xFFFFD700),
                                blurRadius: 25,
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
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      const Color(0xFF00BCD4).withOpacity(0.6),
                      const Color(0xFFD4AF37).withOpacity(0.5),
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    'No legend yet... Begin your journey',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              const SizedBox(height: 65),

              // Arabian-styled clear button
              if (_highScore != null && _highScore! > 0)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withOpacity(0.3),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: TextButton.icon(
                    onPressed: _clearHighScore,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: const Color(0xFF1A237E).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: const Color(0xFFFF6B6B).withOpacity(0.6),
                          width: 2,
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.restart_alt_rounded,
                      color: Color(0xFFFF6B6B),
                      size: 22,
                    ),
                    label: const Text(
                      'Reset Legend',
                      style: TextStyle(
                        color: Color(0xFFFF6B6B),
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
