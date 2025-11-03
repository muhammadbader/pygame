import turtle
import random

# Initialize the screen
screen = turtle.Screen()
screen.title("Math Calculator with Turtle")

# Initialize the turtle for displaying text
text_turtle = turtle.Turtle()
text_turtle.penup()
text_turtle.hideturtle()

# Initialize a turtle for selecting answers
selector_turtle = turtle.Turtle()
selector_turtle.shape("triangle")
selector_turtle.penup()

# Math question variables
correct_answer = 0
answers = []
selected_index = 0

# Function to generate a new question
def generate_question():
    global correct_answer, answers, selected_index
    selected_index = 0

    # Random math question
    num1 = random.randint(1, 10)
    num2 = random.randint(1, 10)
    correct_answer = num1 + num2
    answers = [correct_answer, correct_answer + random.randint(1, 3), correct_answer - random.randint(1, 3)]
    random.shuffle(answers)

    # Display the question
    text_turtle.clear()
    text_turtle.goto(0, 100)
    text_turtle.write(f"What is {num1} + {num2}?", align="center", font=("Arial", 24, "bold"))

    # Display the answers
    for i in range(3):
        text_turtle.goto(0, 50 - i * 30)
        text_turtle.write(f"{i + 1}: {answers[i]}", align="center", font=("Arial", 18, "normal"))

    # Place the selector turtle
    update_selector()

# Function to update the selector position
def update_selector():
    selector_turtle.goto(-50, 50 - selected_index * 30)

# Functions to handle arrow key presses
def move_up():
    global selected_index
    if selected_index > 0:
        selected_index -= 1
        update_selector()

def move_down():
    global selected_index
    if selected_index < 2:
        selected_index += 1
        update_selector()

def check_answer():
    if answers[selected_index] == correct_answer:
        text_turtle.goto(0, -50)
        text_turtle.write("Correct!", align="center", font=("Arial", 24, "bold"))
    else:
        text_turtle.goto(0, -50)
        text_turtle.write("Incorrect, try again.", align="center", font=("Arial", 24, "bold"))
    screen.ontimer(generate_question, 2000)

# Key bindings
screen.listen()
screen.onkey(move_up, "Up")
screen.onkey(move_down, "Down")
screen.onkey(check_answer, "space")

# Generate the first question
generate_question()

# Keep the window open
screen.mainloop()
