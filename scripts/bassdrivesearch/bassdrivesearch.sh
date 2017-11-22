#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: bassdrivesearch [SEARCH]"
    exit 1
fi

url="http://archives.bassdrivearchive.com/"
search="$1"

for site in $(curl -s $url | hxnormalize -x | hxselect -s '\n' 'a' | sed 's/<a href="//' | sed 's/">[A-Za-z ]*<\/a>//' | head -7); do
    curl -s "$url$site" 2>&1 | grep -i "$search" > /dev/null  && echo $url$site
done

exit 0
