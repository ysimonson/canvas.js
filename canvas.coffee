class Canvas
    # Creates a new canvas object. Takes in a canvas DOM element.
    constructor: (canvas) ->
        if not canvas.getContext then throw "Canvas not supported"
        
        @context = canvas.getContext '2d'
        @_doStroke = true
        @_doFill = false 
        @_background = 'white'
        @_framerate = 30.0
        @width = canvas.getAttribute 'width'
        @height = canvas.getAttribute 'height'
        
    # Starts a new path at the specified (x, y) position.
    _startPath: (x, y) ->
        @context.beginPath()
        if x != undefined and y != undefined then @context.moveTo x, y
        
    # Finishes a path. Closes the path if closePath is true (i.e. if the first
    # and last points don't touch, then it will add a line between the two
    # positions.) Fills in the object if enabled. Adds a stroke to the object
    # as well.
    _finishPath: (closePath) ->
        if closePath then @context.closePath()
        if @_doFill then @context.fill()
        if @_doStroke then @context.stroke()
        this
        
    # Runs a loop, redrawing the canvas at the rate specified by framerate. At
    # each loop iteration, the specified callback method is called, with its
    # context being this object. If the callback returns false, the loop is
    # broken out of.
    run: (callback) ->
        self = this
        result = true
        
        # Create a callback that will be executed periodically.
        timer = () ->
            # Clear the canvas, then run the input callback. Set a timer to
            # rerun this function at the specified framerate.
            if result is false then return
            self.clear()
            result = callback.apply self
            setTimeout timer, 1000.0 / self._framerate
            
        # Run the callback for the first time.
        timer()
    
    # Enables fill for drawn objects.
    fill: () ->
        @_doFill = true
        this
        
    # Removes fill for drawn objects.
    noFill: () ->
        @_doFill = false
        this
        
    # Sets the fill style for drawn objects. Style is a CSS string.
    fillStyle: (style) ->
        if style is undefined then return @context.fillStyle
        @context.fillStyle = style
        this
        
    # Enables stroke for drawn objects.
    stroke: () ->
        @_doStroke = true
        this
        
    # Removes the stroke for drawn objects.
    noStroke: () ->
        @_doStroke = false
        this
        
    # Sets the stroke style for drawn objects. Style is a CSS string.
    strokeStyle: (style) ->
        if style is undefined then return @context.strokeStyle
        @context.strokeStyle = style
        this
        
    # Sets the stroke weight (i.e. thickness) for drawn objects. Weight is a
    # number (int or float) specifying thickness.
    strokeWeight: (weight) ->
        if weight is undefined then return @context.lineWidth
        @context.lineWidth = weight
        this
        
    # Sets the font properties according to the key/values passed in by the
    # map. Valid values include 'font', 'textAlign', and 'textBaseline'.
    fontProps: (props) ->
        for prop in ['font', 'textAlign', 'textBaseline'] when props[prop] != undefined
            @context[prop] = props[prop]
        this
        
    # Sets the background style. Style is a CSS string.
    background: (style) ->
        if style is undefined then return @_background
        @_background = style
        this
        
    # Fills the screen with the background color.
    clear: ->
        oldFillStyle = @context.fillStyle
        @context.fillStyle = @_background
        @context.fillRect 0, 0, @width, @height
        @context.fillStyle = oldFillStyle
        this
        
    # Sets the framerate for redrawing when the loop in run() is active.
    framerate: (fps) ->
        if fps is undefined then return @_framerate
        @_framerate = fps
        this
        
    # Draws an arc. Origin is at (x, y) with the specified radius. Start and
    # end are radians specifying the degrees at which the arc begins and ends.
    arc: (x, y, radius, start, end) ->
        @context.arc x, y, radius, start, end, true
        @_finishPath()
        
    # Draws an ellipse. The top-left corner is at (x, y), and the ellipse has
    # the specified width and height. Based off of
    # http://stackoverflow.com/questions/2172798/how-to-draw-an-oval-in-html5-canvas
    ellipse: (x, y, width, height) ->
        kappa = 0.5522848
        ox = width / 2 * kappa
        oy = height / 2 * kappa
        xe = x + width
        ye = y + height
        xm = x + width / 2
        ym = y + width / 2
        
        @_startPath()

        @context.moveTo x, ym
        @context.bezierCurveTo x,       ym - oy, xm - ox, y,       xm,     y
        @context.bezierCurveTo xm + ox, y,       xe,      ym - oy, xe,     ym
        @context.bezierCurveTo xe,      ym + oy, xm + ox, ye,      xm,     ye
        @context.bezierCurveTo xm - ox, ye,      x,       ym + oy, x,      ym
        
        @_finishPath true
    
    # Draws a line from (x1, y1) to (x2, y2).
    line: (x1, y1, x2, y2) ->
        @_startPath x1, y1
        @context.lineTo x2, y2 
        @context.stroke()
        this
        
    # Draws a rectangle. Its top-left corner is at (x, y), and the rectangle
    # has the specified width and height.
    rectangle: (x, y, width, height) ->
        @context[if @_doFill then 'fillRect' else 'strokeRect'] x, y, width, height
        this
        
    # Draws a polygon given the vararg list of points. There must be an even
    # number of arguments.
    polygon: (points...) ->
        @_startPath points[0], points[1]
        
        for i in [2...points.length] by 2
            @context.lineTo points[i], points[i + 1]
            
        @_finishPath()
    
    # Draws one or more bezier curves given the vararg list of points. The
    # first two points specify the start point. After that, sets of six
    # arguments are given: the first two specify the first control point, the
    # second two specify the second control point, and the last specifies the
    # end point for that part of the curve. For example:
    #    bezier(0, 0, 30, 20, 40, 50, 100, 100, 80, 60, 70, 90, 200, 200)
    # Would draw two bezier curves. The first would start at (0, 0) and end at
    # (100, 100). It would have control points at (30, 20) and (40, 50). The
    # second bezier curve would start at (100, 100) and end at (200, 200). It
    # would have control points at (80, 60) and (70, 90).
    bezier: (points...) ->
        @_startPath points[0], points[1]
        
        for i in [2...points.length] by 6
            @context.bezierCurveTo points[i..i+5]...
            
        @_finishPath()
        
    # Draws one or more quadratic curves given the vararg list of points. The
    # first two points specify the start point. After that, sets of four
    # arguments are given: the first two specify the control point and the
    # last specifies the end point for that part of the curve. For example:
    #    quadratic(0, 0, 30, 20, 100, 100, 80, 60, 200, 200)
    # Would draw two quadratic curves. The first would start at (0, 0) and end
    # at (100, 100), with a control point at (30, 20). The second would start
    # at (100, 100) and end at (200, 200), with a control point at (80, 60).
    quadratic: (points...) ->
        @_startPath()
        
        for i in [2...points.length] by 4
            @context.quadraticCurveTo points[i..i+3]...
            
        @_finishPath()
        
    # Draws an image on the canvas. Image is a DOM image element, or a string
    # specifying where to fetch the image. x and y specify the position to
    # draw the image. The optional arguments width and height allow for
    # stretching/shrinking of the image drawn. The optional arguments sliceX,
    # sliceY, sliceWidth, sliceHeight allow you to just draw a part of the
    # specified image, which is useful for spriting.
    # Examples:
    #    image(img, 0, 0)
    # draws the image 'img' at (0, 0).
    #    image(img, 0, 0, 100, 50)
    # draws the image 'img' at (0, 0) with a width of 100 and a height of 50.
    #    image(img, 0, 0, 100, 50, 10, 10, 15, 20)
    # draws a rectangular part of the image 'img', from (10, 10) with a width
    # of 15 and a height of 20. The image is drawn on the canvas at (0, 0) 
    # with a width of 100 and a height of 50.
    image: (image, x, y, width, height, sliceX, sliceY, sliceWidth, sliceHeight) ->
        imageObj = null
        self = this
        
        # This callback is executed when the image is loaded.
        callback = ->
            if width != undefined and height != undefined
                # Enable stretching/shrinking.
                
                if sliceX != undefined and sliceY != undefined and sliceWidth != undefined and sliceHeight != undefined
                    # Enable stretching/shrinking with spriting.
                    self.context.drawImage imageObj, sliceX, sliceY, sliceWidth, sliceHeight, x, y, width, height
                else
                    self.context.drawImage imageObj, x, y, width, height
            else
                # Draw the entire image, at scale, at (x, y).
                self.context.drawImage imageObj, x, y
            
        if image instanceof String
            # If the image is a string, we need to create a new Image DOM
            # element and load it. Execute callback when the image is done
            # loading.
            imageObj = new Image()
            imageObj.onload = callback
            imageObj.src = image
            
        else
            # Otherwise the image must be a DOM element. Draw it.
            imageObj = image
            callback()
            
        this
    
    # Draws text. Its top-left corner is at (x, y), and the text has the
    # specified width.    
    text: (text, x, y, width) ->
        @context[if @_doFill then 'fillText' else 'strokeText'] text, x, y, width
        this

window.Canvas = Canvas