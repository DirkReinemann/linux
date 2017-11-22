#!/bin/bash

OUTDIR="$HOME/Pictures/Screenshots"
if [ ! -d $OUTDIR ]; then
    mkdir -p $OUTDIR
fi

OUTFIL="$OUTDIR/$(date '+%Y-%m-%d-%H-%M-%S-%N').png"
import -window root -display :0 -screen $OUTFIL

MESSAGE=""

if [ $? -eq 0 ]; then
    MESSAGE="Screenshot saved under '$OUTFIL'."
else
    MESSAGE="Error while taking screenshot." 
fi

echo $MESSAGE

command -v notify-send > /dev/null 2>&1
if [ $? -eq 0 ]; then
    notify-send "Screenshot" "$MESSAGE"
fi

exit 0
