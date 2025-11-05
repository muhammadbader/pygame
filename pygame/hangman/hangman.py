import pygame
import random
import sys
import math
import colorsys

# ---------------------------
# Configuration
# ---------------------------
WORDS = [
    "python", "robotics", "artificial", "machine", "learning",
    "flutter", "developer", "science", "technology", "computer",
    "vibe", "fire", "slay", "sigma", "rizz", "drip", "bussin", "based"
]

# Gen Z Neon Cyberpunk Color Palette
BG_DARK = (10, 5, 20)
BG_PURPLE = (25, 10, 40)
NEON_PINK = (255, 16, 240)
NEON_CYAN = (0, 255, 255)
NEON_GREEN = (57, 255, 20)
NEON_ORANGE = (255, 165, 0)
NEON_YELLOW = (255, 255, 0)
NEON_PURPLE = (191, 64, 191)
NEON_BLUE = (64, 224, 208)
HOT_PINK = (255, 105, 180)
ELECTRIC_BLUE = (125, 249, 255)
LIME = (204, 255, 0)
GOLD = (255, 215, 0)
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)

# Screen settings
WIDTH = 1400
HEIGHT = 900
FPS = 60

# ---------------------------
# Background Star Class
# ---------------------------
class Star:
    def __init__(self):
        self.x = random.randint(0, WIDTH)
        self.y = random.randint(0, HEIGHT)
        self.size = random.randint(1, 3)
        self.speed = random.uniform(0.5, 2.0)
        self.brightness = random.randint(100, 255)

    def update(self):
        self.y += self.speed
        if self.y > HEIGHT:
            self.y = 0
            self.x = random.randint(0, WIDTH)

    def draw(self, screen):
        color = (self.brightness, self.brightness, self.brightness)
        pygame.draw.circle(screen, color, (int(self.x), int(self.y)), self.size)

# ---------------------------
# Floating Shape Class
# ---------------------------
class FloatingShape:
    def __init__(self):
        self.x = random.randint(0, WIDTH)
        self.y = random.randint(0, HEIGHT)
        self.size = random.randint(20, 60)
        self.rotation = random.uniform(0, 360)
        self.rotation_speed = random.uniform(-1, 1)
        self.color = random.choice([NEON_PINK, NEON_CYAN, NEON_PURPLE, NEON_GREEN])
        self.alpha = random.randint(20, 60)
        self.drift_x = random.uniform(-0.3, 0.3)
        self.drift_y = random.uniform(-0.3, 0.3)

    def update(self):
        self.rotation += self.rotation_speed
        self.x += self.drift_x
        self.y += self.drift_y

        # Wrap around
        if self.x < -self.size: self.x = WIDTH + self.size
        if self.x > WIDTH + self.size: self.x = -self.size
        if self.y < -self.size: self.y = HEIGHT + self.size
        if self.y > HEIGHT + self.size: self.y = -self.size

    def draw(self, screen):
        s = pygame.Surface((self.size * 2, self.size * 2), pygame.SRCALPHA)
        points = []
        for i in range(3):
            angle = math.radians(self.rotation + i * 120)
            x = self.size + math.cos(angle) * self.size
            y = self.size + math.sin(angle) * self.size
            points.append((x, y))
        pygame.draw.polygon(s, (*self.color, self.alpha), points)
        screen.blit(s, (int(self.x - self.size), int(self.y - self.size)))

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
        self.size = random.randint(4, 12)
        self.glow = True

    def update(self):
        self.x += self.velocity[0]
        self.y += self.velocity[1]
        self.velocity = (self.velocity[0] * 0.98, self.velocity[1] + 0.2)
        self.lifetime -= 1

    def draw(self, screen):
        alpha = int(255 * (self.lifetime / self.max_lifetime))
        size = int(self.size * (self.lifetime / self.max_lifetime))
        if size > 0:
            # Glow effect
            for glow_size in range(size * 3, size, -size // 3):
                glow_alpha = alpha // 3
                s = pygame.Surface((glow_size * 2, glow_size * 2), pygame.SRCALPHA)
                pygame.draw.circle(s, (*self.color, glow_alpha), (glow_size, glow_size), glow_size)
                screen.blit(s, (int(self.x - glow_size), int(self.y - glow_size)))

            # Core particle
            s = pygame.Surface((size * 2, size * 2), pygame.SRCALPHA)
            pygame.draw.circle(s, (*self.color, alpha), (size, size), size)
            screen.blit(s, (int(self.x - size), int(self.y - size)))

    def is_dead(self):
        return self.lifetime <= 0

# ---------------------------
# Text Pop Animation
# ---------------------------
class TextPop:
    def __init__(self, text, x, y, color, font_size=60):
        self.text = text
        self.x = x
        self.y = y
        self.color = color
        self.font_size = font_size
        self.lifetime = 60
        self.max_lifetime = 60
        self.vel_y = -3

    def update(self):
        self.y += self.vel_y
        self.vel_y += 0.1
        self.lifetime -= 1

    def draw(self, screen):
        if self.lifetime > 0:
            alpha = int(255 * (self.lifetime / self.max_lifetime))
            scale = 1.0 + (1.0 - self.lifetime / self.max_lifetime) * 0.5
            font_size = int(self.font_size * scale)
            font = pygame.font.Font(None, font_size)

            # Glow
            for offset in range(10, 0, -2):
                glow_surf = font.render(self.text, True, self.color)
                glow_surf.set_alpha(alpha // 4)
                for dx, dy in [(-offset, 0), (offset, 0), (0, -offset), (0, offset)]:
                    rect = glow_surf.get_rect(center=(int(self.x + dx), int(self.y + dy)))
                    screen.blit(glow_surf, rect)

            # Main text
            text_surf = font.render(self.text, True, WHITE)
            text_surf.set_alpha(alpha)
            rect = text_surf.get_rect(center=(int(self.x), int(self.y)))
            screen.blit(text_surf, rect)

    def is_dead(self):
        return self.lifetime <= 0

# ---------------------------
# Game Class
# ---------------------------
class HangmanGame:
    def __init__(self):
        pygame.init()
        self.screen = pygame.display.set_mode((WIDTH, HEIGHT))
        pygame.display.set_caption("🔥 HANGMAN // NO CAP 🔥")
        self.clock = pygame.time.Clock()

        # Fonts
        self.font_massive = pygame.font.Font(None, 120)
        self.font_title = pygame.font.Font(None, 96)
        self.font_large = pygame.font.Font(None, 80)
        self.font_medium = pygame.font.Font(None, 48)
        self.font_small = pygame.font.Font(None, 36)
        self.font_tiny = pygame.font.Font(None, 28)

        # Background elements
        self.stars = [Star() for _ in range(150)]
        self.shapes = [FloatingShape() for _ in range(8)]

        # Game state
        self.particles = []
        self.text_pops = []
        self.animation_timer = 0
        self.letter_reveal_timers = {}
        self.score = 0
        self.games_played = 0
        self.streak = 0
        self.best_streak = 0
        self.combo = 0
        self.total_wins = 0
        self.rainbow_offset = 0
        self.screen_flash = 0

        self.reset_game()

    def reset_game(self):
        """Reset game to initial state."""
        self.word = random.choice(WORDS).upper()
        self.guessed_letters = set()
        self.tries = 6
        self.word_display = ["_"] * len(self.word)
        self.game_over = False
        self.won = False
        self.message = "LET'S GOOO! GUESS A LETTER 🚀"
        self.message_color = NEON_CYAN
        self.animation_timer = 0
        self.shake_offset = 0
        self.shake_intensity = 0
        self.pulse_scale = 1.0
        self.games_played += 1
        self.combo = 0

    def get_rainbow_color(self, offset=0):
        """Get color from rainbow spectrum."""
        hue = ((self.animation_timer * 2 + offset) % 360) / 360
        rgb = colorsys.hsv_to_rgb(hue, 1.0, 1.0)
        return (int(rgb[0] * 255), int(rgb[1] * 255), int(rgb[2] * 255))

    def create_particles(self, x, y, color, count=20):
        """Create particle explosion effect."""
        for _ in range(count):
            angle = random.uniform(0, 2 * math.pi)
            speed = random.uniform(3, 12)
            velocity = (math.cos(angle) * speed, math.sin(angle) * speed)
            self.particles.append(Particle(x, y, color, velocity))

    def create_text_pop(self, text, x, y, color, font_size=60):
        """Create floating text animation."""
        self.text_pops.append(TextPop(text, x, y, color, font_size))

    def draw_gradient_bg(self):
        """Draw animated gradient background."""
        for y in range(HEIGHT):
            progress = y / HEIGHT
            # Animated colors
            offset = math.sin(self.animation_timer * 0.01 + progress * 2) * 10
            r = int(BG_DARK[0] + (BG_PURPLE[0] - BG_DARK[0]) * progress + offset)
            g = int(BG_DARK[1] + (BG_PURPLE[1] - BG_DARK[1]) * progress + offset)
            b = int(BG_DARK[2] + (BG_PURPLE[2] - BG_DARK[2]) * progress + offset)
            pygame.draw.line(self.screen, (max(0, r), max(0, g), max(0, b)), (0, y), (WIDTH, y))

    def draw_neon_panel(self, rect, border_color, glow=True):
        """Draw neon-style panel with glow."""
        # Outer glow
        if glow:
            for i in range(15, 0, -3):
                glow_rect = rect.inflate(i * 2, i * 2)
                alpha = int(30 * (i / 15))
                s = pygame.Surface((glow_rect.width, glow_rect.height), pygame.SRCALPHA)
                pygame.draw.rect(s, (*border_color, alpha), s.get_rect(), border_radius=20)
                self.screen.blit(s, glow_rect.topleft)

        # Glass panel
        panel_surf = pygame.Surface((rect.width, rect.height), pygame.SRCALPHA)
        pygame.draw.rect(panel_surf, (20, 10, 35, 180), panel_surf.get_rect(), border_radius=15)
        self.screen.blit(panel_surf, rect.topleft)

        # Neon border
        pygame.draw.rect(self.screen, border_color, rect, 4, border_radius=15)

        # Inner highlight
        inner_rect = rect.inflate(-8, -8)
        pygame.draw.rect(self.screen, (*border_color, 60), inner_rect, 2, border_radius=12)

    def draw_neon_text(self, text, font, color, x, y, glow_intensity=8):
        """Draw text with neon glow effect."""
        # Glow layers
        for offset in range(glow_intensity * 2, 0, -2):
            alpha = int(150 * (offset / (glow_intensity * 2)))
            glow_surf = font.render(text, True, color)
            glow_surf.set_alpha(alpha)
            for angle in range(0, 360, 45):
                dx = int(math.cos(math.radians(angle)) * offset)
                dy = int(math.sin(math.radians(angle)) * offset)
                rect = glow_surf.get_rect(center=(x + dx, y + dy))
                self.screen.blit(glow_surf, rect)

        # Main text
        text_surf = font.render(text, True, WHITE)
        rect = text_surf.get_rect(center=(x, y))
        self.screen.blit(text_surf, rect)

    def draw_rainbow_text(self, text, font, x, y):
        """Draw text with rainbow colors."""
        total_width = font.size(text)[0]
        start_x = x - total_width // 2

        for i, char in enumerate(text):
            color = self.get_rainbow_color(i * 30)
            self.draw_neon_text(char, font, color, start_x + font.size(text[:i])[0] + font.size(char)[0] // 2, y, 6)

    def draw_hangman(self):
        """Draw cyberpunk hangman."""
        base_x = 250
        base_y = 700

        # Holographic platform
        platform_surf = pygame.Surface((200, 20), pygame.SRCALPHA)
        for i in range(10):
            alpha = int(100 - i * 10)
            pygame.draw.ellipse(platform_surf, (*NEON_CYAN, alpha),
                              pygame.Rect(10, i * 2, 180, 10))
        self.screen.blit(platform_surf, (base_x - 100, base_y))

        # Neon gallows
        glow_color = self.get_rainbow_color(0)

        # Base with glow
        for thickness in range(15, 5, -2):
            alpha = int(100 * (thickness / 15))
            pygame.draw.line(self.screen, (*glow_color, alpha),
                           (base_x - 80, base_y), (base_x + 80, base_y), thickness)
        pygame.draw.line(self.screen, WHITE, (base_x - 80, base_y), (base_x + 80, base_y), 6)

        # Vertical pole
        for thickness in range(15, 5, -2):
            alpha = int(100 * (thickness / 15))
            pygame.draw.line(self.screen, (*NEON_PINK, alpha),
                           (base_x, base_y), (base_x, base_y - 400), thickness)
        pygame.draw.line(self.screen, WHITE, (base_x, base_y), (base_x, base_y - 400), 6)

        # Top bar
        for thickness in range(15, 5, -2):
            alpha = int(100 * (thickness / 15))
            pygame.draw.line(self.screen, (*NEON_CYAN, alpha),
                           (base_x, base_y - 400), (base_x + 180, base_y - 400), thickness)
        pygame.draw.line(self.screen, WHITE, (base_x, base_y - 400), (base_x + 180, base_y - 400), 6)

        # Animated rope
        rope_color = self.get_rainbow_color(self.animation_timer * 10)
        for i in range(6):
            y_pos = base_y - 400 + i * 15
            thickness = 8 - i % 2
            pygame.draw.line(self.screen, rope_color,
                           (base_x + 180, y_pos), (base_x + 180, y_pos + 12), thickness)

        wrong_guesses = 6 - self.tries
        hang_x = base_x + 180
        head_y = base_y - 300

        # Apply shake
        shake_x = random.randint(-self.shake_intensity, self.shake_intensity)
        shake_y = random.randint(-self.shake_intensity, self.shake_intensity)

        if wrong_guesses >= 1:  # Head
            # Massive glow
            for radius in range(60, 40, -4):
                alpha = int(80 * ((60 - radius) / 20))
                s = pygame.Surface((radius * 2, radius * 2), pygame.SRCALPHA)
                pygame.draw.circle(s, (*NEON_PINK, alpha), (radius, radius), radius)
                self.screen.blit(s, (hang_x + shake_x - radius, head_y + shake_y - radius))

            # Head
            pygame.draw.circle(self.screen, BG_PURPLE, (hang_x + shake_x, head_y + shake_y), 42)
            pygame.draw.circle(self.screen, NEON_PINK, (hang_x + shake_x, head_y + shake_y), 42, 6)

            # Glowing X eyes
            eye_left_x = hang_x - 15 + shake_x
            eye_right_x = hang_x + 15 + shake_x
            eye_y = head_y - 5 + shake_y

            for ex in [eye_left_x, eye_right_x]:
                pygame.draw.line(self.screen, NEON_CYAN, (ex - 6, eye_y - 6), (ex + 6, eye_y + 6), 4)
                pygame.draw.line(self.screen, NEON_CYAN, (ex - 6, eye_y + 6), (ex + 6, eye_y - 6), 4)

            # Mouth
            mouth_y = head_y + 15 + shake_y
            pygame.draw.arc(self.screen, NEON_PINK,
                          pygame.Rect(hang_x - 18 + shake_x, mouth_y, 36, 25),
                          math.pi, 2 * math.pi, 4)

        # Body parts with neon glow
        body_color = NEON_CYAN if wrong_guesses >= 2 else WHITE

        if wrong_guesses >= 2:  # Body
            for thickness in range(18, 6, -3):
                alpha = int(100 * (thickness / 18))
                pygame.draw.line(self.screen, (*body_color, alpha),
                               (hang_x + shake_x, head_y + 42 + shake_y),
                               (hang_x + shake_x, head_y + 160 + shake_y), thickness)
            pygame.draw.line(self.screen, WHITE,
                           (hang_x + shake_x, head_y + 42 + shake_y),
                           (hang_x + shake_x, head_y + 160 + shake_y), 8)

        if wrong_guesses >= 3:  # Left arm
            for thickness in range(18, 6, -3):
                alpha = int(100 * (thickness / 18))
                pygame.draw.line(self.screen, (*NEON_GREEN, alpha),
                               (hang_x + shake_x, head_y + 70 + shake_y),
                               (hang_x - 60 + shake_x, head_y + 130 + shake_y), thickness)
            pygame.draw.line(self.screen, WHITE,
                           (hang_x + shake_x, head_y + 70 + shake_y),
                           (hang_x - 60 + shake_x, head_y + 130 + shake_y), 8)

        if wrong_guesses >= 4:  # Right arm
            for thickness in range(18, 6, -3):
                alpha = int(100 * (thickness / 18))
                pygame.draw.line(self.screen, (*NEON_GREEN, alpha),
                               (hang_x + shake_x, head_y + 70 + shake_y),
                               (hang_x + 60 + shake_x, head_y + 130 + shake_y), thickness)
            pygame.draw.line(self.screen, WHITE,
                           (hang_x + shake_x, head_y + 70 + shake_y),
                           (hang_x + 60 + shake_x, head_y + 130 + shake_y), 8)

        if wrong_guesses >= 5:  # Left leg
            for thickness in range(18, 6, -3):
                alpha = int(100 * (thickness / 18))
                pygame.draw.line(self.screen, (*NEON_ORANGE, alpha),
                               (hang_x + shake_x, head_y + 160 + shake_y),
                               (hang_x - 50 + shake_x, head_y + 240 + shake_y), thickness)
            pygame.draw.line(self.screen, WHITE,
                           (hang_x + shake_x, head_y + 160 + shake_y),
                           (hang_x - 50 + shake_x, head_y + 240 + shake_y), 8)

        if wrong_guesses >= 6:  # Right leg
            for thickness in range(18, 6, -3):
                alpha = int(100 * (thickness / 18))
                pygame.draw.line(self.screen, (*NEON_ORANGE, alpha),
                               (hang_x + shake_x, head_y + 160 + shake_y),
                               (hang_x + 50 + shake_x, head_y + 240 + shake_y), thickness)
            pygame.draw.line(self.screen, WHITE,
                           (hang_x + shake_x, head_y + 160 + shake_y),
                           (hang_x + 50 + shake_x, head_y + 240 + shake_y), 8)

        if self.shake_intensity > 0:
            self.shake_intensity -= 1

    def draw_word(self):
        """Draw word with fire letter boxes."""
        panel_rect = pygame.Rect(550, 180, 800, 140)
        self.draw_neon_panel(panel_rect, NEON_PINK)

        # Title with emoji
        self.draw_neon_text("WORD 📝", self.font_medium, NEON_PINK, 640, 220, 6)

        # Letter boxes
        total_letters = len(self.word_display)
        box_size = 70
        spacing = 20
        total_width = (box_size + spacing) * total_letters - spacing
        start_x = 550 + (800 - total_width) // 2

        for i, letter in enumerate(self.word_display):
            x = start_x + i * (box_size + spacing)
            y = 260

            # Animation
            if letter != "_" and i in self.letter_reveal_timers:
                scale = min(1.2, self.letter_reveal_timers[i] / 8.0)
                size = int(box_size * scale)
                offset = (box_size - size) // 2
            else:
                size = box_size
                offset = 0

            box_rect = pygame.Rect(x + offset, y + offset, size, size)

            if letter == "_":
                # Empty box
                pygame.draw.rect(self.screen, (30, 20, 50, 200), box_rect, border_radius=12)
                pygame.draw.rect(self.screen, NEON_PURPLE, box_rect, 3, border_radius=12)
            else:
                # Filled box with rainbow glow
                color = self.get_rainbow_color(i * 40 + self.animation_timer * 5)

                # Glow
                for g_size in range(size + 20, size, -4):
                    g_offset = (g_size - size) // 2
                    g_rect = pygame.Rect(x + offset - g_offset, y + offset - g_offset, g_size, g_size)
                    alpha = int(60 * ((size + 20 - g_size) / 20))
                    s = pygame.Surface((g_size, g_size), pygame.SRCALPHA)
                    pygame.draw.rect(s, (*color, alpha), s.get_rect(), border_radius=14)
                    self.screen.blit(s, g_rect.topleft)

                pygame.draw.rect(self.screen, (10, 5, 20, 240), box_rect, border_radius=12)
                pygame.draw.rect(self.screen, color, box_rect, 5, border_radius=12)

                # Letter
                letter_surf = self.font_large.render(letter, True, WHITE)
                letter_rect = letter_surf.get_rect(center=box_rect.center)
                self.screen.blit(letter_surf, letter_rect)

        # Update timers
        for key in list(self.letter_reveal_timers.keys()):
            self.letter_reveal_timers[key] += 1
            if self.letter_reveal_timers[key] > 12:
                del self.letter_reveal_timers[key]

    def draw_stats_panel(self):
        """Draw stats in top left."""
        panel_rect = pygame.Rect(30, 30, 460, 120)
        self.draw_neon_panel(panel_rect, NEON_CYAN)

        # Streak
        streak_color = NEON_ORANGE if self.streak > 0 else NEON_CYAN
        self.draw_neon_text(f"🔥 STREAK: {self.streak}", self.font_small, streak_color, 140, 60, 4)

        # Best streak
        self.draw_neon_text(f"👑 BEST: {self.best_streak}", self.font_tiny, GOLD, 140, 95, 3)

        # Score with rainbow
        score_text = f"💎 {self.score}"
        self.draw_rainbow_text(score_text, self.font_medium, 360, 75)

    def draw_lives(self):
        """Draw lives with fire hearts."""
        panel_rect = pygame.Rect(550, 350, 800, 100)

        color = NEON_GREEN if self.tries > 2 else NEON_PINK
        self.draw_neon_panel(panel_rect, color)

        self.draw_neon_text("LIVES 💖", self.font_medium, color, 640, 385, 6)

        # Hearts
        heart_y = 390
        for i in range(6):
            heart_x = 740 + i * 70

            if i < self.tries:
                # Animated heart
                scale = 1.0 + 0.1 * math.sin(self.animation_timer * 0.1 + i * 0.5)
                heart_size = int(12 * scale)

                # Glow
                for g_size in range(heart_size + 15, heart_size, -3):
                    alpha = int(60 * ((heart_size + 15 - g_size) / 15))
                    for offset_x, offset_y in [(-g_size//2, 0), (g_size//2, 0)]:
                        s = pygame.Surface((g_size * 2, g_size * 2), pygame.SRCALPHA)
                        pygame.draw.circle(s, (*NEON_PINK, alpha), (g_size, g_size), g_size)
                        self.screen.blit(s, (heart_x + offset_x - g_size, heart_y + offset_y - g_size))

                # Heart
                pygame.draw.circle(self.screen, NEON_PINK, (heart_x - heart_size//2, heart_y), heart_size)
                pygame.draw.circle(self.screen, NEON_PINK, (heart_x + heart_size//2, heart_y), heart_size)
                pygame.draw.polygon(self.screen, NEON_PINK, [
                    (heart_x - heart_size * 1.2, heart_y),
                    (heart_x, heart_y + heart_size * 2),
                    (heart_x + heart_size * 1.2, heart_y)
                ])
            else:
                # Dead heart
                pygame.draw.circle(self.screen, (60, 60, 80), (heart_x - 6, heart_y), 8, 3)
                pygame.draw.circle(self.screen, (60, 60, 80), (heart_x + 6, heart_y), 8, 3)
                pygame.draw.polygon(self.screen, (60, 60, 80), [
                    (heart_x - 14, heart_y),
                    (heart_x, heart_y + 20),
                    (heart_x + 14, heart_y)
                ], 3)

    def draw_guessed_letters(self):
        """Draw guessed letters panel."""
        panel_rect = pygame.Rect(550, 480, 800, 100)
        self.draw_neon_panel(panel_rect, NEON_PURPLE)

        self.draw_neon_text("GUESSED 🎯", self.font_medium, NEON_PURPLE, 640, 515, 6)

        if self.guessed_letters:
            letters = " ".join(sorted(self.guessed_letters))
        else:
            letters = "NONE YET"

        self.draw_neon_text(letters, self.font_small, WHITE, 950, 545, 4)

    def draw_message(self):
        """Draw message with mega effects."""
        panel_rect = pygame.Rect(550, 610, 800, 110)
        self.draw_neon_panel(panel_rect, self.message_color)

        # Pulsing text
        self.pulse_scale = 1.0 + 0.08 * math.sin(self.animation_timer * 0.15)
        font_size = int(40 * self.pulse_scale)
        font = pygame.font.Font(None, font_size)

        self.draw_neon_text(self.message, font, self.message_color, 950, 665, 8)

    def draw_title(self):
        """Draw mega title."""
        # Rainbow title
        title_y = 90
        self.draw_rainbow_text("HANGMAN", self.font_massive, WIDTH // 2, title_y)

        # Subtitle
        subtitle = "// NO CAP EDITION //"
        self.draw_neon_text(subtitle, self.font_small, NEON_CYAN, WIDTH // 2, 145, 5)

    def draw_game_over(self):
        """Draw insane game over screen."""
        # Screen flash
        if self.screen_flash > 0:
            flash_surf = pygame.Surface((WIDTH, HEIGHT), pygame.SRCALPHA)
            flash_surf.fill((*WHITE, self.screen_flash))
            self.screen.blit(flash_surf, (0, 0))
            self.screen_flash -= 15

        # Dark overlay
        overlay = pygame.Surface((WIDTH, HEIGHT), pygame.SRCALPHA)
        overlay.fill((0, 0, 0, 200))
        self.screen.blit(overlay, (0, 0))

        # Panel
        panel_rect = pygame.Rect(300, 250, 800, 450)
        border_color = NEON_GREEN if self.won else NEON_PINK
        self.draw_neon_panel(panel_rect, border_color)

        if self.won:
            # VICTORY
            emojis = ["🔥", "💯", "✨", "🎉", "🏆", "👑"]
            victory_text = f"{random.choice(emojis)} SHEEEESH {random.choice(emojis)}"
            self.draw_rainbow_text(victory_text, self.font_massive, WIDTH // 2, 360)

            message = f"WORD: {self.word}"
            self.draw_neon_text(message, self.font_large, NEON_CYAN, WIDTH // 2, 470, 8)

            bonus = self.tries * 100
            combo_bonus = self.combo * 50
            total_bonus = bonus + combo_bonus

            bonus_text = f"+{total_bonus} POINTS! 💰"
            self.draw_neon_text(bonus_text, self.font_medium, GOLD, WIDTH // 2, 550, 6)

            if self.combo > 0:
                combo_text = f"COMBO x{self.combo}! 🚀"
                self.draw_neon_text(combo_text, self.font_small, NEON_ORANGE, WIDTH // 2, 600, 5)
        else:
            # DEFEAT
            defeat_text = "💀 RIP 💀"
            self.draw_neon_text(defeat_text, self.font_massive, NEON_PINK, WIDTH // 2, 360, 12)

            message = f"WORD WAS: {self.word}"
            self.draw_neon_text(message, self.font_large, NEON_CYAN, WIDTH // 2, 480, 8)

            oof = "BETTER LUCK NEXT TIME BESTIE 😭"
            self.draw_neon_text(oof, self.font_small, NEON_PURPLE, WIDTH // 2, 570, 5)

        # Instructions
        space_text = "PRESS SPACE TO RUN IT BACK 🔄"
        self.draw_neon_text(space_text, self.font_small, WHITE, WIDTH // 2, 640, 4)

    def handle_guess(self, letter):
        """Handle guess with mega feedback."""
        if self.game_over:
            return

        letter = letter.upper()

        if not letter.isalpha() or len(letter) != 1:
            return

        if letter in self.guessed_letters:
            self.message = "ALREADY GUESSED THAT BRO! 🙄"
            self.message_color = NEON_ORANGE
            self.shake_intensity = 8
            return

        self.guessed_letters.add(letter)

        if letter in self.word:
            # CORRECT!
            messages = ["YOOO LETS GO! 🔥", "SHEESH! 💯", "BUSSIN! ✨", "NO CAP! 👑", "FIRE! 🎯"]
            self.message = random.choice(messages)
            self.message_color = NEON_GREEN
            self.combo += 1

            for i, char in enumerate(self.word):
                if char == letter:
                    self.word_display[i] = letter
                    self.letter_reveal_timers[i] = 0

                    # MEGA particles
                    x = 550 + (800 // 2) + (i - len(self.word) // 2) * 90
                    y = 295
                    for _ in range(3):
                        color = random.choice([NEON_GREEN, NEON_CYAN, LIME, ELECTRIC_BLUE])
                        self.create_particles(x, y, color, 25)

                    # Pop text
                    pop_texts = ["+100", "NICE!", "SLAY!", "YES!"]
                    self.create_text_pop(random.choice(pop_texts), x, y - 40, NEON_GREEN, 50)

            if "_" not in self.word_display:
                self.game_over = True
                self.won = True
                self.streak += 1
                self.best_streak = max(self.best_streak, self.streak)
                self.total_wins += 1

                # Add score
                bonus = self.tries * 100 + self.combo * 50
                self.score += bonus

                # VICTORY EXPLOSION
                self.screen_flash = 200
                for _ in range(200):
                    x = random.randint(0, WIDTH)
                    y = random.randint(0, HEIGHT)
                    colors = [NEON_PINK, NEON_CYAN, NEON_GREEN, NEON_YELLOW, NEON_PURPLE, GOLD]
                    self.create_particles(x, y, random.choice(colors), 5)
        else:
            # WRONG!
            messages = ["NAHH! 😭", "MISSED! 💀", "OOF! ❌", "NOT IT! 😬"]
            self.message = random.choice(messages)
            self.message_color = NEON_PINK
            self.tries -= 1
            self.shake_intensity = 15
            self.combo = 0

            # Red explosion
            for _ in range(5):
                self.create_particles(250, 400, NEON_PINK, 30)

            self.create_text_pop("MISS!", WIDTH // 2, 400, NEON_PINK, 80)

            if self.tries <= 0:
                self.game_over = True
                self.won = False
                self.word_display = list(self.word)
                self.streak = 0

    def update_background(self):
        """Update animated background elements."""
        for star in self.stars:
            star.update()
        for shape in self.shapes:
            shape.update()

    def draw_background(self):
        """Draw background elements."""
        for star in self.stars:
            star.draw(self.screen)
        for shape in self.shapes:
            shape.draw(self.screen)

    def update_particles(self):
        """Update particles and text pops."""
        for particle in self.particles[:]:
            particle.update()
            if particle.is_dead():
                self.particles.remove(particle)

        for text_pop in self.text_pops[:]:
            text_pop.update()
            if text_pop.is_dead():
                self.text_pops.remove(text_pop)

    def draw_particles(self):
        """Draw all effects."""
        for particle in self.particles:
            particle.draw(self.screen)
        for text_pop in self.text_pops:
            text_pop.draw(self.screen)

    def draw(self):
        """Main draw function."""
        self.draw_gradient_bg()
        self.draw_background()

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
        self.rainbow_offset += 1

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
            self.update_background()
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
