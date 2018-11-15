# TODO

## Backend implementations
1. Implement: conic, locus, ellipse, hyperbola, parabola, tangents, polar, (parallel) line,
line of best fit, polygon, (parametric) curve, point (on object)
1. Declarations of state: setColor, setAnimate, setStyle, etc
1. Modularize the main code.
1. More examples of macros.
1. Documentation (especially of macros).

## Concurrency model
The concurrency model at present has the Mercury process run once, and then the front-end process allows user interaction.  Ideally, this should be improved to a more flexible client-server model.  To implement this with the Geogebra frontend would require some Javascript (and the API seems to be poorly documented).

## Frontend development
Make a frontend (besides the current Geogebra target).  The frontend should be written in an object-oriented language with good graphics support.  The front-end should support a (limited) set of Geogebra primitives.  It will also need to implement some solvers for, at least, linear/quadratic equations, and (possibly) Newton's method in higher degree.

Object relations declared in the Mercury declarative language should be *immutable* (for example, declaring setColor("A","Red") from Mercury will should cause the object "A" to be colored red forever more).  Other object properties in the front-end should be mutable.  Those parameters and object properties that are not initialized by the Mercury script should be mutable in the frontend (and assume reasonable default values at initialization).  The frontend should support client/server communication with the controlling Mercury process.

It is important that no output that the Mercury engine produces should result in failure of the frontend, even in the event of exceptions like division by zero.  We propose a monadic model of exception handling, similar to the Haskell Maybe monad.  An object that results in an error in any parameter will still carry values for all of its attributes, but will simply fail to display.
