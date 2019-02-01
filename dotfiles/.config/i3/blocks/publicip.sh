#!/bin/bash

IP="$(curl -s http://ipecho.net/plain || echo '0.0.0.0')"
LOCATION=""
COLOR="#FF0000"

if [ "$IP" != "0.0.0.0" ]; then
    LOCATION="$(geoiplookup "$IP" | awk -F': ' '{ print $2 }')"
    COLOR="#00FF00"
fi

echo "$IP $LOCATION"
echo "$IP $LOCATION"
echo "$COLOR"

exit 0
