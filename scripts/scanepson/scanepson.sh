#!/bin/bash

usage()
{
    echo "scans from epson"
    echo
    echo "Usage: $0 [Options] [Filename]"
    echo
    echo "Options:"
    printf "  %-20s %s\n" "-r [NUMBER]" "sets the resolution (default: 150)"
    printf "  %-20s %s\n" "-c" "sets colored scan (default gray)"
    printf "  %-20s %s\n" "-p" "sets output to png (default pdf)"
    exit 1
}

RESOLUTION=150
MODE="Gray"
PDF=1
FILENAME=
OUTDIR="/home/dirk/Pictures/Scans"

start()
{
    if ! [[ $RESOLUTION =~ ^[0-9]*$ ]]; then
        usage
    fi

    if [ ! -d $OUTDIR ]; then
        mkdir -p $OUTDIR
    fi

    SCANNER=$(scanimage --list-devices | grep epson | grep -o "\`[A-Za-z0-9:.]*")
    if [ -z $SCANNER ]; then
        echo "The scanner was not found!"
        exit 2
    fi
    SCANNER=${SCANNER:1}
    FILENAME=${FILENAME%%.*}

    scanimage --device "$SCANNER" --resolution "$RESOLUTION" --mode $MODE --format=png > $OUTDIR/$FILENAME.png

    if [ $PDF -eq 1 ]; then
        convert $OUTDIR/$FILENAME.png $OUTDIR/$FILENAME.pdf
        rm $OUTDIR/$FILENAME.png
    fi
}

if [ $# == 0 ]; then
    usage
fi

while getopts "cpr:" OPT; do
    case $OPT in
    r)
        RESOLUTION=$OPTARG
        ;;
    c)
        MODE="Color"
        ;;
    p)
        PDF=0
        ;;
    \?)
        usage
        ;;
    :)
        usage
        ;;
    esac
done

shift $(( OPTIND - 1 ))

FILENAME=$@

if [ -z $FILENAME ]; then
    usage
fi

start

exit 0
