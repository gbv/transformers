#!/bin/bash

RESULT=0

for DIR in *
do 
    if [ ! -d $DIR ]; then
        continue
    fi
    cd $DIR
    if [ -f "runtest.sh" ]
    then
        echo \# $DIR
        ls
        prove -v runtest.sh
        RESULT=$((RESULT+$?))
    else
        echo \# $DIR - no tests
    fi
    cd ..
done 

echo \# failed tests: $RESULT
exit $RESULT
