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
        backgroundColor: const Color(0xFF0a0a0a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(
            color: Color(0xFF00FFFF),
            width: 2,
          ),
        ),
        title: const Text(
          'Clear High Score?',
          style: TextStyle(color: Color(0xFF00FFFF)),
        ),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('CLEAR'),
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00FFFF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'HIGH SCORES',
          style: TextStyle(
            color: Color(0xFF00FFFF),
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Trophy icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFD700),
                    width: 3,
                  ),
                  color: const Color(0xFFFFD700).withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  size: 60,
                  color: Color(0xFFFFD700),
                ),
              ),

              const SizedBox(height: 50),

              // High score display
              if (_highScore != null && _highScore! > 0)
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF00FFFF).withOpacity(0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF00FFFF).withOpacity(0.05),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'BEST SCORE',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF00FFFF).withOpacity(0.6),
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        _highScore.toString().padLeft(4, '0'),
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00FFFF),
                          fontFeatures: [FontFeature.tabularFigures()],
                          shadows: [
                            Shadow(
                              color: Color(0xFF00FFFF),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  'No high score yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.cyan.withOpacity(0.5),
                  ),
                ),

              const SizedBox(height: 60),

              // Clear button
              if (_highScore != null && _highScore! > 0)
                TextButton.icon(
                  onPressed: _clearHighScore,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'Clear High Score',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
