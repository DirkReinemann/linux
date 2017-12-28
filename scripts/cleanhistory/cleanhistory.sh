#!/bin/bash

configfile="/home/dirk/.config/cleanhistory.cnf"

usage()
{
    echo "Clean history files."
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-20s %s\\n" "-c" "clean history files"
    printf "  %-20s %s\\n" "-j" "clean journal log"
    printf "  %-20s %s\\n" "-p" "clean pacman cache"
    printf "  %-20s %s\\n" "-l" "list history files"
    printf "  %-20s %s\\n" "-t" "test history files"
    printf "  %-20s %s\\n" "-o" "remove unused pacman packages"
    exit 1
}

cleanfiles()
{
    while read -r line; do
        sudo rm -vrf "$line"
    done < $configfile
}

listfiles()
{
    while read -r line; do
        echo "$line"
    done < $configfile
}

checkfiles()
{
    while read -r line; do
        if [ ! -f "$line" ] && [ ! -d "$line" ]; then
            printf "\\e[31m%s\\n" "$line"
        else
            printf "\\e[32m%s\\n" "$line"
        fi
    done < $configfile
}

journallog()
{
    sudo journalctl --rotate --flush && sudo journalctl --vacuum-size=1K --vacuum-time=1s
}

pacmancache()
{
    sudo pacman -Sc --noconfirm
}

unusedpackages()
{
    local packages=""
    packages="$(pacman -Qtdq)"
    if [ ! -z "$packages" ]; then
        sudo pacman -Rns --noconfirm "$packages"
    fi
}

if [ $# == 0 ]; then
    usage
fi

if [ ! -f $configfile ]; then
    touch $configfile && echo "The configuration file '$configfile' was not found and therefore created."
fi

while getopts "cljpto" opt; do
    case $opt in
        c)
            cleanfiles
        ;;
        l)
            listfiles
        ;;
        j)
            journallog
        ;;
        p)
            pacmancache
        ;;
        t)
            checkfiles
        ;;
        o)
            unusedpackages
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
