#!/bin/bash
. ../testrunner

if [ "$#" -eq 0 ]
then
    xslt_tests pica2gndlx.xsl test/*.in.xml
else
    for file in "$@"
    do
        if [ -f "$file" ]
        then
            xslt_tests pica2gndlx.xsl "$file"
        elif [ -f "$file.in.xml" ]
        then
            xslt_tests pica2gndlx.xsl "$file.in.xml"
        elif [ -f "test/$file.in.xml" ]
        then
            xslt_tests pica2gndlx.xsl "test/$file.in.xml"
        else
            not_ok "test file not found: $file"
        fi
    done
fi

done_testing
