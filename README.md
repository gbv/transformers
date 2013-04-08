# transformers

This repository contains several scripts for transformation of bibliographic
records, used in GBV library union network (*Kommentare sind auch auf Deutsch
möglich*).

# Structure

Each script is in one subdirectory named by input and output formats.

# List of transformers

## marcxml2mods

Für den GBV angepasste Version des XSL-Stylesheets der LOC für die
Transformation von MARCXML nach MODS3.4

## pica2safo (to be renamed to pica2gndlx)

Developer version of transformation from GND authority records in PICAXML to
GND Light XML.

## mods2rdf

Experimental transformation from MODS to RDF/XML

## gndlx2mads

Experimental transformation from GNDLX to MADS

# Related work

This repository does not contain specific tools for (mass) conversion of records
but only the scripts for single steps.

* The [CultureGraph](http://www.culturegraph.org/) project has developed a tool
  suite for metadata processing, called [metafacture](https://github.com/culturegraph/metafacture-core/wiki).
* [LibreCat/Catmandu](http://www.librecat.org/) includes a metadata conversion
  framework
* ...

