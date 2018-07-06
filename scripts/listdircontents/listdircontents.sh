#!/bin/bash

WORKDIR="$(pwd)"

print_usage()
{
    echo "Delete temporary files."
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-20s %s\n" "-d [Directory]" "sets the directory to list (default is the current directory)"
    exit 1
}

list_dir_contents()
{
    if [ ! -d "$WORKDIR" ]; then
        printf "The given directory '%s' doesn't exist.\n" "$WORKDIR"
        exit 2
    fi

    local file
    for file in $(find "$WORKDIR" -type f); do
        printf "\e[32m%s:\e[39m\n" "$file"
        cat "$file"
        echo
    done
}

while getopts "d:" opt; do
    case $opt in
        d)
            WORKDIR="$OPTARG"
        ;;
        \?)
            print_usage
        ;;
        :)
            print_usage
        ;;
    esac
done

list_dir_contents

exit 0
