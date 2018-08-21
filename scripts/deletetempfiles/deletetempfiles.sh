#!/bin/bash

patterns=( ".*~" ".*.swp" ".*\.log.[0-9]{1}" ".*\.[0-9]{1}.log.old" ".*\.[0-9]{1}.gz" ".*\.old" ".*_history" )
path="$(pwd)"
ask=0

usage()
{
    echo "Delete temporary files."
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-20s %s\n" "-d" "delete temporary files from path"
    printf "  %-20s %s\n" "-s" "show temporary files from path"
    printf "  %-20s %s\n" "-a" "ask before deleting the file"
    printf "  %-20s %s\n" "-p [Path]" "sets the path to search in (default is the current directory)"
    exit 1
}

delete()
{
    for pattern in ${patterns[@]}; do
        if [ $ask -eq 1 ]; then
            for file in $(sudo find $path -regextype posix-extended -regex $pattern); do
                sudo rm -i $file
            done
        else
            sudo find $path -regextype posix-extended -regex $pattern -print0 | xargs -0 -r sudo rm -v
        fi
    done
}

show()
{
    for pattern in ${patterns[@]}; do
        sudo find $path -regextype posix-extended -regex $pattern
    done
}

if [ $# -eq 0 ]; then
    usage
fi

state=0
while getopts "dsap:" opt; do
    case $opt in
        s)
            state=1
        ;;
        d)
            state=2
        ;;
        a)
            ask=1
        ;;
        p)
            path=$OPTARG
        ;;
        \?)
            usage
        ;;
        :)
            usage
        ;;
    esac
done

if [ ! -d $path ]; then
    "The given path '$path' doesn't exist."
    exit 2
fi

case $state in
    1)
        show
    ;;
    2)
        delete
    ;;
    *)
        usage
    ;;
esac

exit 0
