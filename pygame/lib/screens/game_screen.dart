import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/direction.dart';
import '../models/game_state.dart';
import '../widgets/game_painter.dart';
import 'game_over_screen.dart';

/// Main game screen with rendering and input handling
class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late GameState _gameState;
  late AnimationController _foodAnimationController;
  late Animation<double> _foodAnimation;
  final FocusNode _focusNode = FocusNode();

  // Swipe detection
  Offset? _swipeStart;
  static const double swipeThreshold = 30.0;

  @override
  void initState() {
    super.initState();

    // Initialize game state
    _gameState = GameState();
    _gameState.initGame();
    _gameState.startGame();
    _gameState.addListener(_onGameStateChanged);

    // Food pulse animation
    _foodAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _foodAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _foodAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Request focus for keyboard input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _onGameStateChanged() {
    if (_gameState.isGameOver) {
      _showGameOver();
    }
    setState(() {});
  }

  void _showGameOver() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GameOverScreen(
            score: _gameState.score,
            foodEaten: _gameState.foodEaten,
          ),
        ),
      );
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
        case LogicalKeyboardKey.keyW:
          _gameState.changeDirection(Direction.up);
          break;
        case LogicalKeyboardKey.arrowDown:
        case LogicalKeyboardKey.keyS:
          _gameState.changeDirection(Direction.down);
          break;
        case LogicalKeyboardKey.arrowLeft:
        case LogicalKeyboardKey.keyA:
          _gameState.changeDirection(Direction.left);
          break;
        case LogicalKeyboardKey.arrowRight:
        case LogicalKeyboardKey.keyD:
          _gameState.changeDirection(Direction.right);
          break;
        case LogicalKeyboardKey.space:
          _gameState.togglePause();
          break;
      }
    }
  }

  void _handlePanStart(DragStartDetails details) {
    _swipeStart = details.localPosition;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_swipeStart == null) return;

    final delta = details.localPosition - _swipeStart!;

    if (delta.distance < swipeThreshold) return;

    // Determine swipe direction
    if (delta.dx.abs() > delta.dy.abs()) {
      // Horizontal swipe
      if (delta.dx > 0) {
        _gameState.changeDirection(Direction.right);
      } else {
        _gameState.changeDirection(Direction.left);
      }
    } else {
      // Vertical swipe
      if (delta.dy > 0) {
        _gameState.changeDirection(Direction.down);
      } else {
        _gameState.changeDirection(Direction.up);
      }
    }

    // Reset swipe start to prevent multiple triggers
    _swipeStart = null;
  }

  @override
  void dispose() {
    _gameState.removeListener(_onGameStateChanged);
    _gameState.dispose();
    _foodAnimationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              // HUD
              _buildHUD(),

              // Game board
              Expanded(
                child: Center(
                  child: _buildGameBoard(),
                ),
              ),

              // Mobile controls hint
              if (Theme.of(context).platform == TargetPlatform.android ||
                  Theme.of(context).platform == TargetPlatform.iOS)
                _buildControlsHint(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHUD() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SCORE',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.cyan.withOpacity(0.6),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _gameState.score.toString().padLeft(4, '0'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00FFFF),
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),

          // Length
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'LENGTH',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.cyan.withOpacity(0.6),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _gameState.snake.length.toString().padLeft(3, '0'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00FFFF),
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate cell size to fit screen
        final maxSize = min(constraints.maxWidth, constraints.maxHeight);
        final boardSize = maxSize * 0.95;
        final cellSize = boardSize / GameState.gridSize;

        return GestureDetector(
          onPanStart: _handlePanStart,
          onPanUpdate: _handlePanUpdate,
          child: Container(
            width: boardSize,
            height: boardSize,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF00FFFF).withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFFF).withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _foodAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: GamePainter(
                    gameState: _gameState,
                    cellSize: cellSize,
                    foodAnimation: _foodAnimation,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlsHint() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Swipe to control',
        style: TextStyle(
          fontSize: 14,
          color: Colors.cyan.withOpacity(0.4),
          letterSpacing: 1,
        ),
      ),
    );
  }
}
