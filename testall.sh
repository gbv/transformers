#!/bin/bash

RESULT=0

for DIR in *
do     
    if [ ! -d $DIR ]; then
        continue
    fi
    if [ ! -e $DIR/$DIR.xsl ]; then
        continue
    fi
    cd $DIR
    echo "### $DIR"
    prove -v ../testrunner
    RESULT=$((RESULT+$?))
    cd ..
done 

echo \# failed tests: $RESULT
exit $RESULT
