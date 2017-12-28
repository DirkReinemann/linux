#!/bin/bash

filename=$( \
    find "$HOME/.thunderbird" -maxdepth 1 -type d | \
    grep "default$" \
)/Mail/Feeds/feeds.rdf

usage()
{
    echo "Thunderbird helper script."
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-15s %s\\n" "-l" "prints feed list"
    printf "  %-15s %s\\n" "-o" "prints feed opml"
    exit 1
}

plist()
{
    xmlstarlet sel -t -m '/RDF:RDF/fz:feed' \
        -v '@dc:title' -o '|' \
        -v '@dc:identifier' -n "$filename" | \
        awk -F'|' '{ printf "%3i. %-30s %s\n", NR, $1, $2 }'
}

popmltemplate()
{
    local dstring

    dstring="$(date '+%a, %d %b %H:%M:%S %Z')"
    echo "
<opml version=\"1.0\" xmlns:fz=\"urn:forumzilla:\">
  <head>
    <title>Thunderbird OPML Export - feeds</title>
    <dateCreated>$dstring</dateCreated>
  </head>
  <body>
  </body>
</opml>
    "
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

popml()
{
    local feed feeds paths saveifs path item select output count

    paths=$( \
        xmlstarlet sel -t -m "/RDF:RDF/fz:feed/fz:destFolder" \
        -v "@RDF:resource" -n $filename \
    )

    feeds=$( \
        xmlstarlet sel -t -m "/RDF:RDF/fz:feed" \
        -v "@dc:title" -o "|" \
        -v "@dc:identifier" -o "|" \
        -v "@NS1:link" -o "|" \
        -v "@fz:options" -o "|" \
        -v "@fz:quickMode" -o "|" \
        -n $filename \
    )

    output="$(popmltemplate)"

    saveifs=$IFS
    IFS=$(echo -en "\\n\\b")
    for path in $paths; do
        path="${path#*@}"
        path="${path#*/}"

        select="/opml/body"
        while : ; do
            item="${path%%/*}"
            count="$(
                echo "$output" | \
                    xmlstarlet sel -t -v "count($select/outline[@title='$item'])" \
            )"
            if [ "$count" -eq "0" ]; then
                output="$( \
                    echo "$output" | \
                    xmlstarlet ed \
                    -s "$select" -t 'elem' -n 'outline' -v '' \
                    -i "$select/outline[not(@title)]" -t 'attr' -n 'title' -v "$item" \
                )"
            fi

            if [ -z "$item" ] || [ "$item" == "$path" ]; then
                break;
            fi

            select="$select/outline[@title='$item']"
            path="${path#*/}"
        done
    done

    local title quickmode options xmlurl htmlurl
    for feed in $feeds; do
        title=$(phead "$feed")
        feed=$(ptail "$feed")

        xmlurl=$(phead "$feed")
        feed=$(ptail "$feed")

        htmlurl=$(phead "$feed")
        feed=$(ptail "$feed")

        options=$(phead "$feed")
        feed=$(ptail "$feed")

        quickmode=$(phead "$feed")
        feed=$(ptail "$feed")

        count="$( \
           echo "$output" | \
           xmlstarlet sel -t -v "count(//outline[@title='$title'])" \
        )"

        if [ "$count" -eq "1" ]; then
            output=$(
            echo "$output" | \
                xmlstarlet ed \
                -i "//outline[@title='$title']" -t 'attr' -n 'type' -v "rss" \
                -i "//outline[@title='$title']" -t 'attr' -n 'text' -v "$title" \
                -i "//outline[@title='$title']" -t 'attr' -n 'version' -v "RSS" \
                -i "//outline[@title='$title']" -t 'attr' -n 'fz:quickMode' -v "$quickmode" \
                -i "//outline[@title='$title']" -t 'attr' -n 'fz:options' -v "$options" \
                -i "//outline[@title='$title']" -t 'attr' -n 'xmlUrl' -v "$xmlurl" \
                -i "//outline[@title='$title']" -t 'attr' -n 'htmlUrl' -v "$htmlurl" \
            )
        fi
    done

    IFS=$saveifs

    echo "$output"
}

if [ $# == 0 ]; then
    usage
fi

if [ ! -f "$filename" ]; then
    echo "The thunderbird feeds file '$filename' was not found."
    exit 1
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
