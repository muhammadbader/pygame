import pygame
import random
import sys
import math

# ---------------------------
# Configuration
# ---------------------------
WORDS = [
    # Basic Islamic terms
    "islam", "quran", "muhammad", "prayer", "ramadan",
    "mosque", "prophet", "ummah", "sunnah", "salah",
    "deen", "iman", "hajj", "zakat", "sadaqah", "adhan", "taqwa", "jannah",
    
    # Historical Islamic terms
    "andalus", "abbasid", "umayyad", "ottoman", "fatimid",
    "cordoba", "baghdad", "damascus", "mecca", "medina",
    "khilafah", "mamluk", "sultans", "granada", "caliphate",
    "samarkand", "ayyubid", "seljuks", "almohad", "mughals"
]

# Modern Minimalist Color Palette - Iconic Design
BG_DARK = (18, 18, 20)
BG_MID = (28, 28, 32)
BG_LIGHT = (38, 38, 42)
ACCENT_PRIMARY = (0, 122, 255)  # Apple Blue
ACCENT_SUCCESS = (52, 199, 89)  # Green
ACCENT_DANGER = (255, 69, 58)   # Red
ACCENT_WARNING = (255, 159, 10) # Orange
ACCENT_PURPLE = (191, 90, 242)  # Purple
WHITE = (255, 255, 255)
LIGHT_GRAY = (142, 142, 147)
DARK_GRAY = (72, 72, 74)
GOLD = (255, 204, 0)

# Screen settings
WIDTH = 1400
HEIGHT = 900
FPS = 60

# ---------------------------
# Particle Class for Visual Effects
# ---------------------------
class Particle:
    def __init__(self, x, y, color, velocity):
        self.x = x
        self.y = y
        self.color = color
        self.velocity = velocity
        self.lifetime = 40
        self.max_lifetime = 40
        self.size = random.randint(3, 7)

    def update(self):
        self.x += self.velocity[0]
        self.y += self.velocity[1]
        self.velocity = (self.velocity[0] * 0.96, self.velocity[1] + 0.15)
        self.lifetime -= 1

    def draw(self, screen):
        alpha = int(255 * (self.lifetime / self.max_lifetime))
        size = max(1, int(self.size * (self.lifetime / self.max_lifetime)))

        s = pygame.Surface((size * 2, size * 2), pygame.SRCALPHA)
        pygame.draw.circle(s, (*self.color, alpha), (size, size), size)
        screen.blit(s, (int(self.x - size), int(self.y - size)))

    def is_dead(self):
        return self.lifetime <= 0

# ---------------------------
# Game Class
# ---------------------------
class HangmanGame:
    def __init__(self):
        pygame.init()
        self.screen = pygame.display.set_mode((WIDTH, HEIGHT))
        pygame.display.set_caption("HANGMAN")
        self.clock = pygame.time.Clock()

        # Fonts
        self.font_massive = pygame.font.Font(None, 110)
        self.font_title = pygame.font.Font(None, 90)
        self.font_large = pygame.font.Font(None, 72)
        self.font_medium = pygame.font.Font(None, 44)
        self.font_small = pygame.font.Font(None, 32)
        self.font_tiny = pygame.font.Font(None, 24)

        # Game state
        self.particles = []
        self.animation_timer = 0
        self.letter_reveal_timers = {}
        self.score = 0
        self.streak = 0
        self.best_streak = 0

        self.reset_game()

    def reset_game(self):
        """Reset game to initial state."""
        self.word = random.choice(WORDS).upper()
        self.guessed_letters = set()
        self.tries = 6
        self.word_display = ["_"] * len(self.word)
        self.game_over = False
        self.won = False
        self.message = "Press any letter to guess"
        self.message_color = LIGHT_GRAY
        self.shake_intensity = 0

    def create_particles(self, x, y, color, count=15):
        """Create particle explosion effect."""
        for _ in range(count):
            angle = random.uniform(0, 2 * math.pi)
            speed = random.uniform(2, 6)
            velocity = (math.cos(angle) * speed, math.sin(angle) * speed)
            self.particles.append(Particle(x, y, color, velocity))

    def draw_modern_panel(self, rect, bg_color=BG_MID, border_color=None, border_width=0):
        """Draw a clean modern panel."""
        # Panel background
        pygame.draw.rect(self.screen, bg_color, rect, border_radius=16)

        # Optional border
        if border_color and border_width > 0:
            pygame.draw.rect(self.screen, border_color, rect, border_width, border_radius=16)

    def draw_text(self, text, font, color, x, y, center=True):
        """Draw text with optional shadow."""
        text_surf = font.render(text, True, color)
        if center:
            text_rect = text_surf.get_rect(center=(x, y))
        else:
            text_rect = text_surf.get_rect(topleft=(x, y))
        self.screen.blit(text_surf, text_rect)
        return text_rect

    def draw_hangman(self):
        """Draw minimalist hangman."""
        base_x = 250
        base_y = 700

        # Modern gallows with subtle gradients
        # Base
        pygame.draw.line(self.screen, DARK_GRAY, (base_x - 70, base_y), (base_x + 70, base_y), 8)
        pygame.draw.line(self.screen, LIGHT_GRAY, (base_x - 70, base_y - 2), (base_x + 70, base_y - 2), 3)

        # Vertical pole
        pygame.draw.line(self.screen, DARK_GRAY, (base_x, base_y), (base_x, base_y - 380), 8)
        pygame.draw.line(self.screen, LIGHT_GRAY, (base_x - 2, base_y), (base_x - 2, base_y - 380), 3)

        # Top horizontal
        pygame.draw.line(self.screen, DARK_GRAY, (base_x, base_y - 380), (base_x + 160, base_y - 380), 8)
        pygame.draw.line(self.screen, LIGHT_GRAY, (base_x, base_y - 382), (base_x + 160, base_y - 382), 3)

        # Rope
        for i in range(5):
            y_pos = base_y - 380 + i * 12
            pygame.draw.line(self.screen, LIGHT_GRAY,
                           (base_x + 160, y_pos), (base_x + 160, y_pos + 10), 4)

        wrong_guesses = 6 - self.tries
        hang_x = base_x + 160
        head_y = base_y - 310

        # Apply shake
        shake_x = random.randint(-self.shake_intensity, self.shake_intensity)
        shake_y = random.randint(-self.shake_intensity, self.shake_intensity)

        if wrong_guesses >= 1:  # Head
            pygame.draw.circle(self.screen, BG_LIGHT, (hang_x + shake_x, head_y + shake_y), 38)
            pygame.draw.circle(self.screen, ACCENT_DANGER, (hang_x + shake_x, head_y + shake_y), 38, 4)

            # Minimal face
            pygame.draw.circle(self.screen, LIGHT_GRAY, (hang_x - 12 + shake_x, head_y - 8 + shake_y), 4)
            pygame.draw.circle(self.screen, LIGHT_GRAY, (hang_x + 12 + shake_x, head_y - 8 + shake_y), 4)
            pygame.draw.arc(self.screen, LIGHT_GRAY,
                          pygame.Rect(hang_x - 16 + shake_x, head_y + 8 + shake_y, 32, 20),
                          math.pi, 2 * math.pi, 3)

        if wrong_guesses >= 2:  # Body
            pygame.draw.line(self.screen, ACCENT_DANGER,
                           (hang_x + shake_x, head_y + 38 + shake_y),
                           (hang_x + shake_x, head_y + 140 + shake_y), 6)

        if wrong_guesses >= 3:  # Left arm
            pygame.draw.line(self.screen, ACCENT_DANGER,
                           (hang_x + shake_x, head_y + 60 + shake_y),
                           (hang_x - 50 + shake_x, head_y + 110 + shake_y), 6)

        if wrong_guesses >= 4:  # Right arm
            pygame.draw.line(self.screen, ACCENT_DANGER,
                           (hang_x + shake_x, head_y + 60 + shake_y),
                           (hang_x + 50 + shake_x, head_y + 110 + shake_y), 6)

        if wrong_guesses >= 5:  # Left leg
            pygame.draw.line(self.screen, ACCENT_DANGER,
                           (hang_x + shake_x, head_y + 140 + shake_y),
                           (hang_x - 45 + shake_x, head_y + 210 + shake_y), 6)

        if wrong_guesses >= 6:  # Right leg
            pygame.draw.line(self.screen, ACCENT_DANGER,
                           (hang_x + shake_x, head_y + 140 + shake_y),
                           (hang_x + 45 + shake_x, head_y + 210 + shake_y), 6)

        if self.shake_intensity > 0:
            self.shake_intensity -= 1

    def draw_word(self):
        """Draw word with clean letter boxes."""
        panel_rect = pygame.Rect(550, 200, 800, 160)
        self.draw_modern_panel(panel_rect, BG_MID)

        # Title
        self.draw_text("WORD", self.font_medium, LIGHT_GRAY, 590, 240, center=False)

        # Letter boxes
        total_letters = len(self.word_display)
        box_size = 65
        spacing = 18
        total_width = (box_size + spacing) * total_letters - spacing
        start_x = 550 + (800 - total_width) // 2

        for i, letter in enumerate(self.word_display):
            x = start_x + i * (box_size + spacing)
            y = 275

            # Animation
            if letter != "_" and i in self.letter_reveal_timers:
                scale = min(1.15, self.letter_reveal_timers[i] / 10.0)
                size = int(box_size * scale)
                offset = (box_size - size) // 2
            else:
                size = box_size
                offset = 0

            box_rect = pygame.Rect(x + offset, y + offset, size, size)

            if letter == "_":
                # Empty box - very clean
                pygame.draw.rect(self.screen, BG_DARK, box_rect, border_radius=12)
                pygame.draw.rect(self.screen, DARK_GRAY, box_rect, 2, border_radius=12)
            else:
                # Filled box - white background with accent border
                pygame.draw.rect(self.screen, WHITE, box_rect, border_radius=12)
                pygame.draw.rect(self.screen, ACCENT_PRIMARY, box_rect, 3, border_radius=12)

                # Letter in dark color for perfect readability
                letter_surf = self.font_large.render(letter, True, BG_DARK)
                letter_rect = letter_surf.get_rect(center=box_rect.center)
                self.screen.blit(letter_surf, letter_rect)

        # Update timers
        for key in list(self.letter_reveal_timers.keys()):
            self.letter_reveal_timers[key] += 1
            if self.letter_reveal_timers[key] > 15:
                del self.letter_reveal_timers[key]

    def draw_stats_panel(self):
        """Draw stats in top left."""
        panel_rect = pygame.Rect(30, 30, 450, 130)
        self.draw_modern_panel(panel_rect, BG_MID)

        # Streak
        streak_icon = "🔥" if self.streak > 0 else "—"
        self.draw_text(f"{streak_icon} Streak: {self.streak}", self.font_small,
                      ACCENT_WARNING if self.streak > 0 else LIGHT_GRAY, 60, 65, center=False)

        # Best
        self.draw_text(f"Best: {self.best_streak}", self.font_tiny, LIGHT_GRAY, 60, 100, center=False)

        # Score
        score_color = ACCENT_PRIMARY if self.score > 0 else LIGHT_GRAY
        self.draw_text(f"Score: {self.score}", self.font_medium, score_color, 360, 80, center=False)

    def draw_lives(self):
        """Draw lives with clean indicators."""
        panel_rect = pygame.Rect(550, 390, 800, 110)

        color = ACCENT_SUCCESS if self.tries > 2 else ACCENT_DANGER
        self.draw_modern_panel(panel_rect, BG_MID, color, 2)

        self.draw_text("LIVES", self.font_medium, color, 590, 430, center=False)

        # Simple circle indicators
        start_x = 730
        for i in range(6):
            x = start_x + i * 70
            y = 445

            if i < self.tries:
                # Filled circle
                pygame.draw.circle(self.screen, color, (x, y), 16)
            else:
                # Empty circle
                pygame.draw.circle(self.screen, DARK_GRAY, (x, y), 16)
                pygame.draw.circle(self.screen, BG_DARK, (x, y), 12)

    def draw_guessed_letters(self):
        """Draw guessed letters panel."""
        panel_rect = pygame.Rect(550, 530, 800, 100)
        self.draw_modern_panel(panel_rect, BG_MID)

        self.draw_text("GUESSED", self.font_medium, LIGHT_GRAY, 590, 565, center=False)

        if self.guessed_letters:
            letters = "  ".join(sorted(self.guessed_letters))
        else:
            letters = "None"

        self.draw_text(letters, self.font_small, WHITE, 950, 580)

    def draw_message(self):
        """Draw message."""
        panel_rect = pygame.Rect(550, 660, 800, 90)
        self.draw_modern_panel(panel_rect, BG_MID)

        self.draw_text(self.message, self.font_small, self.message_color, 950, 705)

    def draw_title(self):
        """Draw title."""
        self.draw_text("HANGMAN", self.font_massive, WHITE, WIDTH // 2, 90)

        # Subtle accent line
        line_width = 200
        line_x = WIDTH // 2 - line_width // 2
        pygame.draw.rect(self.screen, ACCENT_PRIMARY,
                        pygame.Rect(line_x, 140, line_width, 3), border_radius=2)

    def draw_game_over(self):
        """Draw clean game over screen."""
        # Overlay
        overlay = pygame.Surface((WIDTH, HEIGHT), pygame.SRCALPHA)
        overlay.fill((0, 0, 0, 220))
        self.screen.blit(overlay, (0, 0))

        # Panel
        panel_rect = pygame.Rect(350, 280, 700, 380)
        self.draw_modern_panel(panel_rect, BG_DARK,
                             ACCENT_SUCCESS if self.won else ACCENT_DANGER, 3)

        if self.won:
            # Victory
            self.draw_text("VICTORY!", self.font_massive, ACCENT_SUCCESS, WIDTH // 2, 370)

            message = f"Word: {self.word}"
            self.draw_text(message, self.font_medium, WHITE, WIDTH // 2, 470)

            bonus = self.tries * 100
            bonus_text = f"+{bonus} Points"
            self.draw_text(bonus_text, self.font_small, GOLD, WIDTH // 2, 530)
        else:
            # Defeat
            self.draw_text("GAME OVER", self.font_massive, ACCENT_DANGER, WIDTH // 2, 370)

            message = f"Word was: {self.word}"
            self.draw_text(message, self.font_medium, WHITE, WIDTH // 2, 480)

        # Instructions
        self.draw_text("Press SPACE to play again", self.font_small, LIGHT_GRAY, WIDTH // 2, 600)

    def handle_guess(self, letter):
        """Handle letter guess."""
        if self.game_over:
            return

        letter = letter.upper()

        if not letter.isalpha() or len(letter) != 1:
            return

        if letter in self.guessed_letters:
            self.message = "Already guessed!"
            self.message_color = ACCENT_WARNING
            self.shake_intensity = 5
            return

        self.guessed_letters.add(letter)

        if letter in self.word:
            # Correct
            self.message = "Good guess!"
            self.message_color = ACCENT_SUCCESS

            for i, char in enumerate(self.word):
                if char == letter:
                    self.word_display[i] = letter
                    self.letter_reveal_timers[i] = 0

                    # Subtle particles
                    x = 550 + (800 // 2) + (i - len(self.word) // 2) * 83
                    y = 305
                    self.create_particles(x, y, ACCENT_SUCCESS, 10)

            if "_" not in self.word_display:
                self.game_over = True
                self.won = True
                self.streak += 1
                self.best_streak = max(self.best_streak, self.streak)

                bonus = self.tries * 100
                self.score += bonus

                # Victory particles
                for _ in range(50):
                    x = random.randint(0, WIDTH)
                    y = random.randint(0, HEIGHT)
                    self.create_particles(x, y, ACCENT_SUCCESS, 3)
        else:
            # Wrong
            self.message = "Wrong guess!"
            self.message_color = ACCENT_DANGER
            self.tries -= 1
            self.shake_intensity = 8

            # Red particles
            self.create_particles(250, 400, ACCENT_DANGER, 15)

            if self.tries <= 0:
                self.game_over = True
                self.won = False
                self.word_display = list(self.word)
                self.streak = 0

    def update_particles(self):
        """Update particles."""
        for particle in self.particles[:]:
            particle.update()
            if particle.is_dead():
                self.particles.remove(particle)

    def draw_particles(self):
        """Draw all particles."""
        for particle in self.particles:
            particle.draw(self.screen)

    def draw(self):
        """Main draw function."""
        self.screen.fill(BG_DARK)

        self.draw_title()
        self.draw_stats_panel()
        self.draw_word()
        self.draw_lives()
        self.draw_guessed_letters()
        self.draw_message()
        self.draw_hangman()

        self.draw_particles()

        if self.game_over:
            self.draw_game_over()

        pygame.display.flip()
        self.animation_timer += 1

    def handle_events(self):
        """Handle events."""
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                return False

            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    return False

                if self.game_over:
                    if event.key == pygame.K_SPACE:
                        self.reset_game()
                else:
                    if event.unicode.isalpha():
                        self.handle_guess(event.unicode)

        return True

    def run(self):
        """Main game loop."""
        running = True
        while running:
            self.clock.tick(FPS)
            running = self.handle_events()
            self.update_particles()
            self.draw()

        pygame.quit()
        sys.exit()

# ---------------------------
# Run Game
# ---------------------------
if __name__ == "__main__":
    game = HangmanGame()
    game.run()
