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
WIDTH = 800
HEIGHT = 600
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
        # Gallows
        pygame.draw.line(self.screen, DARK_BLUE, (150, 450), (250, 450), 5)  # Base
        pygame.draw.line(self.screen, DARK_BLUE, (200, 450), (200, 150), 5)  # Vertical pole
        pygame.draw.line(self.screen, DARK_BLUE, (200, 150), (300, 150), 5)  # Top horizontal
        pygame.draw.line(self.screen, DARK_BLUE, (300, 150), (300, 200), 5)  # Rope

        # Draw body parts based on wrong guesses (6 - tries)
        wrong_guesses = 6 - self.tries

        if wrong_guesses >= 1:  # Head
            pygame.draw.circle(self.screen, BLACK, (300, 230), 30, 3)

        if wrong_guesses >= 2:  # Body
            pygame.draw.line(self.screen, BLACK, (300, 260), (300, 350), 3)

        if wrong_guesses >= 3:  # Left arm
            pygame.draw.line(self.screen, BLACK, (300, 280), (260, 320), 3)

        if wrong_guesses >= 4:  # Right arm
            pygame.draw.line(self.screen, BLACK, (300, 280), (340, 320), 3)

        if wrong_guesses >= 5:  # Left leg
            pygame.draw.line(self.screen, BLACK, (300, 350), (270, 410), 3)

        if wrong_guesses >= 6:  # Right leg
            pygame.draw.line(self.screen, BLACK, (300, 350), (330, 410), 3)

    def draw_word(self):
        """Draw the word with guessed letters."""
        word_str = " ".join(self.word_display)
        word_text = self.font_large.render(word_str, True, BLUE)
        word_rect = word_text.get_rect(center=(WIDTH // 2, 150))
        self.screen.blit(word_text, word_rect)

    def draw_guessed_letters(self):
        """Draw the letters that have been guessed."""
        if self.guessed_letters:
            guessed_str = "Guessed: " + ", ".join(sorted(self.guessed_letters))
        else:
            guessed_str = "Guessed: None"

        guessed_text = self.font_small.render(guessed_str, True, GRAY)
        guessed_rect = guessed_text.get_rect(center=(WIDTH // 2, 250))
        self.screen.blit(guessed_text, guessed_rect)

    def draw_tries(self):
        """Draw remaining tries."""
        tries_str = f"Remaining tries: {self.tries}"
        tries_text = self.font_medium.render(tries_str, True, RED if self.tries <= 2 else BLACK)
        tries_rect = tries_text.get_rect(center=(WIDTH // 2, 320))
        self.screen.blit(tries_text, tries_rect)

    def draw_message(self):
        """Draw game message."""
        message_text = self.font_small.render(self.message, True, self.message_color)
        message_rect = message_text.get_rect(center=(WIDTH // 2, 500))
        self.screen.blit(message_text, message_rect)

    def draw_title(self):
        """Draw game title."""
        title_text = self.font_large.render("HANGMAN", True, DARK_BLUE)
        title_rect = title_text.get_rect(center=(WIDTH // 2, 50))
        self.screen.blit(title_text, title_rect)

    def draw_restart_prompt(self):
        """Draw restart prompt when game is over."""
        if self.game_over:
            restart_text = self.font_small.render("Press SPACE to play again or ESC to quit", True, BLACK)
            restart_rect = restart_text.get_rect(center=(WIDTH // 2, 550))
            self.screen.blit(restart_text, restart_rect)

    def draw_game_over(self):
        """Draw game over screen."""
        if self.won:
            result_text = self.font_large.render("YOU WON!", True, GREEN)
            word_reveal = self.font_medium.render(f"The word was: {self.word}", True, BLUE)
        else:
            result_text = self.font_large.render("GAME OVER!", True, RED)
            word_reveal = self.font_medium.render(f"The word was: {self.word}", True, BLUE)

        result_rect = result_text.get_rect(center=(WIDTH // 2, 380))
        word_rect = word_reveal.get_rect(center=(WIDTH // 2, 440))

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
