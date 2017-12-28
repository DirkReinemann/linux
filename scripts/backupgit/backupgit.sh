#!/bin/bash

backupdir="$HOME/Projects/Private/private/backup"
backupconfig="$HOME/.config/backup.cnf"
dotfiledir="$HOME/Projects/Private/linux/dotfiles"
dotfileconfig="$HOME/.config/dotfile.cnf"

usage()
{
    echo "Backup acript for files and directories."
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-20s %s\\n" "-l" "list backup files and directories"
    printf "  %-20s %s\\n" "-b" "backup files and directories"
    printf "  %-20s %s\\n" "-f" "backup firefox bookmarks"
    printf "  %-20s %s\\n" "-r" "backup rhythmbox radio stations"
    printf "  %-20s %s\\n" "-t" "backup thunderbird feeds"
    printf "  %-20s %s\\n" "-c" "clean duplicates in configfile)"
    printf "  %-20s %s\\n" "-d" "diff backup with system files"
    exit 1
}

blist()
{
    local line

    echo "$1"
    while read -r line; do
        echo "$line"
    done < "$2"
    echo ""
}

remove_homepath()
{
    printf "%s" "$line" | sed "s%$HOME/%%"
}

bfiles()
{
    local line

    if [ ! -z "$3" ]; then
        cd "$HOME" || exit 1
    fi

    printf "Backup entries from file '%s' to dir '%s' ... " "$2" "$1"
    while read -r line; do
        if [ -z "$3" ]; then
            rsync -achqR --delete --stats "$line" "$1"
        else
            line="$(remove_homepath "$line")"
            rsync -achqR --delete --stats "$line" "$1"
        fi
    done < "$2"
    printf "done.\\n"
}

bdiff()
{
    local line

    if [ ! -z "$4" ]; then
        cd "$HOME" || exit 1
    fi

    echo "$1"
    while read -r line; do
        if [ -z "$4" ]; then
            diff -rq "$2$line" "$line"
        else
            line="$(remove_homepath "$line")"
            diff -rq "$2/$line" "$line"
        fi
    done < "$3"
    echo ""
}

bfirefox()
{
    local bookmarkdir bookmarkfile bookmarkbackupdir bookmarkbackupfile

    bookmarkdir=$( \
        find "$HOME/.mozilla/firefox" -maxdepth 1 -type d | \
            grep 'default$' | \
            head -1 \
    )/bookmarkbackups

    if [ -z "$bookmarkdir" ]; then
        echo "Error while finding firefox directory."
    fi

    bookmarkfile=$(
    find "$bookmarkdir" -maxdepth 1 -type f ! -path [] | \
            sort -r | \
            head -1 | \
            xargs basename
    )

    bookmarkbackupdir="$backupdir$HOME/.mozilla/firefox"
    if [ ! -d "$bookmarkbackupdir" ]; then
        mkdir -p "$bookmarkbackupdir"
    fi

    bookmarkbackupfile=bookmarks.${bookmarkfile#*.}
    if cp -f "$bookmarkdir/$bookmarkfile" "$bookmarkbackupdir/$bookmarkbackupfile"; then
        echo "The file '$bookmarkbackupdir/$bookmarkbackupfile' was successfully created."
    else
        echo "Error while creating the file '$bookmarkbackupdir/$bookmarkbackupfile'."
    fi
}

brhythmbox()
{
    if ! command -v rhythmboxhelper > /dev/null 2>&1; then
        echo "The command rhythmboxhelper was not found."
        exit 1
    fi

    local rhythmboxbackupdir="$backupdir$HOME/.local/share/rhythmbox"
    local rhythmboxbackupfile="$rhythmboxbackupdir/rhythmdb.xml"

    if [ ! -d "$rhythmboxbackupdir" ]; then
        mkdir -p "$rhythmboxbackupdir"
    fi

    if rhythmboxhelper -x > "$rhythmboxbackupfile"; then
        echo "The file '$rhythmboxbackupfile' was sucessfully created."
    else
        echo "Error while creating the file '$rhythmboxbackupfile'."
    fi
}

bthunderbird()
{
    if ! command -v thunderbirdhelper > /dev/null 2>&1; then
        echo "The command thunderbirdhelper was not found."
        exit 1
    fi

    local feedbackupdir="$backupdir$HOME/.thunderbird"
    local feedbackupfile="$feedbackupdir/feeds.opml"

    if [ ! -d "$feedbackupdir" ]; then
        mkdir -p "$feedbackupdir"
    fi

    if thunderbirdhelper -o > "$feedbackupfile"; then
        echo "The file '$feedbackupfile' was sucessfully created."
    else
        echo "Error while creating the file '$feedbackupfile'."
    fi
}

bclean()
{
    printf "Removing diplicates from configfile '%s' ... " "$1"
    sort -u "$1" | sponge "$1"
    printf "done.\\n"
}

check_file()
{
    if [ ! -f "$1" ]; then
        if touch "$1"; then
            "The file '$1' was not found and therefore created."
        fi
    fi
}

check_dir()
{
    if [ ! -d "$1" ]; then
        if mkdir -p "$1"; then
            echo "The directory '$1' was not found and therefore created."
        fi
    fi
}

if [ $# == 0 ]; then
    usage
fi

check_file "$backupconfig"
check_file "$dotfileconfig"

check_dir "$backupdir"
check_dir "$dotfiledir"

while getopts "lbfrtcd" opt; do
    case $opt in
        l)
            blist "BACKUP:" "$backupconfig"
            blist "DOTFILE:" "$dotfileconfig"
        ;;
        b)
            bfiles "$backupdir" "$backupconfig"
            bfiles "$dotfiledir" "$dotfileconfig" "true"
        ;;
        f)
            bfirefox
        ;;
        r)
            brhythmbox
        ;;
        t)
            bthunderbird
        ;;
        c)
            bclean "$backupconfig"
            bclean "$dotfileconfig"
        ;;
        d)
            bdiff "BACKUP:" "$backupdir" "$backupconfig"
            bdiff "DOTFILE:" "$dotfiledir" "$dotfileconfig" "true"
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
