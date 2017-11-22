#!/bin/bash

workdir="$HOME"
editor=vi
filename=""

usage()
{
    echo "Search and opens the given filename."
    echo
    echo "Usage: $0 [Options] [Filename]"
    echo
    echo "Options:"
    printf "  %-20s %s\n" "-d" "the directory to search in (default=$HOME)"
    exit 1
}

pick()
{
    local found=$1
    local count=$2
    local i=0
    printf "\e[39mFound the following files:\n\n"
    for f in ${found[@]}; do
        printf "\e[32m[%d]\e[39m %s\n" $i $f
        i=$((i+1))
    done
    printf "\e[39m\n"
    read -p "Please choose a file to open: " choice

    if  [[ $choice =~ ^[0-$((count-1))]$ ]]; then
        $editor ${found[$choice]}
    else
        printf "\e[31mThe given input '%s' is invalid.\e[39m\n" $choice
        exit 1
    fi
}

open()
{
    found=( $(find $workdir -type f -iname "*$filename*") )
    count=${#found[@]}

    if [ $count -eq 0 ]; then
        printf "\e[31mThe given filename '%s' was not found.\e[39m\n" $filename
        exit 1
    elif [ $count -eq 1 ]; then
        $editor $found
    elif [ $count -lt 11 ]; then
        pick $found $count
    else
        printf "\e[31mFound '%d' files for filename '%s'. Please specify your filename.\e[39m\n" $count $filename
        exit 1
    fi
}

if [ $# == 0 ]; then
    usage
fi

while getopts "d:" opt; do
    case $opt in
        d) workdir="$OPTARG" ;;
    esac
done

shift $((OPTIND-1))

filename=$@

if [ -z $filename ]; then
    usage
fi

printf "\e[39m\nSearching in directory '$workdir':\n\n"
open
