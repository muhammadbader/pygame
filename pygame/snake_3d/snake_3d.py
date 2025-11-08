"""
3D Snake Game using Ursina Engine
A modern 3D implementation of the classic snake game
"""

from ursina import *
from random import randint


class SnakeGame(Ursina):
    def __init__(self):
        super().__init__()

        # Game settings
        self.grid_size = 15
        self.move_speed = 0.15
        self.time_elapsed = 0

        # Snake setup
        self.snake = []
        self.direction = Vec3(1, 0, 0)
        self.next_direction = Vec3(1, 0, 0)

        # Game state
        self.game_over = False
        self.score = 0
        self.paused = False

        # Setup the game
        self.setup_scene()
        self.create_snake()
        self.spawn_food()
        self.create_ui()

    def setup_scene(self):
        """Setup the 3D scene, camera, and lighting"""
        window.title = '3D Snake Game'
        window.borderless = False
        window.fullscreen = False
        window.exit_button.visible = False
        window.fps_counter.enabled = True

        # Set background color
        camera.orthographic = False
        camera.fov = 90
        Sky(color=color.rgb(20, 20, 40))

        # Position camera for better view
        camera.position = (0, 20, -20)
        camera.rotation_x = 45

        # Create grid floor
        self.create_grid()

        # Add ambient light
        AmbientLight(color=color.rgba(100, 100, 100, 0.5))
        DirectionalLight(y=2, z=3, shadows=True, rotation=(45, -45, 45))

    def create_grid(self):
        """Create a visual grid for the play area"""
        grid_color = color.rgb(40, 40, 60)

        # Create floor
        floor = Entity(
            model='plane',
            scale=self.grid_size * 2,
            color=color.rgb(15, 15, 25),
            position=(0, -0.5, 0),
            collider='box'
        )

        # Create grid lines
        for i in range(-self.grid_size, self.grid_size + 1):
            # Lines along X axis
            Entity(
                model='cube',
                scale=(self.grid_size * 2, 0.05, 0.05),
                position=(0, -0.45, i),
                color=grid_color
            )
            # Lines along Z axis
            Entity(
                model='cube',
                scale=(0.05, 0.05, self.grid_size * 2),
                position=(i, -0.45, 0),
                color=grid_color
            )

        # Create walls
        wall_height = 3
        wall_color = color.rgb(30, 30, 50)

        # Four walls
        for x, z, sx, sz in [
            (0, self.grid_size, self.grid_size * 2 + 1, 1),  # Front
            (0, -self.grid_size, self.grid_size * 2 + 1, 1),  # Back
            (self.grid_size, 0, 1, self.grid_size * 2 + 1),  # Right
            (-self.grid_size, 0, 1, self.grid_size * 2 + 1)  # Left
        ]:
            Entity(
                model='cube',
                position=(x, wall_height / 2 - 0.5, z),
                scale=(sx, wall_height, sz),
                color=wall_color,
                collider='box'
            )

    def create_snake(self):
        """Create the initial snake"""
        # Start with 3 segments
        start_positions = [Vec3(0, 0, 0), Vec3(-1, 0, 0), Vec3(-2, 0, 0)]

        for pos in start_positions:
            segment = Entity(
                model='cube',
                color=color.rgb(50, 255, 50),
                position=pos,
                scale=0.9
            )
            self.snake.append(segment)

        # Make head brighter
        self.snake[0].color = color.rgb(100, 255, 100)

    def spawn_food(self):
        """Spawn food at a random location"""
        while True:
            x = randint(-self.grid_size + 1, self.grid_size - 1)
            z = randint(-self.grid_size + 1, self.grid_size - 1)
            food_pos = Vec3(x, 0, z)

            # Check if position is occupied by snake
            occupied = any(seg.position == food_pos for seg in self.snake)
            if not occupied:
                break

        self.food = Entity(
            model='sphere',
            color=color.rgb(255, 50, 50),
            position=food_pos,
            scale=0.7
        )

        # Add pulsing animation to food
        self.food.animate_scale(0.9, duration=0.5, curve=curve.in_out_bounce)
        self.food.animate_scale(0.7, duration=0.5, delay=0.5, curve=curve.in_out_bounce, loop=True)

    def create_ui(self):
        """Create UI elements"""
        self.score_text = Text(
            text=f'Score: {self.score}',
            position=(-0.85, 0.45),
            scale=2,
            color=color.white
        )

        self.controls_text = Text(
            text='WASD/Arrows: Move | Space: Pause | R: Restart | Esc: Quit',
            position=(-0.85, -0.45),
            scale=1.2,
            color=color.light_gray
        )

        self.game_over_text = Text(
            text='',
            position=(0, 0.1),
            scale=3,
            color=color.red,
            origin=(0, 0),
            visible=False
        )

    def move_snake(self):
        """Move the snake in the current direction"""
        if self.game_over or self.paused:
            return

        # Update direction
        self.direction = self.next_direction

        # Calculate new head position
        new_head_pos = self.snake[0].position + self.direction

        # Check wall collision
        if (abs(new_head_pos.x) >= self.grid_size or
            abs(new_head_pos.z) >= self.grid_size):
            self.end_game()
            return

        # Check self collision
        for segment in self.snake[1:]:
            if segment.position == new_head_pos:
                self.end_game()
                return

        # Check food collision
        ate_food = new_head_pos == self.food.position

        if ate_food:
            self.score += 10
            self.score_text.text = f'Score: {self.score}'
            destroy(self.food)
            self.spawn_food()

            # Add new segment
            new_segment = Entity(
                model='cube',
                color=color.rgb(50, 255, 50),
                position=self.snake[-1].position,
                scale=0.9
            )
            self.snake.append(new_segment)

        # Move snake
        for i in range(len(self.snake) - 1, 0, -1):
            self.snake[i].position = self.snake[i - 1].position

        self.snake[0].position = new_head_pos

        # Update head color
        self.snake[0].color = color.rgb(100, 255, 100)
        if len(self.snake) > 1:
            self.snake[1].color = color.rgb(50, 255, 50)

    def end_game(self):
        """Handle game over"""
        self.game_over = True
        self.game_over_text.text = f'GAME OVER!\nScore: {self.score}\nPress R to Restart'
        self.game_over_text.visible = True

        # Make snake red
        for segment in self.snake:
            segment.color = color.rgb(255, 50, 50)

    def restart_game(self):
        """Restart the game"""
        # Clear snake
        for segment in self.snake:
            destroy(segment)
        self.snake.clear()

        # Clear food
        if hasattr(self, 'food'):
            destroy(self.food)

        # Reset game state
        self.direction = Vec3(1, 0, 0)
        self.next_direction = Vec3(1, 0, 0)
        self.game_over = False
        self.score = 0
        self.paused = False
        self.time_elapsed = 0

        # Recreate game elements
        self.create_snake()
        self.spawn_food()
        self.score_text.text = f'Score: {self.score}'
        self.game_over_text.visible = False

    def update(self):
        """Called every frame"""
        if self.game_over or self.paused:
            return

        self.time_elapsed += time.dt

        if self.time_elapsed >= self.move_speed:
            self.time_elapsed = 0
            self.move_snake()

    def input(self, key):
        """Handle keyboard input"""
        if key == 'escape':
            application.quit()

        if key == 'r':
            self.restart_game()

        if key == 'space':
            self.paused = not self.paused

        if self.game_over or self.paused:
            return

        # Movement controls - prevent 180-degree turns
        if key in ('w', 'up arrow') and self.direction != Vec3(0, 0, 1):
            self.next_direction = Vec3(0, 0, -1)
        elif key in ('s', 'down arrow') and self.direction != Vec3(0, 0, -1):
            self.next_direction = Vec3(0, 0, 1)
        elif key in ('a', 'left arrow') and self.direction != Vec3(1, 0, 0):
            self.next_direction = Vec3(-1, 0, 0)
        elif key in ('d', 'right arrow') and self.direction != Vec3(-1, 0, 0):
            self.next_direction = Vec3(1, 0, 0)


def main():
    """Main entry point"""
    game = SnakeGame()
    game.run()


if __name__ == '__main__':
    main()
