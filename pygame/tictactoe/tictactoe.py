"""
Tic Tac Toe Game
A simple two-player Tic Tac Toe game in Python
"""

def print_board(board):
    """Display the current game board"""
    print("\n")
    print(f" {board[0]} | {board[1]} | {board[2]} ")
    print("---+---+---")
    print(f" {board[3]} | {board[4]} | {board[5]} ")
    print("---+---+---")
    print(f" {board[6]} | {board[7]} | {board[8]} ")
    print("\n")


def check_winner(board, player):
    """Check if the specified player has won"""
    # All possible winning combinations
    win_conditions = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8],  # Rows
        [0, 3, 6], [1, 4, 7], [2, 5, 8],  # Columns
        [0, 4, 8], [2, 4, 6]              # Diagonals
    ]
    
    for condition in win_conditions:
        if all(board[i] == player for i in condition):
            return True
    return False


def is_board_full(board):
    """Check if the board is full (draw condition)"""
    return all(space != " " for space in board)


def get_player_move(board, player):
    """Get and validate player input"""
    while True:
        try:
            move = input(f"Player {player}, enter your move (1-9): ")
            move = int(move) - 1  # Convert to 0-indexed
            
            if move < 0 or move > 8:
                print("Invalid input! Please enter a number between 1 and 9.")
                continue
            
            if board[move] != " ":
                print("That space is already taken! Choose another.")
                continue
            
            return move
        except ValueError:
            print("Invalid input! Please enter a number between 1 and 9.")
        except KeyboardInterrupt:
            print("\n\nGame interrupted. Thanks for playing!")
            exit()


def play_game():
    """Main game loop"""
    # Initialize the board
    board = [" " for _ in range(9)]
    current_player = "X"
    
    print("=" * 30)
    print("Welcome to Tic Tac Toe!")
    print("=" * 30)
    print("\nBoard positions:")
    print(" 1 | 2 | 3 ")
    print("---+---+---")
    print(" 4 | 5 | 6 ")
    print("---+---+---")
    print(" 7 | 8 | 9 ")
    
    # Game loop
    while True:
        print_board(board)
        
        # Get player move
        move = get_player_move(board, current_player)
        board[move] = current_player
        
        # Check for winner
        if check_winner(board, current_player):
            print_board(board)
            print(f"🎉 Congratulations! Player {current_player} wins! 🎉")
            break
        
        # Check for draw
        if is_board_full(board):
            print_board(board)
            print("It's a draw! Well played both players!")
            break
        
        # Switch player
        current_player = "O" if current_player == "X" else "X"


def main():
    """Main function to handle game replay"""
    while True:
        play_game()
        
        # Ask if players want to play again
        play_again = input("\nWould you like to play again? (yes/no): ").lower()
        if play_again not in ["yes", "y"]:
            print("\nThanks for playing Tic Tac Toe! Goodbye! 👋")
            break
        print("\n" + "=" * 30)


if __name__ == "__main__":
    main()