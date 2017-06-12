# transformers

This repository contains several XSLT scripts for transformation of bibliographic records, used in GBV library union network. In particular the scripts are used at the unAPI server unapi.gbv.de.

Each transformer script is located in one subdirectory named by input and output formats. Format names must match `[a-z][a-z0-9]*`, separated by `2`. For instance script `marcxml2mods.xsl` is located in directory `marcxml2mods`. Scripts must no use

Transformer scripts following this naming scheme are *daily synced to unapi.gbv.de* from the *master* branch of this repository, so **don't commit to the master branch unless you surely know what you are doing!**.

## Dependencies

XSLT scripts require an XSLT 1.0 or XSLT 2.0 processor. You should install both e.g. Saxon on Ubuntu:

    sudo apt-get install libsaxon-java  # Saxon (XSLT 1.0)
    sudo apt-get install libsaxonb-java # Saxon-B (XSLT 2.0)

## Unit tests

Unit tests can be added in subdirectory `test`. The Bash script `testrunner` automatically runs all available test cases in a directory, e.g.

    cd marcxml2mods
    ../testrunner

The script expects tests cases in subdirectory `test` with names `*.in.xml` for input and `*.ok.xml` for expected output.

To run tests of all transformers, call `testall.sh`.

[![Build Status](https://travis-ci.org/gbv/transformers.png)](https://travis-ci.org/gbv/transformers)

