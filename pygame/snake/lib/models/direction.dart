/// Direction enum for snake movement
enum Direction {
  up,
  down,
  left,
  right;

  /// Check if this direction is opposite to another
  bool isOpposite(Direction other) {
    return (this == Direction.up && other == Direction.down) ||
        (this == Direction.down && other == Direction.up) ||
        (this == Direction.left && other == Direction.right) ||
        (this == Direction.right && other == Direction.left);
  }
}
