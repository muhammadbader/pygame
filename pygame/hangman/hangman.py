import pygame
import random
import sys
import math

# ---------------------------
# Configuration
# ---------------------------
WORDS = [
    "python", "robotics", "artificial", "machine", "learning",
    "flutter", "developer", "science", "technology", "computer"
]

# Modern Color Palette - EA Style
DARK_BG = (15, 20, 35)
MID_BG = (25, 35, 55)
LIGHT_BG = (40, 50, 75)
ACCENT_BLUE = (41, 128, 185)
ACCENT_CYAN = (52, 152, 219)
ACCENT_GREEN = (46, 204, 113)
ACCENT_RED = (231, 76, 60)
ACCENT_ORANGE = (230, 126, 34)
ACCENT_PURPLE = (155, 89, 182)
GOLD = (241, 196, 15)
WHITE = (255, 255, 255)
LIGHT_GRAY = (189, 195, 199)
DARK_GRAY = (52, 73, 94)

# Screen settings
WIDTH = 1200
HEIGHT = 800
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
        self.lifetime = 60
        self.max_lifetime = 60
        self.size = random.randint(3, 8)

    def update(self):
        self.x += self.velocity[0]
        self.y += self.velocity[1]
        self.velocity = (self.velocity[0] * 0.98, self.velocity[1] + 0.2)  # Gravity
        self.lifetime -= 1

    def draw(self, screen):
        alpha = int(255 * (self.lifetime / self.max_lifetime))
        size = int(self.size * (self.lifetime / self.max_lifetime))
        if size > 0:
            s = pygame.Surface((size * 2, size * 2), pygame.SRCALPHA)
            color_with_alpha = (*self.color, alpha)
            pygame.draw.circle(s, color_with_alpha, (size, size), size)
            screen.blit(s, (int(self.x - size), int(self.y - size)))

    def is_dead(self):
        return self.lifetime <= 0

# ---------------------------
# Button Class
# ---------------------------
class Button:
    def __init__(self, x, y, width, height, text, color, hover_color):
        self.rect = pygame.Rect(x, y, width, height)
        self.text = text
        self.color = color
        self.hover_color = hover_color
        self.current_color = color
        self.is_hovered = False

    def update(self, mouse_pos):
        self.is_hovered = self.rect.collidepoint(mouse_pos)
        self.current_color = self.hover_color if self.is_hovered else self.color

    def draw(self, screen, font):
        # Draw shadow
        shadow_rect = self.rect.copy()
        shadow_rect.y += 4
        pygame.draw.rect(screen, (0, 0, 0, 100), shadow_rect, border_radius=10)

        # Draw button
        pygame.draw.rect(screen, self.current_color, self.rect, border_radius=10)
        pygame.draw.rect(screen, WHITE, self.rect, 2, border_radius=10)

        # Draw text
        text_surf = font.render(self.text, True, WHITE)
        text_rect = text_surf.get_rect(center=self.rect.center)
        screen.blit(text_surf, text_rect)

    def is_clicked(self, mouse_pos, mouse_pressed):
        return self.is_hovered and mouse_pressed[0]

# ---------------------------
# Game Class
# ---------------------------
class HangmanGame:
    def __init__(self):
        pygame.init()
        self.screen = pygame.display.set_mode((WIDTH, HEIGHT))
        pygame.display.set_caption("HANGMAN - Elite Edition")
        self.clock = pygame.time.Clock()

        # Fonts
        self.font_title = pygame.font.Font(None, 96)
        self.font_large = pygame.font.Font(None, 80)
        self.font_medium = pygame.font.Font(None, 48)
        self.font_small = pygame.font.Font(None, 36)
        self.font_tiny = pygame.font.Font(None, 28)

        # Game state
        self.particles = []
        self.animation_timer = 0
        self.letter_reveal_timers = {}
        self.score = 0
        self.games_played = 0

        self.reset_game()

    def reset_game(self):
        """Reset game to initial state."""
        self.word = random.choice(WORDS).upper()
        self.guessed_letters = set()
        self.tries = 6
        self.word_display = ["_"] * len(self.word)
        self.game_over = False
        self.won = False
        self.message = "Press any letter to start guessing!"
        self.message_color = LIGHT_GRAY
        self.animation_timer = 0
        self.shake_offset = 0
        self.shake_intensity = 0
        self.pulse_scale = 1.0
        self.games_played += 1

    def create_particles(self, x, y, color, count=20):
        """Create particle explosion effect."""
        for _ in range(count):
            angle = random.uniform(0, 2 * math.pi)
            speed = random.uniform(2, 8)
            velocity = (math.cos(angle) * speed, math.sin(angle) * speed)
            self.particles.append(Particle(x, y, color, velocity))

    def draw_gradient_background(self):
        """Draw a gradient background."""
        for y in range(HEIGHT):
            progress = y / HEIGHT
            r = int(DARK_BG[0] + (MID_BG[0] - DARK_BG[0]) * progress)
            g = int(DARK_BG[1] + (MID_BG[1] - DARK_BG[1]) * progress)
            b = int(DARK_BG[2] + (MID_BG[2] - DARK_BG[2]) * progress)
            pygame.draw.line(self.screen, (r, g, b), (0, y), (WIDTH, y))

    def draw_panel(self, rect, color=MID_BG, border_color=ACCENT_BLUE):
        """Draw a modern UI panel with shadow and border."""
        # Shadow
        shadow = pygame.Surface((rect.width + 10, rect.height + 10), pygame.SRCALPHA)
        pygame.draw.rect(shadow, (0, 0, 0, 80), shadow.get_rect(), border_radius=15)
        self.screen.blit(shadow, (rect.x - 5, rect.y + 5))

        # Panel
        pygame.draw.rect(self.screen, color, rect, border_radius=15)
        pygame.draw.rect(self.screen, border_color, rect, 3, border_radius=15)

    def draw_text_with_shadow(self, text, font, color, x, y, center=True, shadow_offset=3):
        """Draw text with shadow effect."""
        # Shadow
        shadow_surf = font.render(text, True, (0, 0, 0))
        shadow_rect = shadow_surf.get_rect(center=(x + shadow_offset, y + shadow_offset)) if center else shadow_surf.get_rect(topleft=(x + shadow_offset, y + shadow_offset))
        self.screen.blit(shadow_surf, shadow_rect)

        # Text
        text_surf = font.render(text, True, color)
        text_rect = text_surf.get_rect(center=(x, y)) if center else text_surf.get_rect(topleft=(x, y))
        self.screen.blit(text_surf, text_rect)

        return text_rect

    def draw_glowing_text(self, text, font, color, x, y, glow_color=None):
        """Draw text with glow effect."""
        if glow_color is None:
            glow_color = color

        # Glow layers
        for offset in range(8, 0, -2):
            alpha = int(100 * (offset / 8))
            glow_surf = font.render(text, True, glow_color)
            glow_surf.set_alpha(alpha)
            for dx, dy in [(-offset, 0), (offset, 0), (0, -offset), (0, offset)]:
                glow_rect = glow_surf.get_rect(center=(x + dx, y + dy))
                self.screen.blit(glow_surf, glow_rect)

        # Main text
        text_surf = font.render(text, True, color)
        text_rect = text_surf.get_rect(center=(x, y))
        self.screen.blit(text_surf, text_rect)

    def draw_hangman(self):
        """Draw enhanced hangman with modern graphics."""
        base_x = 250
        base_y = 600

        # Draw platform shadow
        shadow_surf = pygame.Surface((150, 10), pygame.SRCALPHA)
        pygame.draw.ellipse(shadow_surf, (0, 0, 0, 80), shadow_surf.get_rect())
        self.screen.blit(shadow_surf, (base_x - 75, base_y + 10))

        # Gallows with gradient effect
        # Base
        pygame.draw.line(self.screen, DARK_GRAY, (base_x - 60, base_y), (base_x + 60, base_y), 10)
        pygame.draw.line(self.screen, LIGHT_GRAY, (base_x - 60, base_y - 2), (base_x + 60, base_y - 2), 4)

        # Vertical pole
        pygame.draw.line(self.screen, DARK_GRAY, (base_x, base_y), (base_x, base_y - 350), 10)
        pygame.draw.line(self.screen, LIGHT_GRAY, (base_x - 3, base_y), (base_x - 3, base_y - 350), 4)

        # Top horizontal
        pygame.draw.line(self.screen, DARK_GRAY, (base_x, base_y - 350), (base_x + 150, base_y - 350), 10)
        pygame.draw.line(self.screen, LIGHT_GRAY, (base_x, base_y - 352), (base_x + 150, base_y - 352), 4)

        # Rope
        for i in range(5):
            y_offset = i * 12
            pygame.draw.line(self.screen, ACCENT_ORANGE,
                           (base_x + 150, base_y - 350 + y_offset),
                           (base_x + 150, base_y - 350 + y_offset + 10), 6)

        wrong_guesses = 6 - self.tries
        hang_x = base_x + 150
        head_y = base_y - 250

        # Apply shake effect when losing tries
        shake_x = random.randint(-self.shake_intensity, self.shake_intensity)
        shake_y = random.randint(-self.shake_intensity, self.shake_intensity)

        if wrong_guesses >= 1:  # Head
            # Glow effect for head
            for radius in range(45, 35, -2):
                alpha = int(50 * ((45 - radius) / 10))
                s = pygame.Surface((radius * 2, radius * 2), pygame.SRCALPHA)
                pygame.draw.circle(s, (*ACCENT_RED, alpha), (radius, radius), radius)
                self.screen.blit(s, (hang_x + shake_x - radius, head_y + shake_y - radius))

            pygame.draw.circle(self.screen, WHITE, (hang_x + shake_x, head_y + shake_y), 40, 0)
            pygame.draw.circle(self.screen, ACCENT_RED, (hang_x + shake_x, head_y + shake_y), 40, 5)

            # Face details
            # Eyes
            pygame.draw.circle(self.screen, DARK_BG, (hang_x - 12 + shake_x, head_y - 5 + shake_y), 5)
            pygame.draw.circle(self.screen, DARK_BG, (hang_x + 12 + shake_x, head_y - 5 + shake_y), 5)
            # Sad mouth
            pygame.draw.arc(self.screen, DARK_BG,
                          pygame.Rect(hang_x - 15 + shake_x, head_y + 10 + shake_y, 30, 20),
                          math.pi, 2 * math.pi, 3)

        if wrong_guesses >= 2:  # Body
            pygame.draw.line(self.screen, ACCENT_RED,
                           (hang_x + shake_x, head_y + 40 + shake_y),
                           (hang_x + shake_x, head_y + 140 + shake_y), 8)

        if wrong_guesses >= 3:  # Left arm
            pygame.draw.line(self.screen, ACCENT_RED,
                           (hang_x + shake_x, head_y + 60 + shake_y),
                           (hang_x - 50 + shake_x, head_y + 110 + shake_y), 8)

        if wrong_guesses >= 4:  # Right arm
            pygame.draw.line(self.screen, ACCENT_RED,
                           (hang_x + shake_x, head_y + 60 + shake_y),
                           (hang_x + 50 + shake_x, head_y + 110 + shake_y), 8)

        if wrong_guesses >= 5:  # Left leg
            pygame.draw.line(self.screen, ACCENT_RED,
                           (hang_x + shake_x, head_y + 140 + shake_y),
                           (hang_x - 45 + shake_x, head_y + 210 + shake_y), 8)

        if wrong_guesses >= 6:  # Right leg
            pygame.draw.line(self.screen, ACCENT_RED,
                           (hang_x + shake_x, head_y + 140 + shake_y),
                           (hang_x + 45 + shake_x, head_y + 210 + shake_y), 8)

        # Reduce shake over time
        if self.shake_intensity > 0:
            self.shake_intensity -= 1

    def draw_word(self):
        """Draw word with animated letter boxes."""
        panel_rect = pygame.Rect(500, 150, 650, 120)
        self.draw_panel(panel_rect, LIGHT_BG, ACCENT_CYAN)

        # Title
        self.draw_text_with_shadow("WORD", self.font_small, ACCENT_CYAN, 525, 180, center=False)

        # Calculate letter spacing
        total_letters = len(self.word_display)
        box_size = 60
        spacing = 15
        total_width = (box_size + spacing) * total_letters - spacing
        start_x = 500 + (650 - total_width) // 2

        for i, letter in enumerate(self.word_display):
            x = start_x + i * (box_size + spacing)
            y = 210

            # Animated reveal
            if letter != "_" and i in self.letter_reveal_timers:
                scale = min(1.0, self.letter_reveal_timers[i] / 10.0)
                size = int(box_size * scale)
                offset = (box_size - size) // 2
            else:
                size = box_size
                offset = 0

            # Letter box
            box_rect = pygame.Rect(x + offset, y + offset, size, size)

            if letter == "_":
                pygame.draw.rect(self.screen, MID_BG, box_rect, border_radius=8)
                pygame.draw.rect(self.screen, DARK_GRAY, box_rect, 3, border_radius=8)
            else:
                pygame.draw.rect(self.screen, ACCENT_CYAN, box_rect, border_radius=8)
                pygame.draw.rect(self.screen, WHITE, box_rect, 3, border_radius=8)

                # Letter
                letter_surf = self.font_medium.render(letter, True, WHITE)
                letter_rect = letter_surf.get_rect(center=box_rect.center)
                self.screen.blit(letter_surf, letter_rect)

        # Update timers
        for key in list(self.letter_reveal_timers.keys()):
            self.letter_reveal_timers[key] += 1
            if self.letter_reveal_timers[key] > 10:
                del self.letter_reveal_timers[key]

    def draw_guessed_letters(self):
        """Draw guessed letters in a modern panel."""
        panel_rect = pygame.Rect(500, 300, 650, 100)
        self.draw_panel(panel_rect, LIGHT_BG, ACCENT_PURPLE)

        # Title
        self.draw_text_with_shadow("GUESSED LETTERS", self.font_small, ACCENT_PURPLE, 525, 325, center=False)

        # Letters
        if self.guessed_letters:
            letters_str = "  ".join(sorted(self.guessed_letters))
        else:
            letters_str = "None yet..."

        self.draw_text_with_shadow(letters_str, self.font_small, WHITE, 825, 360)

    def draw_tries(self):
        """Draw remaining tries with visual indicator."""
        panel_rect = pygame.Rect(500, 430, 300, 100)

        if self.tries <= 2:
            self.draw_panel(panel_rect, LIGHT_BG, ACCENT_RED)
            color = ACCENT_RED
        else:
            self.draw_panel(panel_rect, LIGHT_BG, ACCENT_GREEN)
            color = ACCENT_GREEN

        # Title
        self.draw_text_with_shadow("LIVES", self.font_small, color, 525, 455, center=False)

        # Draw hearts
        heart_y = 485
        for i in range(6):
            heart_x = 540 + i * 40
            if i < self.tries:
                # Filled heart
                pygame.draw.circle(self.screen, ACCENT_RED, (heart_x - 5, heart_y), 8)
                pygame.draw.circle(self.screen, ACCENT_RED, (heart_x + 5, heart_y), 8)
                pygame.draw.polygon(self.screen, ACCENT_RED, [
                    (heart_x - 12, heart_y),
                    (heart_x, heart_y + 15),
                    (heart_x + 12, heart_y)
                ])
            else:
                # Empty heart
                pygame.draw.circle(self.screen, DARK_GRAY, (heart_x - 5, heart_y), 8, 2)
                pygame.draw.circle(self.screen, DARK_GRAY, (heart_x + 5, heart_y), 8, 2)
                pygame.draw.polygon(self.screen, DARK_GRAY, [
                    (heart_x - 12, heart_y),
                    (heart_x, heart_y + 15),
                    (heart_x + 12, heart_y)
                ], 2)

    def draw_score(self):
        """Draw score panel."""
        panel_rect = pygame.Rect(830, 430, 320, 100)
        self.draw_panel(panel_rect, LIGHT_BG, GOLD)

        # Title
        self.draw_text_with_shadow("SCORE", self.font_small, GOLD, 855, 455, center=False)

        # Score value
        score_text = f"{self.score}"
        self.draw_glowing_text(score_text, self.font_large, GOLD, 990, 485, GOLD)

    def draw_message(self):
        """Draw message with animation."""
        # Pulse effect for message
        self.pulse_scale = 1.0 + 0.05 * math.sin(self.animation_timer * 0.1)

        panel_rect = pygame.Rect(500, 560, 650, 80)
        self.draw_panel(panel_rect, LIGHT_BG, self.message_color)

        # Scale text
        scaled_font_size = int(36 * self.pulse_scale)
        scaled_font = pygame.font.Font(None, scaled_font_size)

        self.draw_text_with_shadow(self.message, scaled_font, self.message_color, 825, 600)

    def draw_title(self):
        """Draw animated title."""
        # Animated glow
        glow_intensity = int(100 + 50 * math.sin(self.animation_timer * 0.05))
        glow_color = (ACCENT_CYAN[0], ACCENT_CYAN[1], glow_intensity)

        self.draw_glowing_text("HANGMAN", self.font_title, WHITE, WIDTH // 2, 70, glow_color)

        # Subtitle
        self.draw_text_with_shadow("Elite Edition", self.font_tiny, ACCENT_CYAN, WIDTH // 2, 120)

    def draw_game_over(self):
        """Draw game over screen with effects."""
        # Dark overlay
        overlay = pygame.Surface((WIDTH, HEIGHT), pygame.SRCALPHA)
        overlay.fill((0, 0, 0, 180))
        self.screen.blit(overlay, (0, 0))

        # Main panel
        panel_rect = pygame.Rect(250, 200, 700, 400)
        self.draw_panel(panel_rect, DARK_BG, GOLD if self.won else ACCENT_RED)

        if self.won:
            # Victory
            self.draw_glowing_text("VICTORY!", self.font_title, GOLD, WIDTH // 2, 300, GOLD)

            # Add score
            bonus = self.tries * 100
            self.score += bonus

            message = f"The word was: {self.word}"
            self.draw_text_with_shadow(message, self.font_medium, ACCENT_CYAN, WIDTH // 2, 400)

            bonus_text = f"+{bonus} points!"
            self.draw_text_with_shadow(bonus_text, self.font_small, GOLD, WIDTH // 2, 460)
        else:
            # Defeat
            self.draw_glowing_text("GAME OVER", self.font_title, ACCENT_RED, WIDTH // 2, 300, ACCENT_RED)

            message = f"The word was: {self.word}"
            self.draw_text_with_shadow(message, self.font_medium, ACCENT_CYAN, WIDTH // 2, 400)

        # Instructions
        self.draw_text_with_shadow("Press SPACE to play again", self.font_small, WHITE, WIDTH // 2, 520)
        self.draw_text_with_shadow("Press ESC to quit", self.font_tiny, LIGHT_GRAY, WIDTH // 2, 560)

    def handle_guess(self, letter):
        """Handle letter guess with visual feedback."""
        if self.game_over:
            return

        letter = letter.upper()

        if not letter.isalpha() or len(letter) != 1:
            return

        if letter in self.guessed_letters:
            self.message = "Already guessed that letter!"
            self.message_color = ACCENT_ORANGE
            self.shake_intensity = 5
            return

        self.guessed_letters.add(letter)

        if letter in self.word:
            self.message = "Excellent! Keep going!"
            self.message_color = ACCENT_GREEN

            # Create particles at correct letters
            for i, char in enumerate(self.word):
                if char == letter:
                    self.word_display[i] = letter
                    self.letter_reveal_timers[i] = 0
                    # Particle effect
                    x = 500 + (650 // 2) + (i - len(self.word) // 2) * 75
                    y = 240
                    self.create_particles(x, y, ACCENT_GREEN, 15)

            if "_" not in self.word_display:
                self.game_over = True
                self.won = True
                # Victory particles
                for _ in range(100):
                    x = random.randint(0, WIDTH)
                    y = random.randint(0, HEIGHT)
                    color = random.choice([GOLD, ACCENT_CYAN, ACCENT_GREEN, ACCENT_PURPLE])
                    self.create_particles(x, y, color, 3)
        else:
            self.message = "Wrong! Try again!"
            self.message_color = ACCENT_RED
            self.tries -= 1
            self.shake_intensity = 10

            # Red particles
            self.create_particles(250, 350, ACCENT_RED, 20)

            if self.tries <= 0:
                self.game_over = True
                self.won = False
                self.word_display = list(self.word)

    def update_particles(self):
        """Update and remove dead particles."""
        for particle in self.particles[:]:
            particle.update()
            if particle.is_dead():
                self.particles.remove(particle)

    def draw_particles(self):
        """Draw all active particles."""
        for particle in self.particles:
            particle.draw(self.screen)

    def draw(self):
        """Main draw function."""
        self.draw_gradient_background()

        self.draw_title()
        self.draw_word()
        self.draw_guessed_letters()
        self.draw_tries()
        self.draw_score()
        self.draw_hangman()
        self.draw_message()

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
