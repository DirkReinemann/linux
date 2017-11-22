#!/bin/bash

usage()
{
    echo "build script"
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-20s %s\n" "-i" "install programm"
    printf "  %-20s %s\n" "-u" "uninstall programm"
    exit 1
}

exec_check()
{
    eval $1 && {
        echo "SUCCESSFUL: $2"
    } || { 
        echo "FAILURE: $2"
        exit 1
    }
    echo $RES
}

install()
{
    exec_check "ls -l" ""
}

uninstall()
{
    echo stop
}

if [ $# == 0 ]; then
    usage
fi

while getopts "iu" OPT; do
    case $OPT in
    i)
        install
        ;;
    u)
        uninstall
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
