import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/menu_screen.dart';
import 'utils/app_theme.dart';

/// Desert Serpent: Arabian Journey
/// A modern reimagining of the classic snake game with mystical Arabian aesthetics
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for mobile
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Hide system UI overlays for immersive experience
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const SnakeGameApp());
}

class SnakeGameApp extends StatelessWidget {
  const SnakeGameApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desert Serpent: Arabian Journey',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MenuScreen(),
    );
  }
}
