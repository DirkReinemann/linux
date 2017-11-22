#!/bin/bash

workdir="$HOME"
dirname=""

usage()
{
    echo "Search and opens the given directory."
    echo
    echo "Usage: $0 [Options] [Directory]"
    echo
    echo "Options:"
    printf "  %-20s %s\n" "-d" "the directory to search in (default=$HOME)"
    exit 1
}

pick()
{
    found=$1
    count=$2
    i=0
    printf "\e[39mFound the following directories:\n\n"
    for f in ${found[@]}; do
        printf "\e[32m[%d]\e[39m %s\n" $i $f
        i=$((i+1))
    done
    printf "\e[39m\n"
    read -p "Please choose a directory to open: " choice

    if  [[ $choice =~ ^[0-$((count-1))]$ ]]; then
        cd ${found[$choice]} && exec bash
    else
        printf "\e[31mThe given input '%s' is invalid.\e[39m\n" $choice
        exit 1
    fi
}

open()
{
    found=( $(find $workdir -type d -iname "*$dirname*") )
    count=${#found[@]}

    if [ $count -eq 0 ]; then
        printf "\e[31mThe given directory '%s' was not found.\e[39m\n" $dirname
        exit 1
    elif [ $count -eq 1 ]; then
        cd $found && exec bash
    elif [ $count -lt 11 ]; then
        pick $found $count
    else
        printf "\e[31mFound '%d' directories for directory '%s'. Please specify your directory.\e[39m\n" $count $dirname
        exit 1
    fi
}

if [ $# -eq 0 ]; then
    usage
fi

while getopts "d:" opt; do
    case $opt in
        d)
            workdir="$OPTARG"
        ;;
        \?)
            usage
        ;;
        :)
            usage
        ;;
    esac
done

shift $((OPTIND-1))

dirname=$@

if [ -z $dirname ]; then
    usage
fi

printf "\e[39m\nSearching in directory '$workdir':\n\n"
open
