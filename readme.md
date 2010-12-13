# About

This is a small library for doing graphics on <canvas> elements. It's like
processing.js in its simple API, except there's no special language so apps
are written directly using javascript or coffeescript. And it heavily uses
method chaining, like jQuery. For an example application, check out [Wordman](https://github.com/ysimonson/wordman)

Create a new canvas like so:

    c = new Canvas(document.getElementById('container'))

where container is a canvas element.

# Basic Graphics

    c.clear()

Fills the screen with the background color

    c.arc(x, y, radius, start, end)

Draws an arc. Origin is at (x, y) with the specified radius. Start and end
are radians specifying the degrees at which the arc begins and ends.

    c.ellipse(x, y, radius, start, end)

Draws an ellipse. The top-left corner is at (x, y), and the ellipse has the
specified width and height.

    c.line(x1, y1, x2, y2)

Draws a line from (x1, y1) to (x2, y2).

    c.rectangle(x, y, width, height)

Draws a rectangle. Its top-left corner is at (x, y), and the rectangle has
the specified width and height.
    c.polygon(points...)

Draws a polygon given the vararg list of points. There must be an even
number of arguments.

# Bezier Curves

    c.bezier(points...)

Draws one or more bezier curves given the vararg list of points. The first
two points specify the start point. After that, sets of six arguments are
given: the first two specify the first control point, the second two
specify the second control point, and the last specifies the end point for
that part of the curve. For example:

    c.bezier(0, 0, 30, 20, 40, 50, 100, 100, 80, 60, 70, 90, 200, 200)

Would draw two bezier curves. The first would start at (0, 0) and end at
(100, 100). It would have control points at (30, 20) and (40, 50). The
second bezier curve would start at (100, 100) and end at (200, 200). It
would have control points at (80, 60) and (70, 90).

# Quadratic Curves

    c.quadratic(points...)

Draws one or more quadratic curves given the vararg list of points. The
first two points specify the start point. After that, sets of four
arguments are given: the first two specify the control point and the last
specifies the end point for that part of the curve. For example:

    quadratic(0, 0, 30, 20, 100, 100, 80, 60, 200, 200)

Would draw two quadratic curves. The first would start at (0, 0) and end at
(100, 100), with a control point at (30, 20). The second would start at
(100, 100) and end at (200, 200), with a control point at (80, 60).

# Images

    c.image(image, x, y, width, height, sliceX, sliceY, sliceWidth, sliceHeight)

Draws an image on the canvas. Image is a DOM image element, or a string
specifying where to fetch the image. x and y specify the position to draw
the image. The optional arguments width and height allow for
stretching/shrinking of the image drawn. The optional arguments sliceX,
sliceY, sliceWidth, sliceHeight allow you to just draw a part of the
specified image, which is useful for spriting.

Examples:

    image(img, 0, 0)

draws the image 'img' at (0, 0).

    image(img, 0, 0, 100, 50)

draws the image 'img' at (0, 0) with a width of 100 and a height of 50.

    image(img, 0, 0, 100, 50, 10, 10, 15, 20)

draws a rectangular part of the image 'img', from (10, 10) with a width of
15 and a height of 20. The image is drawn on the canvas at (0, 0) with a
width of 100 and a height of 50.

# Styling

    c.fill()

Enables fill for drawn objects

    c.noFill()

Removes fill for drawn objects

    c.fillStyle(style)

Sets the fill style for drawn objects. Style is a CSS string.

    c.stroke()

Enables stroke for drawn objects

    c.noStroke()

Removes the stroke for drawn objects

    c.strokeStyle(style)

Sets the stroke style for drawn objects. Style is a CSS string.
    c.strokeWeight(weight)

Sets the stroke weight (i.e. thickness) for drawn objects. Weight is a
number (int or float) specifying thickness.

    c.fontProps(props)

Sets the font properties according to the key/values passed in by the map.
Valid values include 'font', 'textAlign', and 'textBaseline'.

    c.background(style)

Sets the background style. Style is a CSS string.

# Other

    c.run(callback)

Runs a loop, redrawing the canvas at the rate specified by framerate. At
each loop iteration, the specified callback method is called, with its
context being this object. If the callback returns false, the loop is
broken out of.

    c.framerate(fps)

Sets the framerate for redrawing when the loop in run() is active.
