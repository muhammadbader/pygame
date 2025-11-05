import pygame
import random
import sys

# ---------------------------
# Configuration
# ---------------------------
WORDS = [
    "python", "robotics", "artificial", "machine", "learning",
    "flutter", "developer", "science", "technology", "computer"
]

# Colors
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
RED = (255, 0, 0)
GREEN = (0, 200, 0)
BLUE = (0, 100, 255)
GRAY = (150, 150, 150)
LIGHT_BLUE = (173, 216, 230)
DARK_BLUE = (0, 50, 100)

# Screen settings
WIDTH = 1000
HEIGHT = 700
FPS = 60

# ---------------------------
# Game Class
# ---------------------------
class HangmanGame:
    def __init__(self):
        pygame.init()
        self.screen = pygame.display.set_mode((WIDTH, HEIGHT))
        pygame.display.set_caption("Hangman Game")
        self.clock = pygame.time.Clock()
        self.font_large = pygame.font.Font(None, 72)
        self.font_medium = pygame.font.Font(None, 48)
        self.font_small = pygame.font.Font(None, 36)
        self.font_tiny = pygame.font.Font(None, 28)

        self.reset_game()

    def reset_game(self):
        """Reset game to initial state."""
        self.word = random.choice(WORDS).upper()
        self.guessed_letters = set()
        self.tries = 6
        self.word_display = ["_"] * len(self.word)
        self.game_over = False
        self.won = False
        self.message = "Press any letter key to guess!"
        self.message_color = BLACK

    def draw_hangman(self):
        """Draw the hangman based on remaining tries."""
        # Gallows - positioned on the left side
        base_x = 200
        base_y = 550

        pygame.draw.line(self.screen, DARK_BLUE, (base_x - 50, base_y), (base_x + 50, base_y), 6)  # Base
        pygame.draw.line(self.screen, DARK_BLUE, (base_x, base_y), (base_x, base_y - 300), 6)  # Vertical pole
        pygame.draw.line(self.screen, DARK_BLUE, (base_x, base_y - 300), (base_x + 120, base_y - 300), 6)  # Top horizontal
        pygame.draw.line(self.screen, DARK_BLUE, (base_x + 120, base_y - 300), (base_x + 120, base_y - 250), 6)  # Rope

        # Draw body parts based on wrong guesses (6 - tries)
        wrong_guesses = 6 - self.tries

        hang_x = base_x + 120
        head_y = base_y - 210

        if wrong_guesses >= 1:  # Head
            pygame.draw.circle(self.screen, BLACK, (hang_x, head_y), 35, 4)

        if wrong_guesses >= 2:  # Body
            pygame.draw.line(self.screen, BLACK, (hang_x, head_y + 35), (hang_x, head_y + 120), 4)

        if wrong_guesses >= 3:  # Left arm
            pygame.draw.line(self.screen, BLACK, (hang_x, head_y + 55), (hang_x - 45, head_y + 95), 4)

        if wrong_guesses >= 4:  # Right arm
            pygame.draw.line(self.screen, BLACK, (hang_x, head_y + 55), (hang_x + 45, head_y + 95), 4)

        if wrong_guesses >= 5:  # Left leg
            pygame.draw.line(self.screen, BLACK, (hang_x, head_y + 120), (hang_x - 40, head_y + 180), 4)

        if wrong_guesses >= 6:  # Right leg
            pygame.draw.line(self.screen, BLACK, (hang_x, head_y + 120), (hang_x + 40, head_y + 180), 4)

    def draw_word(self):
        """Draw the word with guessed letters."""
        # Add extra spacing between letters
        word_str = "   ".join(self.word_display)
        word_text = self.font_large.render(word_str, True, BLUE)
        word_rect = word_text.get_rect(center=(WIDTH // 2 + 100, 200))
        self.screen.blit(word_text, word_rect)

    def draw_guessed_letters(self):
        """Draw the letters that have been guessed."""
        if self.guessed_letters:
            # Add spacing between guessed letters
            guessed_str = "Guessed: " + "  ".join(sorted(self.guessed_letters))
        else:
            guessed_str = "Guessed: None"

        guessed_text = self.font_small.render(guessed_str, True, GRAY)
        guessed_rect = guessed_text.get_rect(center=(WIDTH // 2 + 100, 320))
        self.screen.blit(guessed_text, guessed_rect)

    def draw_tries(self):
        """Draw remaining tries."""
        tries_str = f"Remaining tries: {self.tries}"
        tries_text = self.font_medium.render(tries_str, True, RED if self.tries <= 2 else BLACK)
        tries_rect = tries_text.get_rect(center=(WIDTH // 2 + 100, 420))
        self.screen.blit(tries_text, tries_rect)

    def draw_message(self):
        """Draw game message."""
        message_text = self.font_small.render(self.message, True, self.message_color)
        message_rect = message_text.get_rect(center=(WIDTH // 2 + 100, 530))
        self.screen.blit(message_text, message_rect)

    def draw_title(self):
        """Draw game title."""
        title_text = self.font_large.render("HANGMAN", True, DARK_BLUE)
        title_rect = title_text.get_rect(center=(WIDTH // 2, 70))
        self.screen.blit(title_text, title_rect)

    def draw_restart_prompt(self):
        """Draw restart prompt when game is over."""
        if self.game_over:
            restart_text = self.font_small.render("Press SPACE to play again or ESC to quit", True, BLACK)
            restart_rect = restart_text.get_rect(center=(WIDTH // 2, 630))
            self.screen.blit(restart_text, restart_rect)

    def draw_game_over(self):
        """Draw game over screen."""
        # Draw a semi-transparent overlay for game over
        overlay = pygame.Surface((WIDTH, HEIGHT))
        overlay.set_alpha(200)
        overlay.fill(LIGHT_BLUE)
        self.screen.blit(overlay, (0, 0))

        if self.won:
            result_text = self.font_large.render("YOU WON!", True, GREEN)
            word_reveal = self.font_medium.render(f"The word was: {self.word}", True, BLUE)
        else:
            result_text = self.font_large.render("GAME OVER!", True, RED)
            word_reveal = self.font_medium.render(f"The word was: {self.word}", True, BLUE)

        result_rect = result_text.get_rect(center=(WIDTH // 2, 300))
        word_rect = word_reveal.get_rect(center=(WIDTH // 2, 400))

        self.screen.blit(result_text, result_rect)
        self.screen.blit(word_reveal, word_rect)

    def handle_guess(self, letter):
        """Handle a letter guess."""
        if self.game_over:
            return

        letter = letter.upper()

        # Validate input
        if not letter.isalpha() or len(letter) != 1:
            return

        if letter in self.guessed_letters:
            self.message = "You already guessed that letter!"
            self.message_color = RED
            return

        # Add to guessed letters
        self.guessed_letters.add(letter)

        # Check if letter is in word
        if letter in self.word:
            self.message = "Good guess!"
            self.message_color = GREEN
            # Update word display
            for i, char in enumerate(self.word):
                if char == letter:
                    self.word_display[i] = letter

            # Check win condition
            if "_" not in self.word_display:
                self.game_over = True
                self.won = True
        else:
            self.message = "Wrong guess!"
            self.message_color = RED
            self.tries -= 1

            # Check lose condition
            if self.tries <= 0:
                self.game_over = True
                self.won = False
                self.word_display = list(self.word)

    def draw(self):
        """Draw the game."""
        self.screen.fill(LIGHT_BLUE)

        self.draw_title()
        self.draw_word()
        self.draw_guessed_letters()
        self.draw_tries()
        self.draw_hangman()
        self.draw_message()

        if self.game_over:
            self.draw_game_over()
            self.draw_restart_prompt()

        pygame.display.flip()

    def handle_events(self):
        """Handle pygame events."""
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
                    # Handle letter input
                    if event.unicode.isalpha():
                        self.handle_guess(event.unicode)

        return True

    def run(self):
        """Main game loop."""
        running = True
        while running:
            self.clock.tick(FPS)
            running = self.handle_events()
            self.draw()

        pygame.quit()
        sys.exit()

# ---------------------------
# Run Game
# ---------------------------
if __name__ == "__main__":
    game = HangmanGame()
    game.run()
