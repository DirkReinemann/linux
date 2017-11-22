#!/bin/bash

extensions=( aux bbl bcf blg glg glo gls ist lof log out run.xml synctex.gz toc pdf nav snm )
mode=""

usage()
{
    echo "latex helper to build, clean, show texfiles"
    echo
    echo "Usage: $0 [Build Mode] [Command]"
    echo
    echo "Build Modes:"
    printf "  %-20s %s\n" "-n" "pdflatex"
    printf "  %-20s %s\n" "-a" "pdflatex,biber,makeglossaries,pdflatex,pdflatex"
    echo
    echo "Commands:"
    printf "  %-20s %s\n" "-b [Filename]" "build texfile"
    printf "  %-20s %s\n" "-r [Filename]" "remove all latex build files"
    printf "  %-20s %s\n" "-o [Filename]" "open latex pdf file"
    exit 1
}

remove()
{
    local name="$1"
    for extension in "${extensions[@]}"; do
        if [ -f "$name.$extension" ]; then
            rm "$name.$extension"
        fi
    done
}

open()
{
    local name="$1"
    if [ -f "$name.pdf" ]; then
        xdg-open $name.pdf > /dev/null 2>&1 &
    else
        echo "The given filename '$name.pdf' doesn't exist."
        exit 1
    fi
}

build()
{
    if [ -z $mode ]; then
        echo "You have to provide a build mode."
        exit 2
    fi

    if [ -f "$1.tex" ]; then
        case $mode in
            a)
                pdflatex -synctex=1 -interaction=nonstopmode $1.tex
                makeglossaries $TEX_FILENAME
                biber $TEX_FILENAME
                pdflatex -synctex=1 -interaction=nonstopmode $1.tex
                pdflatex -synctex=1 -interaction=nonstopmode $1.tex
            ;;
            n)
                pdflatex -synctex=1 -interaction=nonstopmode $1.tex
            ;;
            *)
                echo "The given build mode '$mode' doesn't exist."
                exit 4
            ;;
        esac
    else
        echo "The given filename '$1.tex' doesn't exist."
        exit 3
    fi
}

if [ $# == 0 ]; then
    usage
fi

while getopts ":o:r:b:na" OPT; do
    case $OPT in
        o)
            open $OPTARG
        ;;
        b)
            build $OPTARG
        ;;
        r)
            remove $OPTARG
        ;;
        n)
            mode="n"
        ;;
        a)
            mode="a"
        ;;
        \?)
            usage
        ;;
        :)
            usage
        ;;
    esac
done

exit 0
