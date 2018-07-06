#!/bin/bash

workdir="$(pwd)"
editor="vi"
filename=""
excludes=( ".git" "target" ".idea" )
maxfiles="20"

usage()
{
    echo "Search and opens the given filename."
    echo
    echo "Usage: $0 [Options] [Filename]"
    echo
    echo "Options:"
    printf "  %-20s %s\\n" "-d" "the directory to search in (default is the current directory)"
    exit 1
}

pick()
{
    local found count choice i f

    found="$1"
    count="$2"

    local i="1"
    printf "\\e[39mFound the following files:\\n\\n"
    for f in $found; do
        printf "\\e[32m[%d]\\e[39m %s\\n" "$i" "$f"
        i="$((i+1))"
    done
    printf "\\e[39m\\n"

    read -rp "Please choose a file to open: " choice

    if  [[ $choice =~ ^[1-$count]$ ]]; then
        $editor "$(printf "%s" "$found" | head -n "$choice" | tail -n 1)"
    else
        printf "\\e[31mThe given input '%s' is invalid.\\e[39m\\n" "$choice"
        exit 1
    fi
}

open()
{
    local found entry count

    found="$(find "$workdir" -type f -iname "*$filename*")"

    for entry in "${excludes[@]}"; do
        found="$(printf "%s" "$found" | grep -v "$entry")"
    done

    if [ -z "$found" ]; then
        count="0"
    else
        count="$(echo "$found" | wc -l)"
    fi

    if [ "$count" -eq "0" ]; then
        printf "\\e[31mThe given filename '%s' was not found.\\e[39m\\n" $filename
        exit 1
    elif [ "$count" -eq "1" ]; then
        $editor "$found"
    elif [ "$count" -le "$maxfiles" ]; then
        pick "$found" "$count"
    else
        printf "\\e[31mFound '%d' files for filename '%s'. Please specify your filename.\\e[39m\\n" "$count" "$filename"
        exit 1
    fi
}

if [ $# == 0 ]; then
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

filename=$*

if [ -z "$filename" ]; then
    usage
fi

printf "\\e[39m\\nSearching in directory '%s':\\n\\n" "$workdir"
open
