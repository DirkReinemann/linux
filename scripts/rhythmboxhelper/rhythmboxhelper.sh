#!/bin/bash

filename="$HOME/.local/share/rhythmbox/rhythmdb.xml"

usage()
{
    echo "Rhythmbox helper script."
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-15s %s\n" "-l" "prints radio station list"
    printf "  %-15s %s\n" "-x" "prints radio station xml"
    printf "  %-15s %s\n" "-i [filename]" "inserts radio station xml in database and prints output"
    printf "\n\n"
    echo "Howto backup and restore rhythmbox radio stations:"
    echo
    echo "1. Print radio stations as xml and redirect the output to a file."
    echo
    echo "  $0 -x > backup.xml"
    echo
    echo "2. Insert the radio stations from xml file to rhythmdb file, redirect the output"
    echo "   to a temp file and override the rhythmdb file by moving the temp file."
    echo
    echo "  $0 -i backup.xml > restore.xml && mv restore.xml $filename"
    echo
    exit 1
}

plist()
{
    xmlstarlet sel -t -m '//entry[@type="iradio"]' \
    -v 'title' -o '|' \
    -v 'location' \
    -n $filename | \
    awk -F'|' '{ printf "%2i. %-50s %s\n", NR, $1, $2 }'
}

pxml()
{
    xmlstarlet ed -d '/rhythmdb/entry[not(@type="iradio")]' \
    -u '/rhythmdb/entry/play-count' -v '' \
    -u '/rhythmdb/entry/last-played' -v '' \
    -u '/rhythmdb/entry/bitrate' -v '' \
    -u '/rhythmdb/entry/date' -v '' \
    -u '/rhythmdb/entry/artist' -v '' \
    -u '/rhythmdb/entry/album' -v '' \
    $filename
}

phead()
{
    local value=$1
    echo "${value%%|*}"
}

ptail()
{
    local value=$1
    echo "${value#*|}"
}

pinsert()
{
    local infile=$1
    if [ ! -f $infile ]; then
        printf "The given file '$infile' doesn't exist.\n"
        exit 1
    fi

    local entries=$(xmlstarlet sel -t -m '//entry[@type="iradio"]' \
        -v 'title' -o '|' \
        -v 'location' -o '|' \
        -v 'genre' -o '|' \
    -v 'media-type' -n $infile)
    
    local output=$(cat $filename)
    local entry title location genre mediatype
    local saveifs=$IFS
    IFS=$(echo -en "\n\b")
    for entry in $entries; do
        title=$(phead "$entry")
        entry=$(ptail "$entry")

        location=$(phead "$entry")
        entry=$(ptail "$entry")

        genre=$(phead "$entry")
        entry=$(ptail "$entry")

        mediatype=$(phead "$entry")
        entry=$(ptail "$entry")

        output="$(echo $output | xmlstarlet ed \
            -s '/rhythmdb' -t 'elem' -n 'entry' -v '' \
            -s '/rhythmdb/entry[not(@type)]' -t 'elem' -n 'title' -v "$title" \
            -s '/rhythmdb/entry[not(@type)]' -t 'elem' -n 'genre' -v "$genre" \
            -s '/rhythmdb/entry[not(@type)]' -t 'elem' -n 'artist' -v '' \
            -s '/rhythmdb/entry[not(@type)]' -t 'elem' -n 'album' -v '' \
            -s '/rhythmdb/entry[not(@type)]' -t 'elem' -n 'location' -v "$location" \
            -s '/rhythmdb/entry[not(@type)]' -t 'elem' -n 'play-count' -v '' \
            -s '/rhythmdb/entry[not(@type)]' -t 'elem' -n 'last-played' -v '' \
            -s '/rhythmdb/entry[not(@type)]' -t 'elem' -n 'bitrate' -v '' \
            -s '/rhythmdb/entry[not(@type)]' -t 'elem' -n 'date' -v '' \
            -s '/rhythmdb/entry[not(@type)]' -t 'elem' -n 'media-type' -v "$mediatype" \
        -i '/rhythmdb/entry[not(@type)]' -t 'attr' -n 'type' -v 'iradio')"
    done
    IFS=$saveifs

    echo "$output"
}

if [ $# == 0 ]; then
    usage
fi

while getopts "lxi:" opt; do
    case $opt in
        l)
            plist
        ;;
        x)
            pxml
        ;;
        i)
            pinsert $OPTARG
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
