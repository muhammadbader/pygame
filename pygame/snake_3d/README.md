# 3D Snake Game

A modern 3D implementation of the classic Snake game built with Ursina Engine.

## Features

- **Full 3D Graphics**: Experience Snake like never before with a stunning 3D environment
- **Grid-based Movement**: Classic snake movement on a 3D grid
- **Dynamic Camera**: Angled camera view for optimal gameplay visibility
- **Visual Effects**:
  - Pulsing food animation
  - Grid floor with walls
  - Directional lighting and shadows
  - Color-coded snake segments (bright head, regular body)
- **Game Mechanics**:
  - Snake grows when eating food
  - Score tracking
  - Collision detection (walls and self)
  - Pause functionality
  - Quick restart

## Installation

### Prerequisites

- Python 3.7 or higher
- pip (Python package manager)

### Setup

1. Install the required dependencies:

```bash
pip install -r requirements.txt
```

Or install Ursina directly:

```bash
pip install ursina
```

## How to Play

Run the game:

```bash
python snake_3d.py
```

### Controls

- **W / Up Arrow**: Move forward (away from camera)
- **S / Down Arrow**: Move backward (toward camera)
- **A / Left Arrow**: Move left
- **D / Right Arrow**: Move right
- **Space**: Pause/Unpause game
- **R**: Restart game
- **Esc**: Quit game

### Gameplay

1. Control the snake to eat the red food spheres
2. Each food item increases your score by 10 points
3. The snake grows longer with each food eaten
4. Avoid hitting the walls or your own body
5. Try to achieve the highest score possible!

## Technical Details

### Built With

- **Ursina Engine**: A Python game engine built on top of Panda3D
- **Python**: Programming language

### Game Architecture

- **Grid Size**: 15x15 units
- **Movement Speed**: Updates every 0.15 seconds
- **3D Models**: Cubes for snake segments, sphere for food
- **Camera**: Positioned at (0, 20, -20) with 45-degree rotation for isometric-style view

### Code Structure

```
snake_3d/
├── snake_3d.py         # Main game file
├── requirements.txt    # Python dependencies
└── README.md          # This file
```

## Game Elements

### Snake
- **Head**: Bright green cube (RGB: 100, 255, 100)
- **Body**: Green cubes (RGB: 50, 255, 50)
- **Initial Length**: 3 segments

### Food
- **Appearance**: Red pulsing sphere (RGB: 255, 50, 50)
- **Animation**: Scales between 0.7 and 0.9
- **Value**: 10 points per food

### Environment
- **Floor**: Dark grid with visible grid lines
- **Walls**: Semi-transparent walls surrounding the play area
- **Lighting**: Ambient and directional lighting for depth

## Tips & Strategies

1. **Plan Ahead**: Think about your path before making moves
2. **Use the Walls**: Navigate along the walls when the snake gets long
3. **Avoid Trapping Yourself**: Leave escape routes as you grow
4. **Speed Increases**: The game maintains constant speed, but longer snake means more challenge

## Troubleshooting

### Game won't start
- Ensure Python 3.7+ is installed: `python --version`
- Check if Ursina is installed: `pip list | grep ursina`
- Reinstall dependencies: `pip install -r requirements.txt --force-reinstall`

### Performance issues
- Close other applications to free up resources
- Update your graphics drivers
- Reduce window size if needed (modify `window.fullscreen` in code)

### Graphics not showing properly
- Ensure your system supports OpenGL
- Update Python and Ursina to latest versions
- Try running with: `python snake_3d.py --force-opengl`

## Future Enhancements

Potential features for future versions:
- Difficulty levels (speed adjustment)
- Power-ups (slow-motion, shield, etc.)
- Multiple camera angles
- High score persistence
- Sound effects and background music
- Different game modes (timed, survival, etc.)
- Obstacles in the play area
- Multiplayer support

## Credits

Developed using the Ursina Engine - a powerful and easy-to-use Python game engine.

## License

This project is open source and available for educational purposes.

---

Enjoy the game! Try to beat your high score and master the 3D snake controls!
