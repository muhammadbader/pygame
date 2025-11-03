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
          child: SafeArea(
            child: Column(
              children: [
                // Arabian-themed HUD
                _buildHUD(),

                // Game board with ornamental border
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
      ),
    );
  }

  Widget _buildHUD() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFD4AF37).withOpacity(0.3), // Rich gold
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score with Arabian styling
          _buildHUDItem(
            label: 'TREASURES',
            value: _gameState.score.toString().padLeft(4, '0'),
            icon: Icons.star_rounded,
          ),

          // Center ornament
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.4),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD4AF37).withOpacity(0.1),
                  const Color(0xFF00BCD4).withOpacity(0.05),
                ],
              ),
            ),
            child: Icon(
              Icons.stars_rounded,
              size: 24,
              color: const Color(0xFFD4AF37).withOpacity(0.8),
            ),
          ),

          // Length with Arabian styling
          _buildHUDItem(
            label: 'SERPENT',
            value: _gameState.snake.length.toString().padLeft(3, '0'),
            icon: Icons.trending_up_rounded,
            align: CrossAxisAlignment.end,
          ),
        ],
      ),
    );
  }

  Widget _buildHUDItem({
    required String label,
    required String value,
    required IconData icon,
    CrossAxisAlignment align = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: const Color(0xFF00BCD4).withOpacity(0.7), // Turquoise
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: const Color(0xFF00BCD4).withOpacity(0.8), // Turquoise
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFFFFD700), // Golden
              Color(0xFFD4AF37), // Rich gold
            ],
          ).createShader(bounds),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
              shadows: [
                Shadow(
                  color: Color(0xFFFFD700),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ],
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
              // Arabian ornamental border
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.5), // Rich gold
                width: 3,
              ),
              // Double border effect
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: const Color(0xFF00BCD4).withOpacity(0.2), // Turquoise glow
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            // Inner ornamental border
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF00BCD4).withOpacity(0.3), // Turquoise
                  width: 1.5,
                ),
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
          ),
        );
      },
    );
  }

  Widget _buildControlsHint() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.swipe_rounded,
            size: 16,
            color: const Color(0xFF00BCD4).withOpacity(0.5),
          ),
          const SizedBox(width: 8),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                const Color(0xFF00BCD4).withOpacity(0.6),
                const Color(0xFFD4AF37).withOpacity(0.5),
              ],
            ).createShader(bounds),
            child: const Text(
              'Swipe to guide the serpent',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
