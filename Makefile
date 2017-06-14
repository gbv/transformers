formats.svg: formats.dot
	dot $< -Tsvg -o$@

formats.dot:
	./formats.pl > formats.dot
