#!/bin/bash

BASE=https://lazardb.gbv.de/api/plugin/base/oai/oai

GetRecordURL () {
    echo "$BASE?verb=GetRecord&identifier=$2&metadataPrefix=$3"
}


# guess format from directory name
FORMAT=$(pwd | xargs basename | cut -f2 -d2)

IDENTIFIER="$1"
FORMAT="${2:-$FORMAT}"

if [ $# -lt 1 ]; then
    echo 1>&2 "missing identifier to get in format $FORMAT"
    exit 2
fi
