# transformers

This repository contains several XSLT scripts for transformation of bibliographic records, used in GBV library union network. In particular the scripts are used at the unAPI server unapi.gbv.de.

Each transformer script is located in one subdirectory named by input and output formats. Format names must match `[a-z][a-z0-9]*`, separated by `2`. For instance script `marcxml2mods.xsl` is located in directory `marcxml2mods`. Scripts must no use

Transformer scripts following this naming scheme are *daily synced to unapi.gbv.de* from the *master* branch of this repository, so **don't commit to the master branch unless you surely know what you are doing!**.

## Unit tests

Unit tests can be added in subdirectory `test`. There must be a script called
`runtest.sh` in each transformer directory, to actually exectute the tests.
Test should print output in Tests Anything Protocol (TAP) format. To run tests
of all transformers, call `testall.sh`.

[![Build Status](https://travis-ci.org/gbv/transformers.png)](https://travis-ci.org/gbv/transformers)

See `testrunner` for useful bash functions to write tests.

