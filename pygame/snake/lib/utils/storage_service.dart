import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting game data (high scores)
class StorageService {
  static const String _highScoreKey = 'high_score';

  /// Get the current high score
  static Future<int> getHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_highScoreKey) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Save a new high score
  static Future<void> saveHighScore(int score) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_highScoreKey, score);
    } catch (e) {
      // Fail silently
    }
  }

  /// Clear the high score
  static Future<void> clearHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_highScoreKey);
    } catch (e) {
      // Fail silently
    }
  }
}
