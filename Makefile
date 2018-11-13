
OUTPUT_FILENAME := $(shell tempfile -d ./ -s .ggb)
demo: ggb
	geogebra $(OUTPUT_FILENAME)

#If Geogebra is not accessible from the command line, you can still build the app:
ggb: xml
	(cd ggb-applet/ && zip -r ../$(OUTPUT_FILENAME) ./)

#Or just the XML source:
xml:
	rm $(OUTPUT_FILENAME)
	mmc geogebra.m
	./geogebra > ggb-applet/geogebra.xml

clean:
	rm geogebra *.d *.o *.c_date *.c *.mh \
		file*.ggb ggb-applet/geogebra.xml

