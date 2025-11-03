import turtle

# Initialize the screen
screen = turtle.Screen()

def quit_program():
    screen.bye()  

screen.listen()
screen.onkey(quit_program, "q")

# Initialize the turtle
my_turtle = turtle.Turtle()

# Set the turtle's attributes (optional)
my_turtle.shape("turtle")  # Change the shape to a turtle
# 'arrow', 'circle', 'classic', 'square', 'triangle', and 'turtle'.
# my_turtle.color("blue")    # Set the color of the turtle
my_turtle.speed(1)
# Move the turtle forward
my_turtle.rt(90)  # riht
my_turtle.fd(100)  # forward
my_turtle.lt(90)  # left
my_turtle.bk(100) # backward

# End the turtle graphics
screen.mainloop()  # Keeps the window open until you close it
