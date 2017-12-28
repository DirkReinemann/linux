#!/bin/bash

workdir="$HOME"
dirname=""
excludes=( ".git" "target" ".idea" )
maxdirs="20"

usage()
{
    echo "Search and opens the given directory."
    echo
    echo "Usage: $0 [Options] [Directory]"
    echo
    echo "Options:"
    printf "  %-20s %s\\n" "-d" "the directory to search in (default=$HOME)"
    exit 1
}

pick()
{
    local found count choice i f

    found="$1"
    count="$2"

    printf "\\e[39mFound the following directories:\\n\\n"
    i="1"
    for f in $found; do
        printf "\\e[32m[%02d]\\e[39m %s\\n" "$i" "$f"
        i="$((i+1))"
    done
    printf "\\e[39m\\n"

    read -rp "Please choose a directory to open: " choice

    if  [[ $choice =~ ^[1-$count]$ ]]; then
        cd "$(printf "%s" "$found" | head -n "$choice" | tail -n 1)" && exec bash
    else
        printf "\\e[31mThe given input '%s' is invalid.\\e[39m\\n" "$choice"
        exit 1
    fi
}

open()
{
    local found entry count

    found="$(find "$workdir" -type d -iname "*$dirname*")"

    for entry in "${excludes[@]}"; do
        found="$(printf "%s" "$found" | grep -v "$entry")"
    done

    if [ -z "$found" ]; then
        count="0"
    else
        count="$(echo "$found" | wc -l)"
    fi

    if [ "$count" -eq "0" ]; then
        printf "\\e[31mThe given directory '%s' was not found.\\e[39m\\n" "$dirname"
        exit 1
    elif [ "$count" -eq "1" ]; then
        cd "$found" && exec bash
    elif [ "$count" -le "$maxdirs" ]; then
        pick "$found" "$count"
    else
        printf "\\e[31mFound '%d' directories for directory '%s'. Please specify your directory.\\e[39m\\n" "$count" "$dirname"
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

dirname="$*"

if [ -z "$dirname" ]; then
    usage
fi

printf "\\e[39m\\nSearching in directory '%s':\\n\\n" "$workdir"
open
