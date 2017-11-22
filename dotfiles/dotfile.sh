#!/bin/bash

backupdir=$(pwd)
configfile="dotfile.cnf"

usage()
{
    echo "Dotfile helper script."
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-20s %s\n" "-l" "list files and directories"
    printf "  %-20s %s\n" "-b" "backup files and directories"
    printf "  %-20s %s\n" "-c" "check for file changes"
    printf "  %-20s %s\n" "-s" "sort and remove duplicates from config file"
    exit 1
}

list()
{
    echo $backupdir

    while read line; do
        echo $line
    done < $configfile
}

backup()
{
    cd $HOME
    while read line; do
        rsync -avchR --delete --stats $line $backupdir
    done < $backupdir/$configfile
}

check()
{
    while read line; do
        diff -rq $line $HOME/$line
    done < $configfile
}

uniquesort()
{
    sort -u $configfile | sponge $configfile
}

if [ $# == 0 ]; then
    usage
fi

if [ ! -f $configfile ]; then
    echo "The configuration file '$configfile' was not found."
    exit 1
fi

if [[ ! $backupdir =~ dotfiles$ ]]; then
    echo "The backup directory '$backupdir' is not correct."
    exit 1
fi

while getopts "lcbs" opt; do
    case $opt in
        l)
            list
        ;;
        b)
            backup
        ;;
        c)
            check
        ;;
        s)
            uniquesort
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
