
OUTPUT_FILENAME := $(shell tempfile -d ./ -s .ggb)
demo: ggb
	geogebra $(OUTPUT_FILENAME)

#If Geogebra is not accessible from the command line, you can still build the app:
ggb: xml
	(cd ggb-applet/ && zip -r ../$(OUTPUT_FILENAME) ./)

#Or just the XML source:
xml:
	rm $(OUTPUT_FILENAME)
	mmc mmcggb.m
	./mmcggb > ggb-applet/geogebra.xml


#Java/Erlang/Csharp targets (experimental):
java:
	rm $(OUTPUT_FILENAME)
	mmc --make --java --gc automatic mmcggb


#Erlang compilation in Mercury is currently broken, so YMMV.
erlang:
	rm $(OUTPUT_FILENAME)
	mmc --make --erlang --gc automatic mmcggb

csharp:
	rm $(OUTPUT_FILENAME)
	mmc --make --csharp --gc automatic mmcggb


.PHONY: clean
clean:
	-rm -rf Mercury
	-rm -f mmcggb *.d *.o *.c_date *.c *.mh *.jar \
		*.erl *.erl_date *.java_date *.exe *.hrl \
		*.err *.dump file*.ggb ggb-applet/geogebra.xml 


