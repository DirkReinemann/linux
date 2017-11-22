#!/bin/bash

backupdir="$HOME/Projects/Private/private/backup"
configfile="$HOME/.config/backupgit.cnf"

usage()
{
    echo "Backup acript for files and directories."
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-20s %s\n" "-l" "list backup files and directories"
    printf "  %-20s %s\n" "-b" "backup files and directories"
    exit 1
}

list()
{
    while read line; do
        echo $line
    done < $configfile
}

backup()
{
    if [ ! -d $backupdir ]; then
        mkdir -p $backupdir && echo "The backup directory '$backupdir' was not found and therefore created."
    fi

    # backup files and directories from backupfile
    while read line; do
        rsync -avchR --delete --stats $line $backupdir
    done < $configfile

    # backup mozilla firefox bookmarks
    local bookmarkdir=$(find $HOME/.mozilla/firefox -maxdepth 1 ! -path [PATH] -type d | grep 'default$' | head -1)/bookmarkbackups
    local bookmarkdfile=$(ls -1 $bookmarkdir | sort -r | head -1)

    local bookmarkbackupdir="$backupdir$HOME/.mozilla/firefox"
    if [ ! -d $bookmarkbackupdir ]; then
        mkdir -p $bookmarkbackupdir
    fi

    local bookmarkbackupfile=bookmarks.${bookmarkfile#*.}
    cp -f $bookmarkdir/$bookmarkfile $bookmarkbackupdir/$bookmarkbackupfile

    # backup thunderbird feed urls
    local feeddir=$(find $HOME/.thunderbird -maxdepth 1 ! -path [PATH] -type d | grep 'default$' | head -1)/Mail/Feeds
    local feedfile="$feeddir/feeds.rdf"

    local feedbackupdir="$backupdir$HOME/.thunderbird"
    if [ ! -d $feedbackupdir ]; then
        mkdir -p $feedbackupdir
    fi

    local feedbackupfile="$feedbackupdir/feeds.txt"
    grep 'fz:feed RDF:about' $feedfile | sed -e 's/^[ \t]*//' | sed 's/<fz:feed RDF:about="//' | sed 's/"$//' | sort -u > $feedbackupfile

    # backup rhythmboxs radio stations
    local rhythmboxdir="$HOME/.local/share/rhythmbox"
    local rhythmboxfile="$rhythmboxdir/rhythmdb.xml"
    local rhythmboxbackupdir="$backupdir$rhythmboxdir"
    local rhythmboxbackupfile="$backupdir$rhythmboxfile"

    if [ ! -d $rhythmboxbackupdir ]; then
        mkdir -p $rhythmboxbackupdir
    fi

    rm $rhythmboxbackupfile

    echo '<?xml version="1.0" standalone="yes"?>' >> $rhythmboxbackupfile
    echo '<rhythmdb version="2.0">' >> $rhythmboxbackupfile
    xmlstarlet sel -I -t -c '//entry[@type="iradio"]' ~/.local/share/rhythmbox/rhythmdb.xml >> $rhythmboxbackupfile
    echo '</rhythmdb>' >> $rhythmboxbackupfile
}

if [ $# == 0 ]; then
    usage
fi

if [ ! -f $configfile ]; then
    touch $configfile && echo "The configuration file '$configfile' was not found and therefore created."
fi

while getopts "lb" opt; do
    case $opt in
        l)
            list
        ;;
        b)
            backup
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
