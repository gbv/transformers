#!/bin/bash
# Get a list of tags used in GNDLightXML (GNDXL)
xsltproc tags.xsl pica2gndlx.xsl | grep -v Error | LC_ALL=C sort | uniq
