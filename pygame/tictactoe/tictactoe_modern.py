"""
Modern Gamified Tic Tac Toe
A beautiful, animated tic-tac-toe game using pygame
Features: Smooth animations, particle effects, modern UI, score tracking
"""

import pygame
import sys
import math
import random

# Initialize pygame
pygame.init()

# Constants
WIDTH, HEIGHT = 600, 700
GRID_SIZE = 3
CELL_SIZE = 180
GRID_OFFSET_X = 30
GRID_OFFSET_Y = 130
LINE_WIDTH = 5
MARK_SIZE = 60
FPS = 60

# Colors - Modern palette
BG_COLOR = (15, 23, 42)  # Dark blue-gray
GRID_COLOR = (71, 85, 105)  # Slate gray
X_COLOR = (239, 68, 68)  # Red
O_COLOR = (59, 130, 246)  # Blue
HOVER_COLOR = (51, 65, 85)  # Lighter slate
WIN_LINE_COLOR = (250, 204, 21)  # Gold
TEXT_COLOR = (248, 250, 252)  # Off-white
BUTTON_COLOR = (100, 116, 139)
BUTTON_HOVER_COLOR = (148, 163, 184)
PARTICLE_COLORS = [(250, 204, 21), (251, 146, 60), (239, 68, 68), (168, 85, 247)]

# Fonts
TITLE_FONT = pygame.font.Font(None, 48)
SCORE_FONT = pygame.font.Font(None, 36)
BUTTON_FONT = pygame.font.Font(None, 30)
WINNER_FONT = pygame.font.Font(None, 40)


class Particle:
    """Particle effect for celebrations"""
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.vx = random.uniform(-5, 5)
        self.vy = random.uniform(-8, -2)
        self.gravity = 0.3
        self.lifetime = 60
        self.age = 0
        self.color = random.choice(PARTICLE_COLORS)
        self.size = random.randint(4, 8)

    def update(self):
        self.vy += self.gravity
        self.x += self.vx
        self.y += self.vy
        self.age += 1

    def draw(self, screen):
        alpha = 255 * (1 - self.age / self.lifetime)
        if alpha > 0:
            pygame.draw.circle(screen, self.color, (int(self.x), int(self.y)), self.size)

    def is_dead(self):
        return self.age >= self.lifetime


class TicTacToe:
    """Main game class"""
    def __init__(self):
        self.screen = pygame.display.set_mode((WIDTH, HEIGHT))
        pygame.display.set_caption("Tic Tac Toe - Modern Edition")
        self.clock = pygame.time.Clock()
        self.board = [['' for _ in range(GRID_SIZE)] for _ in range(GRID_SIZE)]
        self.current_player = 'X'
        self.game_over = False
        self.winner = None
        self.winning_line = None
        self.hover_cell = None
        self.animation_progress = 0
        self.marks_animation = {}  # Track animation for each mark
        self.particles = []
        self.scores = {'X': 0, 'O': 0, 'Draw': 0}
        self.winning_line_animation = 0

    def reset_board(self):
        """Reset the game board"""
        self.board = [['' for _ in range(GRID_SIZE)] for _ in range(GRID_SIZE)]
        self.current_player = 'X'
        self.game_over = False
        self.winner = None
        self.winning_line = None
        self.animation_progress = 0
        self.marks_animation = {}
        self.particles = []
        self.winning_line_animation = 0

    def get_cell_from_mouse(self, pos):
        """Convert mouse position to grid cell"""
        x, y = pos
        if (GRID_OFFSET_X <= x <= GRID_OFFSET_X + CELL_SIZE * GRID_SIZE and
            GRID_OFFSET_Y <= y <= GRID_OFFSET_Y + CELL_SIZE * GRID_SIZE):
            col = (x - GRID_OFFSET_X) // CELL_SIZE
            row = (y - GRID_OFFSET_Y) // CELL_SIZE
            return (row, col)
        return None

    def make_move(self, row, col):
        """Make a move on the board"""
        if self.board[row][col] == '' and not self.game_over:
            self.board[row][col] = self.current_player
            self.marks_animation[(row, col)] = 0  # Start animation for this mark

            # Check for winner
            if self.check_winner():
                self.game_over = True
                self.winner = self.current_player
                self.scores[self.current_player] += 1
                self.spawn_celebration_particles()
            elif self.is_board_full():
                self.game_over = True
                self.winner = 'Draw'
                self.scores['Draw'] += 1
            else:
                self.current_player = 'O' if self.current_player == 'X' else 'X'

    def check_winner(self):
        """Check if there's a winner"""
        # Check rows
        for row in range(GRID_SIZE):
            if (self.board[row][0] == self.board[row][1] == self.board[row][2] != ''):
                self.winning_line = ('row', row)
                return True

        # Check columns
        for col in range(GRID_SIZE):
            if (self.board[0][col] == self.board[1][col] == self.board[2][col] != ''):
                self.winning_line = ('col', col)
                return True

        # Check diagonals
        if (self.board[0][0] == self.board[1][1] == self.board[2][2] != ''):
            self.winning_line = ('diag', 0)
            return True
        if (self.board[0][2] == self.board[1][1] == self.board[2][0] != ''):
            self.winning_line = ('diag', 1)
            return True

        return False

    def is_board_full(self):
        """Check if board is full"""
        return all(self.board[row][col] != '' for row in range(GRID_SIZE) for col in range(GRID_SIZE))

    def spawn_celebration_particles(self):
        """Create celebration particles"""
        center_x = GRID_OFFSET_X + CELL_SIZE * 1.5
        center_y = GRID_OFFSET_Y + CELL_SIZE * 1.5
        for _ in range(50):
            self.particles.append(Particle(center_x, center_y))

    def draw_grid(self):
        """Draw the game grid"""
        # Draw cells with hover effect
        for row in range(GRID_SIZE):
            for col in range(GRID_SIZE):
                x = GRID_OFFSET_X + col * CELL_SIZE
                y = GRID_OFFSET_Y + row * CELL_SIZE

                # Hover effect
                if self.hover_cell == (row, col) and self.board[row][col] == '' and not self.game_over:
                    pygame.draw.rect(self.screen, HOVER_COLOR, (x, y, CELL_SIZE, CELL_SIZE))

        # Draw grid lines
        for i in range(GRID_SIZE + 1):
            # Vertical lines
            x = GRID_OFFSET_X + i * CELL_SIZE
            pygame.draw.line(self.screen, GRID_COLOR, (x, GRID_OFFSET_Y),
                           (x, GRID_OFFSET_Y + CELL_SIZE * GRID_SIZE), LINE_WIDTH)

            # Horizontal lines
            y = GRID_OFFSET_Y + i * CELL_SIZE
            pygame.draw.line(self.screen, GRID_COLOR, (GRID_OFFSET_X, y),
                           (GRID_OFFSET_X + CELL_SIZE * GRID_SIZE, y), LINE_WIDTH)

    def draw_marks(self):
        """Draw X's and O's with animation"""
        for row in range(GRID_SIZE):
            for col in range(GRID_SIZE):
                mark = self.board[row][col]
                if mark != '':
                    center_x = GRID_OFFSET_X + col * CELL_SIZE + CELL_SIZE // 2
                    center_y = GRID_OFFSET_Y + row * CELL_SIZE + CELL_SIZE // 2

                    # Animate new marks
                    if (row, col) in self.marks_animation:
                        self.marks_animation[(row, col)] = min(1.0, self.marks_animation[(row, col)] + 0.15)
                        scale = self.marks_animation[(row, col)]
                    else:
                        scale = 1.0

                    if mark == 'X':
                        self.draw_x(center_x, center_y, scale)
                    else:
                        self.draw_o(center_x, center_y, scale)

    def draw_x(self, x, y, scale=1.0):
        """Draw an X with animation"""
        size = MARK_SIZE * scale
        color = X_COLOR
        width = 8
        pygame.draw.line(self.screen, color, (x - size, y - size), (x + size, y + size), width)
        pygame.draw.line(self.screen, color, (x + size, y - size), (x - size, y + size), width)

    def draw_o(self, x, y, scale=1.0):
        """Draw an O with animation"""
        radius = int(MARK_SIZE * scale)
        color = O_COLOR
        width = 8
        pygame.draw.circle(self.screen, color, (x, y), radius, width)

    def draw_winning_line(self):
        """Draw the winning line with animation"""
        if self.winning_line and self.winning_line_animation < 1.0:
            self.winning_line_animation = min(1.0, self.winning_line_animation + 0.05)

        if self.winning_line:
            line_type, index = self.winning_line
            width = 10

            if line_type == 'row':
                start_x = GRID_OFFSET_X + 20
                start_y = GRID_OFFSET_Y + index * CELL_SIZE + CELL_SIZE // 2
                end_x = GRID_OFFSET_X + CELL_SIZE * GRID_SIZE - 20
                end_y = start_y
            elif line_type == 'col':
                start_x = GRID_OFFSET_X + index * CELL_SIZE + CELL_SIZE // 2
                start_y = GRID_OFFSET_Y + 20
                end_x = start_x
                end_y = GRID_OFFSET_Y + CELL_SIZE * GRID_SIZE - 20
            elif line_type == 'diag':
                if index == 0:
                    start_x = GRID_OFFSET_X + 20
                    start_y = GRID_OFFSET_Y + 20
                    end_x = GRID_OFFSET_X + CELL_SIZE * GRID_SIZE - 20
                    end_y = GRID_OFFSET_Y + CELL_SIZE * GRID_SIZE - 20
                else:
                    start_x = GRID_OFFSET_X + CELL_SIZE * GRID_SIZE - 20
                    start_y = GRID_OFFSET_Y + 20
                    end_x = GRID_OFFSET_X + 20
                    end_y = GRID_OFFSET_Y + CELL_SIZE * GRID_SIZE - 20

            # Animated line drawing
            current_end_x = start_x + (end_x - start_x) * self.winning_line_animation
            current_end_y = start_y + (end_y - start_y) * self.winning_line_animation

            pygame.draw.line(self.screen, WIN_LINE_COLOR, (start_x, start_y),
                           (current_end_x, current_end_y), width)

    def draw_ui(self):
        """Draw UI elements (title, scores, current player)"""
        # Title
        title = TITLE_FONT.render("TIC TAC TOE", True, TEXT_COLOR)
        title_rect = title.get_rect(center=(WIDTH // 2, 40))
        self.screen.blit(title, title_rect)

        # Current player indicator
        if not self.game_over:
            player_text = f"Current Player: {self.current_player}"
            player_color = X_COLOR if self.current_player == 'X' else O_COLOR
            player_surface = SCORE_FONT.render(player_text, True, player_color)
            player_rect = player_surface.get_rect(center=(WIDTH // 2, 90))
            self.screen.blit(player_surface, player_rect)

        # Scores
        score_y = HEIGHT - 60
        x_score = SCORE_FONT.render(f"X: {self.scores['X']}", True, X_COLOR)
        o_score = SCORE_FONT.render(f"O: {self.scores['O']}", True, O_COLOR)
        draw_score = SCORE_FONT.render(f"Draws: {self.scores['Draw']}", True, TEXT_COLOR)

        self.screen.blit(x_score, (80, score_y))
        self.screen.blit(o_score, (WIDTH // 2 - 30, score_y))
        self.screen.blit(draw_score, (WIDTH - 180, score_y))

    def draw_game_over(self):
        """Draw game over screen"""
        if self.game_over:
            # Semi-transparent overlay
            overlay = pygame.Surface((WIDTH, HEIGHT))
            overlay.set_alpha(200)
            overlay.fill(BG_COLOR)
            self.screen.blit(overlay, (0, 0))

            # Winner text
            if self.winner == 'Draw':
                text = "It's a Draw!"
                color = TEXT_COLOR
            else:
                text = f"Player {self.winner} Wins!"
                color = X_COLOR if self.winner == 'X' else O_COLOR

            winner_surface = WINNER_FONT.render(text, True, color)
            winner_rect = winner_surface.get_rect(center=(WIDTH // 2, HEIGHT // 2 - 50))
            self.screen.blit(winner_surface, winner_rect)

            # Play again button
            button_rect = pygame.Rect(WIDTH // 2 - 100, HEIGHT // 2 + 20, 200, 50)
            mouse_pos = pygame.mouse.get_pos()
            button_color = BUTTON_HOVER_COLOR if button_rect.collidepoint(mouse_pos) else BUTTON_COLOR

            pygame.draw.rect(self.screen, button_color, button_rect, border_radius=10)
            button_text = BUTTON_FONT.render("Play Again", True, TEXT_COLOR)
            button_text_rect = button_text.get_rect(center=button_rect.center)
            self.screen.blit(button_text, button_text_rect)

            return button_rect
        return None

    def update_particles(self):
        """Update and draw particles"""
        for particle in self.particles[:]:
            particle.update()
            particle.draw(self.screen)
            if particle.is_dead():
                self.particles.remove(particle)

    def run(self):
        """Main game loop"""
        running = True

        while running:
            self.clock.tick(FPS)

            # Event handling
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False

                elif event.type == pygame.MOUSEMOTION:
                    self.hover_cell = self.get_cell_from_mouse(event.pos)

                elif event.type == pygame.MOUSEBUTTONDOWN:
                    if self.game_over:
                        # Check if play again button was clicked
                        button_rect = pygame.Rect(WIDTH // 2 - 100, HEIGHT // 2 + 20, 200, 50)
                        if button_rect.collidepoint(event.pos):
                            self.reset_board()
                    else:
                        cell = self.get_cell_from_mouse(event.pos)
                        if cell:
                            row, col = cell
                            self.make_move(row, col)

            # Drawing
            self.screen.fill(BG_COLOR)
            self.draw_grid()
            self.draw_marks()
            self.draw_winning_line()
            self.update_particles()
            self.draw_ui()

            play_again_button = self.draw_game_over()

            pygame.display.flip()

        pygame.quit()
        sys.exit()


def main():
    """Main entry point"""
    game = TicTacToe()
    game.run()


if __name__ == "__main__":
    main()
