# Snake Game - Retro Edition

A classic 2D Snake game built with Flutter, featuring a retro-future aesthetic with neon colors and smooth animations.

## Features

- **Cross-platform**: Runs on iOS, Android, and Web (PWA)
- **Smooth gameplay**: 60 FPS rendering with CustomPainter
- **Responsive controls**:
  - Mobile: Swipe gestures (up, down, left, right)
  - Web/Desktop: Arrow keys or WASD
- **Progressive difficulty**: Speed increases every 5 food items
- **High score persistence**: Local storage of best scores
- **Retro-modern UI**: Neon cyan/magenta color scheme with glow effects

## Game Mechanics

- **Grid**: 20×20 cells
- **Starting speed**: 200ms per tick
- **Speed progression**: +10ms faster every 5 food items (min: 100ms)
- **Scoring**: 10 points per food item
- **No 180° turns**: Snake cannot reverse direction

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── direction.dart        # Direction enum
│   ├── position.dart         # Grid position class
│   └── game_state.dart       # Core game logic & state management
├── screens/
│   ├── menu_screen.dart      # Main menu
│   ├── game_screen.dart      # Game play screen
│   ├── game_over_screen.dart # Game over with stats
│   └── high_scores_screen.dart # High score display
├── widgets/
│   └── game_painter.dart     # Custom painter for rendering
└── utils/
    └── storage_service.dart  # High score persistence
```

## Building

### Prerequisites
- Flutter SDK 3.0.0 or higher
- For iOS: Xcode with iOS 11+ support
- For Android: Android Studio with SDK 21+

### Install Dependencies
```bash
flutter pub get
```

### Run on Device/Emulator
```bash
# Mobile (connected device/emulator)
flutter run

# iOS
flutter run -d ios

# Android
flutter run -d android

# Web
flutter run -d chrome
```

### Build for Production

#### iOS
```bash
flutter build ios --release
```

#### Android
```bash
flutter build apk --release
# or for App Bundle
flutter build appbundle --release
```

#### Web (PWA)
```bash
flutter build web --release
```

The web build will be in `build/web/` directory. Deploy to any static hosting service.

## PWA Configuration

To make the web version a Progressive Web App:

1. The manifest is auto-generated in `web/manifest.json`
2. Service worker is generated during build
3. Deploy to HTTPS hosting for full PWA features

## Controls

### Mobile
- **Swipe up**: Move up
- **Swipe down**: Move down
- **Swipe left**: Move left
- **Swipe right**: Move right

### Web/Desktop
- **Arrow keys**: Directional movement
- **WASD**: Alternative directional controls
- **Space**: Pause/Resume (if implemented)

## Technical Details

- **Rendering**: CustomPainter with Canvas API (60 FPS)
- **State Management**: ChangeNotifier pattern
- **Input**: GestureDetector (mobile) + KeyboardListener (web)
- **Storage**: shared_preferences package
- **Animations**: AnimationController for food pulse effect

## Performance

- Optimized rendering with shouldRepaint
- Efficient collision detection
- Minimal rebuilds with targeted setState
- Locked at 60 FPS for smooth gameplay

## License

MIT License - Feel free to use and modify

## Author

Built with Flutter

---

**Let's play!** 🐍
