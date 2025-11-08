"""
NERDY CYBERPUNK TIC TAC TOE
A hacker-themed, animated tic-tac-toe game using pygame
Features: Matrix effects, glitch animations, binary rain, neon glow, terminal aesthetics

Controls:
- Mouse Click: Place mark
- SPACE: Restart game
- Q: Quit game
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

# Colors - Cyberpunk/Hacker Theme
BG_COLOR = (10, 10, 20)  # Almost black
GRID_COLOR = (0, 255, 170)  # Neon cyan
X_COLOR = (255, 0, 255)  # Neon magenta
O_COLOR = (0, 255, 255)  # Cyan
HOVER_COLOR = (30, 30, 60)  # Dark blue glow
WIN_LINE_COLOR = (0, 255, 100)  # Matrix green
TEXT_COLOR = (0, 255, 170)  # Neon cyan
SECONDARY_TEXT = (100, 255, 200)  # Light cyan
BUTTON_COLOR = (20, 60, 80)
BUTTON_HOVER_COLOR = (40, 100, 120)
PARTICLE_COLORS = [(0, 255, 100), (0, 255, 255), (255, 0, 255), (255, 255, 0)]
BINARY_COLOR = (0, 200, 100)  # Matrix green
SCANLINE_COLOR = (0, 255, 170, 20)  # Transparent cyan

# Fonts (using monospace for that terminal feel)
try:
    TITLE_FONT = pygame.font.SysFont('couriernew', 48, bold=True)
    SCORE_FONT = pygame.font.SysFont('couriernew', 32)
    BUTTON_FONT = pygame.font.SysFont('couriernew', 28)
    WINNER_FONT = pygame.font.SysFont('couriernew', 40, bold=True)
    BINARY_FONT = pygame.font.SysFont('couriernew', 16)
    HINT_FONT = pygame.font.SysFont('couriernew', 20)
except:
    TITLE_FONT = pygame.font.Font(None, 48)
    SCORE_FONT = pygame.font.Font(None, 32)
    BUTTON_FONT = pygame.font.Font(None, 28)
    WINNER_FONT = pygame.font.Font(None, 40)
    BINARY_FONT = pygame.font.Font(None, 16)
    HINT_FONT = pygame.font.Font(None, 20)


class BinaryDigit:
    """Falling binary digits for matrix effect"""
    def __init__(self):
        self.x = random.randint(0, WIDTH)
        self.y = random.randint(-HEIGHT, 0)
        self.speed = random.uniform(1, 3)
        self.value = random.choice(['0', '1'])
        self.alpha = random.randint(50, 150)

    def update(self):
        self.y += self.speed
        if self.y > HEIGHT:
            self.y = random.randint(-50, 0)
            self.x = random.randint(0, WIDTH)
            self.value = random.choice(['0', '1'])

    def draw(self, screen):
        text = BINARY_FONT.render(self.value, True, BINARY_COLOR)
        text.set_alpha(self.alpha)
        screen.blit(text, (self.x, self.y))


class Particle:
    """Particle effect for celebrations"""
    def __init__(self, x, y, particle_type='explosion'):
        self.x = x
        self.y = y
        self.particle_type = particle_type

        if particle_type == 'explosion':
            angle = random.uniform(0, 2 * math.pi)
            speed = random.uniform(2, 8)
            self.vx = math.cos(angle) * speed
            self.vy = math.sin(angle) * speed
            self.gravity = 0.2
        else:  # sparkle
            self.vx = random.uniform(-2, 2)
            self.vy = random.uniform(-5, -1)
            self.gravity = 0.1

        self.lifetime = random.randint(40, 80)
        self.age = 0
        self.color = random.choice(PARTICLE_COLORS)
        self.size = random.randint(3, 7)

    def update(self):
        self.vy += self.gravity
        self.x += self.vx
        self.y += self.vy
        self.age += 1

    def draw(self, screen):
        alpha = 255 * (1 - self.age / self.lifetime)
        if alpha > 0:
            # Draw glow effect
            glow_size = self.size + 4
            glow_surface = pygame.Surface((glow_size * 2, glow_size * 2))
            glow_surface.fill((0, 0, 0))
            glow_surface.set_colorkey((0, 0, 0))
            glow_alpha = int(alpha // 3)
            pygame.draw.circle(glow_surface, self.color, (glow_size, glow_size), glow_size)
            glow_surface.set_alpha(glow_alpha)
            screen.blit(glow_surface, (int(self.x) - glow_size, int(self.y) - glow_size))

            # Draw particle
            pygame.draw.circle(screen, self.color, (int(self.x), int(self.y)), self.size)

    def is_dead(self):
        return self.age >= self.lifetime


class GlitchEffect:
    """Screen glitch effect"""
    def __init__(self):
        self.active = False
        self.duration = 0
        self.max_duration = 20

    def trigger(self):
        self.active = True
        self.duration = 0

    def update(self):
        if self.active:
            self.duration += 1
            if self.duration >= self.max_duration:
                self.active = False
                self.duration = 0

    def apply(self, screen):
        if self.active and random.random() < 0.3:
            # Random horizontal shift
            offset = random.randint(-10, 10)
            y = random.randint(0, HEIGHT - 50)
            height = random.randint(5, 30)

            # Create a copy of the strip and shift it
            strip = screen.subsurface((0, y, WIDTH, min(height, HEIGHT - y))).copy()
            screen.blit(strip, (offset, y))


class TicTacToe:
    """Main game class"""
    def __init__(self):
        self.screen = pygame.display.set_mode((WIDTH, HEIGHT))
        pygame.display.set_caption("[ NERD-TAC-TOE v2.0 ] - CYBERPUNK EDITION")
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

        # New nerdy effects
        self.binary_digits = [BinaryDigit() for _ in range(30)]
        self.glitch = GlitchEffect()
        self.grid_pulse = 0
        self.screen_shake = 0
        self.title_glitch_timer = 0
        self.scanline_offset = 0

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
        self.screen_shake = 0
        self.glitch.active = False

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

            # Spawn sparkle particles
            center_x = GRID_OFFSET_X + col * CELL_SIZE + CELL_SIZE // 2
            center_y = GRID_OFFSET_Y + row * CELL_SIZE + CELL_SIZE // 2
            for _ in range(10):
                self.particles.append(Particle(center_x, center_y, 'sparkle'))

            # Check for winner
            if self.check_winner():
                self.game_over = True
                self.winner = self.current_player
                self.scores[self.current_player] += 1
                self.spawn_celebration_particles()
                self.glitch.trigger()
                self.screen_shake = 15
            elif self.is_board_full():
                self.game_over = True
                self.winner = 'Draw'
                self.scores['Draw'] += 1
                self.spawn_celebration_particles()
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
        for _ in range(100):
            self.particles.append(Particle(center_x, center_y, 'explosion'))

    def draw_background_effects(self):
        """Draw nerdy background effects"""
        # Binary rain
        for digit in self.binary_digits:
            digit.update()
            digit.draw(self.screen)

        # Scanlines
        self.scanline_offset = (self.scanline_offset + 1) % 4
        for y in range(0, HEIGHT, 4):
            scanline = pygame.Surface((WIDTH, 2), pygame.SRCALPHA)
            scanline.fill(SCANLINE_COLOR)
            self.screen.blit(scanline, (0, y + self.scanline_offset))

    def draw_grid(self):
        """Draw the game grid with pulse effect"""
        # Pulse animation
        self.grid_pulse = (self.grid_pulse + 0.05) % (2 * math.pi)
        pulse = int(20 * math.sin(self.grid_pulse))

        # Draw cells with hover effect
        for row in range(GRID_SIZE):
            for col in range(GRID_SIZE):
                x = GRID_OFFSET_X + col * CELL_SIZE
                y = GRID_OFFSET_Y + row * CELL_SIZE

                # Hover effect with glow
                if self.hover_cell == (row, col) and self.board[row][col] == '' and not self.game_over:
                    # Outer glow
                    glow_surface = pygame.Surface((CELL_SIZE, CELL_SIZE))
                    glow_surface.fill(O_COLOR)
                    glow_surface.set_alpha(30)
                    self.screen.blit(glow_surface, (x, y))
                    # Inner highlight
                    pygame.draw.rect(self.screen, HOVER_COLOR, (x, y, CELL_SIZE, CELL_SIZE))

        # Draw grid lines with glow
        grid_color_pulsed = [
            int(min(255, max(0, GRID_COLOR[0] + pulse))),
            int(min(255, max(0, GRID_COLOR[1] + pulse))),
            int(min(255, max(0, GRID_COLOR[2] + pulse)))
        ]

        for i in range(GRID_SIZE + 1):
            # Vertical lines
            x = GRID_OFFSET_X + i * CELL_SIZE
            # Glow effect
            for offset in range(3):
                alpha = 100 - offset * 30
                glow_surface = pygame.Surface((LINE_WIDTH + offset * 2, CELL_SIZE * GRID_SIZE))
                glow_surface.fill(grid_color_pulsed)
                glow_surface.set_alpha(alpha)
                self.screen.blit(glow_surface, (x - offset + LINE_WIDTH // 2, GRID_OFFSET_Y))
            # Main line
            pygame.draw.line(self.screen, grid_color_pulsed, (x, GRID_OFFSET_Y),
                           (x, GRID_OFFSET_Y + CELL_SIZE * GRID_SIZE), LINE_WIDTH)

            # Horizontal lines
            y = GRID_OFFSET_Y + i * CELL_SIZE
            # Glow effect
            for offset in range(3):
                alpha = 100 - offset * 30
                glow_surface = pygame.Surface((CELL_SIZE * GRID_SIZE, LINE_WIDTH + offset * 2))
                glow_surface.fill(grid_color_pulsed)
                glow_surface.set_alpha(alpha)
                self.screen.blit(glow_surface, (GRID_OFFSET_X, y - offset + LINE_WIDTH // 2))
            # Main line
            pygame.draw.line(self.screen, grid_color_pulsed, (GRID_OFFSET_X, y),
                           (GRID_OFFSET_X + CELL_SIZE * GRID_SIZE, y), LINE_WIDTH)

    def draw_marks(self):
        """Draw X's and O's with animation and glow"""
        for row in range(GRID_SIZE):
            for col in range(GRID_SIZE):
                mark = self.board[row][col]
                if mark != '':
                    center_x = GRID_OFFSET_X + col * CELL_SIZE + CELL_SIZE // 2
                    center_y = GRID_OFFSET_Y + row * CELL_SIZE + CELL_SIZE // 2

                    # Animate new marks with bounce
                    if (row, col) in self.marks_animation:
                        t = min(1.0, self.marks_animation[(row, col)] + 0.12)
                        self.marks_animation[(row, col)] = t
                        # Elastic bounce effect
                        scale = t if t < 0.5 else 1.0 - 0.2 * math.sin((t - 0.5) * 10)
                    else:
                        scale = 1.0

                    if mark == 'X':
                        self.draw_x(center_x, center_y, scale)
                    else:
                        self.draw_o(center_x, center_y, scale)

    def draw_x(self, x, y, scale=1.0):
        """Draw an X with neon glow effect"""
        size = MARK_SIZE * scale
        color = X_COLOR
        width = 8

        # Glow layers
        for glow_level in range(3):
            glow_width = width + glow_level * 4
            glow_alpha = 80 - glow_level * 25
            glow_surface = pygame.Surface((int(size * 2 + 40), int(size * 2 + 40)))
            glow_surface.fill((0, 0, 0))
            glow_surface.set_colorkey((0, 0, 0))
            offset = int(size + 20)
            pygame.draw.line(glow_surface, color,
                           (offset - size, offset - size), (offset + size, offset + size), glow_width)
            pygame.draw.line(glow_surface, color,
                           (offset + size, offset - size), (offset - size, offset + size), glow_width)
            glow_surface.set_alpha(glow_alpha)
            self.screen.blit(glow_surface, (int(x - size - 20), int(y - size - 20)))

        # Main X
        pygame.draw.line(self.screen, color, (x - size, y - size), (x + size, y + size), width)
        pygame.draw.line(self.screen, color, (x + size, y - size), (x - size, y + size), width)

    def draw_o(self, x, y, scale=1.0):
        """Draw an O with neon glow effect"""
        radius = int(MARK_SIZE * scale)
        color = O_COLOR
        width = 8

        # Glow layers
        for glow_level in range(3):
            glow_width = width + glow_level * 4
            glow_alpha = 80 - glow_level * 25
            glow_surface = pygame.Surface((radius * 2 + 40, radius * 2 + 40))
            glow_surface.fill((0, 0, 0))
            glow_surface.set_colorkey((0, 0, 0))
            pygame.draw.circle(glow_surface, color,
                             (radius + 20, radius + 20), radius + glow_level * 2, glow_width)
            glow_surface.set_alpha(glow_alpha)
            self.screen.blit(glow_surface, (int(x - radius - 20), int(y - radius - 20)))

        # Main O
        pygame.draw.circle(self.screen, color, (int(x), int(y)), radius, width)

    def draw_winning_line(self):
        """Draw the winning line with animation and glow"""
        if self.winning_line and self.winning_line_animation < 1.0:
            self.winning_line_animation = min(1.0, self.winning_line_animation + 0.08)

        if self.winning_line:
            line_type, index = self.winning_line
            width = 12

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

            # Draw glow
            for glow in range(4):
                glow_width = width + glow * 6
                glow_alpha = 100 - glow * 25
                glow_surface = pygame.Surface((WIDTH, HEIGHT))
                glow_surface.fill((0, 0, 0))
                glow_surface.set_colorkey((0, 0, 0))
                pygame.draw.line(glow_surface, WIN_LINE_COLOR,
                               (start_x, start_y), (current_end_x, current_end_y), glow_width)
                glow_surface.set_alpha(glow_alpha)
                self.screen.blit(glow_surface, (0, 0))

            # Main line
            pygame.draw.line(self.screen, WIN_LINE_COLOR, (start_x, start_y),
                           (current_end_x, current_end_y), width)

    def draw_ui(self):
        """Draw UI elements with glitch effects"""
        # Title with random glitch
        self.title_glitch_timer += 1
        if random.random() < 0.02:  # Random glitch
            title_text = "[ N3RD-T4C-T03 v2.0 ]"
        else:
            title_text = "[ NERD-TAC-TOE v2.0 ]"

        title = TITLE_FONT.render(title_text, True, TEXT_COLOR)
        title_rect = title.get_rect(center=(WIDTH // 2, 40))

        # Glow effect for title
        glow_title = TITLE_FONT.render(title_text, True, TEXT_COLOR)
        glow_title.set_alpha(100)
        self.screen.blit(glow_title, (title_rect.x + 2, title_rect.y + 2))
        self.screen.blit(title, title_rect)

        # Current player indicator with hex address
        if not self.game_over:
            player_text = f"> PLAYER [{self.current_player}] :: 0x{hash(self.current_player) & 0xFFFF:04X}"
            player_color = X_COLOR if self.current_player == 'X' else O_COLOR
            player_surface = SCORE_FONT.render(player_text, True, player_color)
            player_rect = player_surface.get_rect(center=(WIDTH // 2, 90))
            self.screen.blit(player_surface, player_rect)

        # Scores with binary representation
        score_y = HEIGHT - 60
        x_score = SCORE_FONT.render(f"[X]: {self.scores['X']:03d}", True, X_COLOR)
        o_score = SCORE_FONT.render(f"[O]: {self.scores['O']:03d}", True, O_COLOR)
        draw_score = SCORE_FONT.render(f"[DRAW]: {self.scores['Draw']:03d}", True, SECONDARY_TEXT)

        self.screen.blit(x_score, (40, score_y))
        self.screen.blit(o_score, (240, score_y))
        self.screen.blit(draw_score, (420, score_y))

        # Keyboard hints
        hint1 = HINT_FONT.render("[SPACE] = RESTART", True, SECONDARY_TEXT)
        hint2 = HINT_FONT.render("[Q] = QUIT", True, SECONDARY_TEXT)
        self.screen.blit(hint1, (10, HEIGHT - 25))
        self.screen.blit(hint2, (WIDTH - 130, HEIGHT - 25))

    def draw_game_over(self):
        """Draw game over screen with animations"""
        if self.game_over:
            # Pulsing overlay
            pulse = (math.sin(self.animation_progress) + 1) / 2
            overlay = pygame.Surface((WIDTH, HEIGHT), pygame.SRCALPHA)
            overlay.fill((*BG_COLOR, int(200 + pulse * 50)))
            self.screen.blit(overlay, (0, 0))

            # Winner text with glitch
            if self.winner == 'Draw':
                text = ">>> SYSTEM DEADLOCK <<<"
                color = SECONDARY_TEXT
            else:
                text = f">>> PLAYER [{self.winner}] WINS <<<"
                color = X_COLOR if self.winner == 'X' else O_COLOR

            # Animated typing effect
            self.animation_progress += 0.1

            winner_surface = WINNER_FONT.render(text, True, color)
            winner_rect = winner_surface.get_rect(center=(WIDTH // 2, HEIGHT // 2 - 50))

            # Glow
            for i in range(3):
                glow_alpha = 50 - i * 15
                glow = WINNER_FONT.render(text, True, color)
                glow.set_alpha(glow_alpha)
                self.screen.blit(glow, (winner_rect.x + i, winner_rect.y + i))

            self.screen.blit(winner_surface, winner_rect)

            # Play again button with hex styling
            button_rect = pygame.Rect(WIDTH // 2 - 120, HEIGHT // 2 + 20, 240, 50)
            mouse_pos = pygame.mouse.get_pos()
            button_color = BUTTON_HOVER_COLOR if button_rect.collidepoint(mouse_pos) else BUTTON_COLOR

            # Button glow on hover
            if button_rect.collidepoint(mouse_pos):
                glow_surf = pygame.Surface((250, 60))
                glow_surf.fill(O_COLOR)
                glow_surf.set_alpha(30)
                self.screen.blit(glow_surf, (WIDTH // 2 - 125, HEIGHT // 2 + 15))

            pygame.draw.rect(self.screen, button_color, button_rect, border_radius=10)
            pygame.draw.rect(self.screen, TEXT_COLOR, button_rect, 2, border_radius=10)

            button_text = BUTTON_FONT.render("[ RESTART ]", True, TEXT_COLOR)
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

    def apply_screen_shake(self):
        """Apply screen shake effect"""
        if self.screen_shake > 0:
            self.screen_shake -= 1
            offset_x = random.randint(-self.screen_shake, self.screen_shake)
            offset_y = random.randint(-self.screen_shake, self.screen_shake)
            return offset_x, offset_y
        return 0, 0

    def run(self):
        """Main game loop"""
        running = True

        while running:
            self.clock.tick(FPS)

            # Event handling
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False

                elif event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_q:
                        # Q to quit
                        running = False
                    elif event.key == pygame.K_SPACE:
                        # SPACE to restart
                        self.reset_board()

                elif event.type == pygame.MOUSEMOTION:
                    self.hover_cell = self.get_cell_from_mouse(event.pos)

                elif event.type == pygame.MOUSEBUTTONDOWN:
                    if self.game_over:
                        # Check if play again button was clicked
                        button_rect = pygame.Rect(WIDTH // 2 - 120, HEIGHT // 2 + 20, 240, 50)
                        if button_rect.collidepoint(event.pos):
                            self.reset_board()
                    else:
                        cell = self.get_cell_from_mouse(event.pos)
                        if cell:
                            row, col = cell
                            self.make_move(row, col)

            # Drawing
            self.screen.fill(BG_COLOR)

            # Background effects
            self.draw_background_effects()

            # Main game
            self.draw_grid()
            self.draw_marks()
            self.draw_winning_line()
            self.update_particles()
            self.draw_ui()

            play_again_button = self.draw_game_over()

            # Apply glitch effect
            self.glitch.update()
            self.glitch.apply(self.screen)

            # Screen shake
            shake_x, shake_y = self.apply_screen_shake()
            if shake_x != 0 or shake_y != 0:
                # Create a copy and shift it
                temp_surf = self.screen.copy()
                self.screen.fill(BG_COLOR)
                self.screen.blit(temp_surf, (shake_x, shake_y))

            pygame.display.flip()

        pygame.quit()
        sys.exit()


def main():
    """Main entry point"""
    game = TicTacToe()
    game.run()


if __name__ == "__main__":
    main()
