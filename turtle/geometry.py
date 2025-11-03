import turtle

# Initialize the screen
screen = turtle.Screen()

geometry_turtle = turtle.Turtle()

geometry_turtle.speed(3)  # Set the speed of drawing
geometry_turtle.color("blue", "green")  # Outline color is black, fill color is red


def rectangle():
    geometry_turtle.begin_fill()

    geometry_turtle.forward(200)
    geometry_turtle.right(90)
    geometry_turtle.forward(200)
    geometry_turtle.right(90)
    geometry_turtle.forward(200)
    geometry_turtle.right(90)
    geometry_turtle.forward(200)
    geometry_turtle.right(90)

    geometry_turtle.end_fill()

rectangle()

geometry_turtle.penup()

geometry_turtle.left(45)
geometry_turtle.forward(200)

geometry_turtle.pendown()
geometry_turtle.color("black", "purple")
rectangle()

geometry_turtle.color("red", "teal")
geometry_turtle.begin_fill()
geometry_turtle.circle(100)
geometry_turtle.end_fill()

geometry_turtle.penup()

geometry_turtle.right(45)
geometry_turtle.backward(300)

geometry_turtle.pendown()
rectangle()

geometry_turtle.hideturtle()

screen.mainloop()