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
      title: 'Desert Serpent - Arabian Journey',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1B2A), // Deep midnight blue
        primaryColor: const Color(0xFFD4AF37), // Rich gold
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37), // Rich gold
          secondary: Color(0xFF00BCD4), // Turquoise
          tertiary: Color(0xFF00695C), // Emerald
          surface: Color(0xFF1A237E), // Rich indigo
          background: Color(0xFF0D1B2A), // Deep midnight blue
          onPrimary: Color(0xFF1A237E), // Dark text on gold
          onSecondary: Colors.white,
          onSurface: Color(0xFFD4AF37), // Gold text on surfaces
          onBackground: Color(0xFFD4AF37), // Gold text on background
        ),
        fontFamily: 'Courier', // Monospace font for retro-modern feel
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4AF37), // Rich gold
            letterSpacing: 4,
            shadows: [
              Shadow(
                color: Color(0xFFFFD700),
                blurRadius: 20,
              ),
            ],
          ),
          displayMedium: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFD700), // Golden
            letterSpacing: 3,
          ),
          bodyLarge: TextStyle(
            fontSize: 24,
            color: Color(0xFF00BCD4), // Turquoise
            letterSpacing: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 18,
            color: Color(0xFF00BCD4), // Turquoise
            letterSpacing: 1,
          ),
        ),
        // Additional theme customizations for Arabian aesthetic
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Color(0xFFD4AF37), // Rich gold
          ),
          titleTextStyle: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
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
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF00BCD4), // Turquoise
          ),
        ),
      ),
      home: const MenuScreen(),
    );
  }
}
