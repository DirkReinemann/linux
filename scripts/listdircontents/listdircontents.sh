#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: listdircontents.sh [DIRNAME]"
    exit 1
fi

if [ ! -d $1 ]; then
    echo "The given parameter '$1' isn't a directory."
    exit 2
fi

for f in $(find $1 -type f); do
    echo "$f:"
    cat $f
done

exit 0
