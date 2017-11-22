#!/bin/bash

dotfile=""
outfile=""

usage()
{
    echo "Converts dot file to png file."
    echo
    echo "Usage: $0 [Options] [Dotfile]"
    echo
    echo "Options:"
    printf "  %-20s %s\n" "-o" "output filename"
    exit 1
}

convert()
{
    local extension

    if [ ! -f $dotfile ]; then
        echo "The given file '$dotfile' doesn't exist."
        exit 1
    fi 

    extension=${dotfile##*.}
    if [ "$extension" != "dot" ]; then
        echo "The given dotfile '$dotfile' is not a dotfile."
        exit 2
    fi

    if [ -z  $outfile ]; then
        outfile=${dotfile%.*}
    fi

    extension=${outfile##*.}
    if [ "$extension" != "png" ]; then
        outfile="$outfile.png"
    fi

    dot -Tpng $dotfile -o $outfile
}

if [ $# -eq 0 ]; then
    usage
fi

while getopts "o:" opt; do
    case $opt in
    o)
        outfile=$OPTARG
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

dotfile=$@

convert

exit 0
