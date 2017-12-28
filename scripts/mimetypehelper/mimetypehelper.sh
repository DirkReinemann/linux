#!/bin/bash

excludes=( .git target )
desktoppath="/usr/share/applications"

usage()
{
    echo "helps to manage mime types"
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-20s %s\\n" "-s [PATH]" "scan recursive for mimetypes in the given path"
    printf "  %-20s %s\\n" "-m [MIME]" "view default application for mimetype"
    printf "  %-20s %s\\n" "-f [FILENAME]" "view mimetype for the given filename"
    printf "  %-20s %s\\n" "-a [NAME]" "find application desktop file"
    printf "  %-20s %s\\n" "-c" "change mimetype"
    exit 1
}

isexcluded()
{
    local ret=0
    local exclude
    for exclude in "${excludes[@]}"; do
        if [[ $1 =~ $exclude ]]; then
            ret=1
            break;
        fi
    done
    echo $ret
}

scan()
{
    if [ ! -d "$1" ]; then
        echo "The given path '$1' doesn't exist!"
        exit 1
    fi

    local check
    local fpath
    find "$1" -type f | while read -r fpath; do
        check=$(isexcluded "$fpath")
        if [ "$check" -eq "0" ]; then
            fbase=$(basename "$fpath")
            fextn=${fbase##*.}
            fmime=$(xdg-mime query filetype "$fpath")
            fdflt=$(xdg-mime query default "$fmime")
            printf "%-15s %-85s %s\\n" "$fextn" "$fmime" "$fdflt"
        fi
    done | sort -u -k 1
}

change()
{
    local mime
    local name
    local rslt

    read -rp "Mimetype: " mime
    read -rp "Desktopfilename: " name

    if xdg-mime default "$name" "$mime"; then
        rslt=$(xdg-mime query default "$mime")
        if [ "$rslt" == "$name" ]; then
            echo "The mimetype for '$mime' was changed to '$name'."
        else
            echo "Error while changing the mimetype."
            exit 1
        fi
    else
        echo "Error while changing the mimetype."
        exit 1
    fi
}

findapp()
{
    local fbase
    local fpath
    find $desktoppath -iname "*$1*" | while read -r fpath; do
        fbase=$(basename "$fpath")
        printf "%s\\n" "$fbase"
    done
}

defaultapp()
{
    xdg-mime query default "$1"
}

mimetype()
{
    xdg-mime query filetype "$1"
}

if [ $# == 0 ]; then
    usage
fi

while getopts "a:s:f:m:c" opt; do
    case $opt in
    s)
        scan "$OPTARG"
        ;;
    a)
        findapp "$OPTARG"
        ;;
    m)
        defaultapp "$OPTARG"
        ;;
    f)
        mimetype "$OPTARG"
        ;;
    c)
        change
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
