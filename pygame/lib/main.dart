import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/menu_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for mobile
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SnakeGameApp());
}

class SnakeGameApp extends StatelessWidget {
  const SnakeGameApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        primaryColor: const Color(0xFF00FFFF), // Cyan
        fontFamily: 'Courier',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00FFFF),
            letterSpacing: 2,
          ),
          displayMedium: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00FFFF),
          ),
          bodyLarge: TextStyle(
            fontSize: 24,
            color: Color(0xFF00FFFF),
          ),
          bodyMedium: TextStyle(
            fontSize: 18,
            color: Color(0xFF00FFFF),
          ),
        ),
      ),
      home: const MenuScreen(),
    );
  }
}
