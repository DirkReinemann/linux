#!/bin/bash

usage()
{
    echo "script short description"
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-20s %s\n" "-s" "command short description"
    printf "  %-20s %s\n" "-i" "command short description"
    exit 1
}

start()
{
    echo start $1
}

stop()
{
    echo stop
}

if [ $# == 0 ]; then
    usage
fi

while getopts "s:i" OPT; do
    case $OPT in
    s)
        start $OPTARG
        ;;
    i)
        stop $OPTARG
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
