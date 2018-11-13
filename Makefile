
OUTPUT_FILENAME := $(shell tempfile -d ./ -s .ggb)
geogebra:
	rm $(OUTPUT_FILENAME)
	mmc geogebra.m
	./geogebra > ggb-applet/geogebra.xml
	(cd ggb-applet/ && zip -r ../$(OUTPUT_FILENAME) ./)
	geogebra $(OUTPUT_FILENAME)

clean:
	rm geogebra *.d *.o *.c_date *.c *.mh \
		file*.ggb ggb-applet/geogebra.xml

