# This Makefile processes all test cases in directory test/

XSLTPROC=xsltproc
XSLTFILE=pica2safo.xsl

test:
	@N=0; \
	for INFILE in test/*.in.xml; do\
		OUTFILE=test/`basename $$INFILE .in.xml`.out.xml; \
		OKFILE=test/`basename $$INFILE .in.xml`.ok.xml; \
		N=$$(( n+1 )); \
		$(XSLTPROC) $(XSLTFILE) $$INFILE > $$OUTFILE; \
		if [ -f $$OKFILE ]; then \
			if diff $$OUTFILE $$OKFILE > /dev/null; then \
				echo ok $$N - $$INFILE =\> $$OKFILE; \
			else \
				echo not ok $$N - $$OUTFILE \!= $$OKFILE; \
				diff $$OUTFILE $$OKFILE | awk '{print "#",$$0}'; \
			fi; \
		else \
			echo not ok - missing file $$OKFILE; \
		fi; \
	done; \
	echo 1..$$N

clean:
	@rm -f test/*.out.xml

.PHONY: test clean
