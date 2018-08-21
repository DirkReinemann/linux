#!/bin/bash

OUTDIR="/tmp"

if [ $# -ne 1 ]; then
    printf "Usage: $0 [FILENAME]\n"
    exit 1
fi

if [ ! -f $1 ]; then
    printf "The given file '$1' doesn't exist.\n"
    exit 1
fi

hash pandoc >/dev/null 2>&1

if [ $? -ne 0 ]; then
    printf "You have to install pandoc.\n"
    exit 1
fi

hash firefox >/dev/null 2>&1

if [ $? -ne 0 ]; then
    printf "You have to install firefox.\n"
    exit 1
fi

NAME=$(basename $1)
OUTFILE="$OUTDIR/$NAME.html"

pandoc -f markdown -t html -o $OUTFILE -s $1 --metadata title="$NAME" && firefox --new-tab $OUTFILE

exit 0
