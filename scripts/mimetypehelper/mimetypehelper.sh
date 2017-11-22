#!/bin/bash

EXCLUDES=( .git target )
DESKTOPPATH="/usr/share/applications"

usage()
{
    echo "helps to manage mime types"
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-20s %s\n" "-s [PATH]" "scan recursive for mimetypes in the given path"
    printf "  %-20s %s\n" "-c" "change mimetype"
    printf "  %-20s %s\n" "-v [MIME]" "view default application for mimetype"
    printf "  %-20s %s\n" "-f [NAME]" "find application desktop file"
    exit 1
}

exclude()
{
    RET=0
    for EXCLUDE in "${EXCLUDES[@]}"; do
        if [[ $1 =~ $EXCLUDE ]]; then
            RET=1
            break;
        fi
    done
    echo $RET
}

scan()
{
    if [ ! -d $1 ]; then
        echo "The given path '$1' doesn't exist!"
        exit 1
    fi

    find $1 -type f | while read FPATH; do
        CHECK=$(exclude "$FPATH")
        if [ $CHECK -eq 0 ]; then
            FBASE=$(basename "$FPATH")
            FEXTN=${FBASE##*.}
            FMIME=$(xdg-mime query filetype "$FPATH")
            FDFLT=$(xdg-mime query default "$FMIME")
            printf "%-30s %-30s %s\n" "$FEXTN" "$FMIME" "$FDFLT"
        fi
    done | sort -u -k 1
}

change()
{
    read -p "Mimetype: " MIME
    read -p "Desktopfilename: " NAME

    xdg-mime default $NAME $MIME
    if [ $? -eq 0 ]; then
        RSLT=$(xdg-mime query default $MIME)
        if [ "$RSLT" == "$NAME" ]; then
            echo "The mimetype for '$MIME' was changed to '$NAME'."
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
    find $DESKTOPPATH -iname "*$1*" | while read FPATH; do
        FBASE=$(basename "$FPATH")
        printf "%s\n" "$FBASE"
    done
}

show()
{
    xdg-mime query default $1
}

if [ $# == 0 ]; then
    usage
fi

while getopts "s:f:cv" OPT; do
    case $OPT in
    s)
        scan $OPTARG
        ;;
    f)
        findapp $OPTARG
        ;;
    v)
        show $OPTARG
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
