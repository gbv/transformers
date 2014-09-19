#!/bin/bash
. ../testrunner

XSLT=marcxml2mods.xsl

if [ "$#" -eq 0 ]
then
    xslt_tests marcxml2mods.xsl test/*.in.xml
else
    for file in "$@"
    do
        if [ -f "$file" ]
        then
            xslt_tests marcxml2mods.xsl "$file"
        elif [ -f "$file.in.xml" ]
        then
            xslt_tests marcxml2mods.xsl "$file.in.xml"
        elif [ -f "test/$file.in.xml" ]
        then
            xslt_tests marcxml2mods.xsl "test/$file.in.xml"
        else
            not_ok "test file not found: $file"
        fi
    done
fi

done_testing
