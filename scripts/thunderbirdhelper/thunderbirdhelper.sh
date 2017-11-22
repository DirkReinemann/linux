#!/bin/bash

filename=$(find "$HOME/.thunderbird" -maxdepth 1 -type d | grep "default$")/Mail/Feeds/feeds.rdf

usage()
{
    echo "Thunderbird helper script."
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-15s %s\n" "-l" "prints feed list"
    printf "  %-15s %s\n" "-o" "prints feed opml"
    exit 1
}

plist()
{
    xmlstarlet sel -t -m '/RDF:RDF/fz:feed' \
        -v '@dc:title' -o '|' \
        -v '@dc:identifier' -n $filename | \
        awk -F'|' '{ printf "%3i. %-30s %s\n", NR, $1, $2 }'
}

popmltemplate()
{
    local dstring="$(date '+%a, %d %b %H:%M:%S %Z')"
    echo "
<opml version="1.0" xmlns:fz="urn:forumzilla:">
  <head>
    <title>Thunderbird OPML Export - feeds</title>
    <dateCreated>$dstring</dateCreated>
  </head>
  <body>
  </body
</opml>
    "
}

popml()
{
    local feeds=$(xmlstarlet sel -t -m "/RDF:RDF/fz:feed" \
        -v "@dc:title" -o "|" \
        -v "@dc:identifier" -o "|" \
        -v "@NS1:link" -o "|" \
        -v "@fz:options" -o "|" \
        -v "@fz:quickMode" -o "|" \
        -v "fz:destFolder/@RDF:resource" -n $filename)

    local paths=$(xmlstarlet sel -t -m "/RDF:RDF/fz:feed/fz:destFolder" \
        -v "@RDF:resource" -n $filename)

    local saveifs=$IFS
    IFS=$(echo -en "\n\b")

    local maxpath=0
    local path count
    for path in $paths; do
        path="${path#*@}"
        path="${path#*/}"
        count=$(echo "$path" | grep -o '/' | wc -l)
        if [ $count -gt $maxpath ]; then
            maxpath=$count
        fi
    done
    echo $maxpath

    echo "$(popmltemplate)"

    for path in $paths; do
        path="${path#*@}"
        path="${path#*/}"
    done
    IFS=$saveifs
}

if [ $# == 0 ]; then
    usage
fi

while getopts "lo" opt; do
    case $opt in
    l)
        plist
        ;;
    o)
        popml
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
