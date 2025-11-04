import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'direction.dart';
import 'position.dart';

/// Game state management
class GameState extends ChangeNotifier {
  // Grid configuration
  static const int gridWidth = 15;  // Narrower for phone width
  static const int gridHeight = 25; // Taller for phone height
  static const int initialSpeed = 200; // milliseconds per tick
  static const int minSpeed = 100;
  static const int speedIncrement = 10;
  static const int foodPerSpeedUp = 5;

  // Game state
  List<Position> snake = [];
  Position? food;
  Direction currentDirection = Direction.right;
  Direction? nextDirection;
  int score = 0;
  int foodEaten = 0;
  bool isGameOver = false;
  bool isPaused = false;
  Timer? _gameTimer;
  int currentSpeed = initialSpeed;
  int currentTheme = 0; // Theme changes every 5 gems

  final Random _random = Random();

  // Theme milestone - change theme every 5 gems
  static const int gemsPerTheme = 5;

  /// Initialize a new game
  void initGame() {
    // Initialize snake at center with 3 segments
    final centerX = gridWidth ~/ 2;
    final centerY = gridHeight ~/ 2;
    snake = [
      Position(centerX, centerY),
      Position(centerX - 1, centerY),
      Position(centerX - 2, centerY),
    ];

    currentDirection = Direction.right;
    nextDirection = null;
    score = 0;
    foodEaten = 0;
    isGameOver = false;
    isPaused = false;
    currentSpeed = initialSpeed;
    currentTheme = 0;

    _spawnFood();
    notifyListeners();
  }

  /// Start the game loop
  void startGame() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(Duration(milliseconds: currentSpeed), (_) {
      if (!isPaused && !isGameOver) {
        _tick();
      }
    });
  }

  /// Pause/Resume the game
  void togglePause() {
    isPaused = !isPaused;
    notifyListeners();
  }

  /// Change snake direction (with 180° prevention)
  void changeDirection(Direction newDirection) {
    if (!currentDirection.isOpposite(newDirection)) {
      nextDirection = newDirection;
    }
  }

  /// Game tick - main game loop
  void _tick() {
    // Apply queued direction change
    if (nextDirection != null) {
      currentDirection = nextDirection!;
      nextDirection = null;
    }

    // Calculate new head position
    final head = snake.first;
    Position newHead;

    switch (currentDirection) {
      case Direction.up:
        newHead = Position(head.x, head.y - 1);
        break;
      case Direction.down:
        newHead = Position(head.x, head.y + 1);
        break;
      case Direction.left:
        newHead = Position(head.x - 1, head.y);
        break;
      case Direction.right:
        newHead = Position(head.x + 1, head.y);
        break;
    }

    // Check wall collision
    if (newHead.x < 0 ||
        newHead.x >= gridWidth ||
        newHead.y < 0 ||
        newHead.y >= gridHeight) {
      _gameOver();
      return;
    }

    // Check self collision
    if (snake.contains(newHead)) {
      _gameOver();
      return;
    }

    // Move snake
    snake.insert(0, newHead);

    // Check food collision
    if (newHead == food) {
      _eatFood();
    } else {
      // Remove tail if not eating
      snake.removeLast();
    }

    notifyListeners();
  }

  /// Handle food consumption
  void _eatFood() {
    foodEaten++;
    score += 10;

    // Update theme every gemsPerTheme gems (cycles through 5 themes)
    currentTheme = (foodEaten ~/ gemsPerTheme) % 5;

    // Increase speed every foodPerSpeedUp foods
    if (foodEaten % foodPerSpeedUp == 0 && currentSpeed > minSpeed) {
      currentSpeed = max(minSpeed, currentSpeed - speedIncrement);
      // Restart timer with new speed
      startGame();
    }

    _spawnFood();
  }

  /// Spawn food at random empty position
  void _spawnFood() {
    final emptyCells = <Position>[];

    for (int x = 0; x < gridWidth; x++) {
      for (int y = 0; y < gridHeight; y++) {
        final pos = Position(x, y);
        if (!snake.contains(pos)) {
          emptyCells.add(pos);
        }
      }
    }

    if (emptyCells.isNotEmpty) {
      food = emptyCells[_random.nextInt(emptyCells.length)];
    }
  }

  /// Handle game over
  void _gameOver() {
    isGameOver = true;
    _gameTimer?.cancel();
    notifyListeners();
  }

  /// Reset game
  void reset() {
    _gameTimer?.cancel();
    initGame();
    startGame();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}
