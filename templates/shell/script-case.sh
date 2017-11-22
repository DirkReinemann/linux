#!/bin/bash

usage()
{
    echo "script short description"
    echo
    echo "Usage: $0 [start] [stop]"
    echo
    printf "  %-20s %s\n" "start" "command short description"
    printf "  %-20s %s\n" "stop" "command short description"
    exit 1
}

start()
{
    echo start
}

stop()
{
    echo stop
}

case $1 in
    start)
        start
        ;;
    stop)
        stop
        ;;
    *)
        usage
        ;;
esac

exit 0
