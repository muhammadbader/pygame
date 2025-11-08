import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/direction.dart';
import '../models/position.dart';
import 'components/snake_component.dart';
import 'components/food_component.dart';
import 'components/grid_component.dart';
import 'components/background_component.dart';

/// Flame-powered snake game with enhanced visual effects
class SnakeFlameGame extends FlameGame
    with KeyboardEvents, TapCallbacks, HasCollisionDetection {
  // Grid configuration
  static const int gridWidth = 15;
  static const int gridHeight = 25;
  static const double initialSpeed = 0.2; // seconds per tick
  static const double minSpeed = 0.1;
  static const double speedDecrement = 0.01;
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
  double currentSpeed = initialSpeed;
  int currentTheme = 0;

  // Components
  late SnakeComponent snakeComponent;
  late FoodComponent foodComponent;
  late GridComponent gridComponent;
  late BackgroundComponent backgroundComponent;

  // Game tick timer
  Timer? _gameTimer;
  double _accumulator = 0;

  // Callbacks
  Function(int score, int foodEaten)? onGameOver;
  Function(int score, int length)? onScoreUpdate;

  // Swipe detection
  Vector2? _swipeStart;
  static const double swipeThreshold = 30.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Pre-cache audio (silently fail if files don't exist)
    try {
      await FlameAudio.audioCache.loadAll([
        'eat.mp3',
        'game_over.mp3',
        'move.mp3',
      ]);
    } catch (e) {
      // Audio files not found, continue without sound
      debugPrint('Audio files not found: $e');
    }

    // Add background
    backgroundComponent = BackgroundComponent();
    add(backgroundComponent);

    // Add grid
    gridComponent = GridComponent(
      gridWidth: gridWidth,
      gridHeight: gridHeight,
    );
    add(gridComponent);

    // Initialize game
    _initGame();
  }

  void _initGame() {
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
    _accumulator = 0;

    _spawnFood();

    // Create snake component
    snakeComponent = SnakeComponent(
      snake: snake,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
    );
    add(snakeComponent);

    // Create food component
    if (food != null) {
      foodComponent = FoodComponent(
        position: food!,
        gridWidth: gridWidth,
        gridHeight: gridHeight,
      );
      add(foodComponent);
    }

    // Notify score update
    onScoreUpdate?.call(score, snake.length);
  }

  void reset() {
    // Remove existing components
    snakeComponent.removeFromParent();
    foodComponent.removeFromParent();

    // Reinitialize
    _initGame();
  }

  void togglePause() {
    isPaused = !isPaused;
  }

  void changeDirection(Direction newDirection) {
    if (!currentDirection.isOpposite(newDirection)) {
      nextDirection = newDirection;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isPaused || isGameOver) return;

    // Accumulate time
    _accumulator += dt;

    // Game tick based on current speed
    if (_accumulator >= currentSpeed) {
      _accumulator = 0;
      _tick();
    }

    // Update theme based on food eaten
    final newTheme = (foodEaten ~/ 5) % 5;
    if (newTheme != currentTheme) {
      currentTheme = newTheme;
      backgroundComponent.updateTheme(currentTheme);
      gridComponent.updateTheme(currentTheme);
      snakeComponent.updateTheme(currentTheme);
      foodComponent.updateTheme(currentTheme);
    }
  }

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

    // Update snake component
    snakeComponent.updateSnake(snake, currentDirection);
  }

  void _eatFood() {
    foodEaten++;
    score += 10;

    // Play eat sound
    try {
      FlameAudio.play('eat.mp3', volume: 0.5);
    } catch (e) {
      // Sound not available
    }

    // Create particle burst at food location
    if (food != null) {
      _createFoodParticles(food!);
    }

    // Increase speed every foodPerSpeedUp foods
    if (foodEaten % foodPerSpeedUp == 0 && currentSpeed > minSpeed) {
      currentSpeed = max(minSpeed, currentSpeed - speedDecrement);
    }

    // Remove old food component
    foodComponent.removeFromParent();

    // Spawn new food
    _spawnFood();

    // Add new food component
    if (food != null) {
      foodComponent = FoodComponent(
        position: food!,
        gridWidth: gridWidth,
        gridHeight: gridHeight,
      );
      add(foodComponent);
    }

    // Notify score update
    onScoreUpdate?.call(score, snake.length);
  }

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
      final random = Random();
      food = emptyCells[random.nextInt(emptyCells.length)];
    }
  }

  void _gameOver() {
    isGameOver = true;

    // Play game over sound
    try {
      FlameAudio.play('game_over.mp3', volume: 0.5);
    } catch (e) {
      // Sound not available
    }

    // Create death explosion
    _createDeathExplosion();

    // Notify game over
    onGameOver?.call(score, foodEaten);
  }

  void _createFoodParticles(Position foodPos) {
    final cellWidth = size.x / gridWidth;
    final cellHeight = size.y / gridHeight;
    final centerX = foodPos.x * cellWidth + cellWidth / 2;
    final centerY = foodPos.y * cellHeight + cellHeight / 2;

    final particleComponent = ParticleSystemComponent(
      particle: Particle.generate(
        count: 30,
        lifespan: 0.8,
        generator: (i) {
          final random = Random();
          final angle = random.nextDouble() * 2 * pi;
          final speed = 50 + random.nextDouble() * 100;

          return AcceleratedParticle(
            acceleration: Vector2(0, 100),
            speed: Vector2(cos(angle) * speed, sin(angle) * speed),
            position: Vector2(centerX, centerY),
            child: CircleParticle(
              radius: 2 + random.nextDouble() * 3,
              paint: Paint()
                ..color = Color.lerp(
                  const Color(0xFFFFD700),
                  const Color(0xFFFFC107),
                  random.nextDouble(),
                )!
                    .withOpacity(0.8),
            ),
          );
        },
      ),
    );

    add(particleComponent);

    // Auto-remove after animation
    Future.delayed(const Duration(seconds: 1), () {
      particleComponent.removeFromParent();
    });
  }

  void _createDeathExplosion() {
    if (snake.isEmpty) return;

    final head = snake.first;
    final cellWidth = size.x / gridWidth;
    final cellHeight = size.y / gridHeight;
    final centerX = head.x * cellWidth + cellWidth / 2;
    final centerY = head.y * cellHeight + cellHeight / 2;

    final particleComponent = ParticleSystemComponent(
      particle: Particle.generate(
        count: 50,
        lifespan: 1.2,
        generator: (i) {
          final random = Random();
          final angle = random.nextDouble() * 2 * pi;
          final speed = 80 + random.nextDouble() * 150;

          return AcceleratedParticle(
            acceleration: Vector2(0, 150),
            speed: Vector2(cos(angle) * speed, sin(angle) * speed),
            position: Vector2(centerX, centerY),
            child: RotatingParticle(
              to: random.nextDouble() * 2 * pi,
              child: CircleParticle(
                radius: 3 + random.nextDouble() * 5,
                paint: Paint()
                  ..color = Color.lerp(
                    const Color(0xFF00BCD4),
                    const Color(0xFF00695C),
                    random.nextDouble(),
                  )!
                      .withOpacity(0.9),
              ),
            ),
          );
        },
      ),
    );

    add(particleComponent);

    // Auto-remove after animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      particleComponent.removeFromParent();
    });
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
        case LogicalKeyboardKey.keyW:
          changeDirection(Direction.up);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowDown:
        case LogicalKeyboardKey.keyS:
          changeDirection(Direction.down);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowLeft:
        case LogicalKeyboardKey.keyA:
          changeDirection(Direction.left);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowRight:
        case LogicalKeyboardKey.keyD:
          changeDirection(Direction.right);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.space:
          togglePause();
          return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  void onTapDown(TapDownEvent event) {
    _swipeStart = event.localPosition;
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_swipeStart == null) return;

    final delta = event.localPosition - _swipeStart!;

    if (delta.length < swipeThreshold) {
      _swipeStart = null;
      return;
    }

    // Determine swipe direction
    if (delta.x.abs() > delta.y.abs()) {
      // Horizontal swipe
      if (delta.x > 0) {
        changeDirection(Direction.right);
      } else {
        changeDirection(Direction.left);
      }
    } else {
      // Vertical swipe
      if (delta.y > 0) {
        changeDirection(Direction.down);
      } else {
        changeDirection(Direction.up);
      }
    }

    _swipeStart = null;
  }
}
