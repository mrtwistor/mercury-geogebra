# TODO

## Backend implementations
1. Implement: conic, locus, ellipse, hyperbola, parabola, tangents, polar, (parallel) line,
line of best fit, polygon, (parametric) curve, point (on object)
1. Declarations of state: setColor, setAnimate, setStyle, etc
1. Modularize the main code.
1. More examples of macros.
1. Documentation (especially of macros).

## Frontend development
Declarative features of the front-end should also be implemented.  Such as specifying window geometry, axes, etc.  

Make a frontend (besides the current Geogebra target).  The frontend should be written in an object-oriented language with good graphics support.  The front-end should support a (limited) set of Geogebra primitives.  It will also need to implement some solvers for, at least, linear/quadratic equations, and (possibly) Newton's method in higher degree.

Object relations declared in the Mercury declarative language should be *immutable* (for example, declaring setColor("A","Red") from Mercury will should cause the object "A" to be colored red forever more).  Other object properties in the front-end should be mutable.  Those parameters and object properties that are not initialized by the Mercury script should be mutable in the frontend (and assume reasonable default values at initialization).  The frontend should support client/server communication with the controlling Mercury process.

## Concurrency model
The present implementation is serial: the Mercury process run once, and then the front-end process allows user interaction.  This is, obviously, less than ideal.

Our preferred model is one of server/client, in which the Mercury process is the client, and the frontend process the server.  Communication shall flow from client to server.  Queries issued by the client are interpreted by the server, which initializes objects at the request of the client, and also modifies their attributes at the client's request.  Values of attributes which are not (yet) specified by the client process may have any value, as specified by the needs of the server.  (For example, the end-user wanting some point to be blue.)  But, once declared, those values are immutable.

A client-to-server query will have the form such as a declaration:
````
line("AB","A","B").
````
or other more complicated examples as seen in geogebra.m.  Ultimately, stateful qualitiest of objects shall be managed with queries such as:
````
setColor("X","Blue").
setColor("Y",colorOf("X")).   %Not actual code
````

The server process will be required to promise not to destroy any objects created by queries, or modify their values from those created by prior queries.

## Server object exceptions
The interface for an object on the server should support the handing and propagation of exceptions.  For example, suppose we declare points "A" and "B":
````
point("A",0.0,0.0).
point("B",0.0,0.0).
line("AB","A",B").

setColor("AB","Blue").
setColor("B",colorOf("AB")).
````
should result in an object `AB` created, with values for all parameters specified by the system, except those generating an exception - e.g., `DivByZero`.  The remaining attributes and methods are still callable, and so the point ``B`` should be colored blue.  The line `AB` should fail to display, as the exception `DivByZero` propagates.

Objects resulting in exceptions need to be dynamically reinitialized whenever a query is made by a client.
