import turtle

# Initialize the screen
screen = turtle.Screen()

# Initialize the turtle
sword_turtle = turtle.Turtle()

# Set up the turtle
sword_turtle.speed(1)  # Set the speed of drawing
sword_turtle.color("red", "yellow")  # Outline color is black, fill color is red

# Start filling the shape
sword_turtle.begin_fill()

# Draw the blade
sword_turtle.forward(10)
sword_turtle.left(90)
sword_turtle.forward(150)
sword_turtle.right(90)
sword_turtle.forward(20)
sword_turtle.right(90)
sword_turtle.forward(150)
sword_turtle.left(90)
sword_turtle.forward(10)

# Draw the guard (horizontal part)
sword_turtle.right(90)
sword_turtle.forward(20)
sword_turtle.right(90)
sword_turtle.forward(15)
sword_turtle.left(90)
sword_turtle.fd(40)
sword_turtle.rt(90)
sword_turtle.fd(10)
sword_turtle.rt(90)
sword_turtle.fd(40)
sword_turtle.lt(90)
sword_turtle.forward(15)


sword_turtle.right(90)
sword_turtle.forward(20)
sword_turtle.right(90)
sword_turtle.forward(40)

# End filling the shape
sword_turtle.end_fill()

# Hide the turtle
sword_turtle.hideturtle()

# Keep the window open until you close it
screen.mainloop()
