# mercury-geogebra
A set of [Geogebra](https://geogebra.org) bindings for the [Mercury language](https://www.mercurylang.org)

## Installation
This requires a working installation of the Mercury language,
with the `mmc` executable in the path of the command 
line.  

To build using the Makefile requires GNU make.  The
package can be compiled with:
````
make ggb
````
This works whether there is a working Geogebra
installation or not, but requires ``zip`` to be on the command 
line.  If the `geogebra` executable is also on the 
command-line, then
````
make demo
````
builds the package and launches Geogebra on it.

## Usage
Edit the User section of the file `geogebra.m`, and see
that file for examples.

## More information on aims
See TODO.md
