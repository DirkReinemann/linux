#!/bin/bash

SSID="$(iwgetid | awk '{ print $2 }' | awk -F':' '{ print $2 }' | tail -c +2 | head -c -2)"
COLOR="#00FF00"

if [ -z "$SSID" ]; then
    SSID="down"
    COLOR="#FF0000"
fi

echo "$SSID"
echo "$SSID"
echo "$COLOR"
