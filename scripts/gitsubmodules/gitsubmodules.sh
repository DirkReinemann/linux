#!/bin/bash

workdir="$(pwd)"

oldifs="$IFS"
IFS="$(echo -en "\\n\\b")"
for dir in $(find "$workdir" -type d -name ".git"); do
        if [ "$dir" != "$workdir/.git" ]; then
        cd "$dir" || continue
        url="$(git remote show origin | grep -i "fetch" | grep -o "http[s]*://.*")"
        rel=${dir#$workdir/}
        rel=${rel%/.git}
        printf "[submodule \"%s\"]\\n" "$rel"
        printf "    path = %s\\n" "$rel"
        printf "    url = %s\\n" "$url"
        printf "    ignore = dirty\\n"
    fi
done
IFS="$oldifs"

exit 0
