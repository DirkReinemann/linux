#!/bin/bash

MOZILLA_PLUGINS_DIRECTORY="/usr/lib/mozilla/plugins"

JDK_LINK="$(ls -1 "$MOZILLA_PLUGINS_DIRECTORY" | grep "jdk" | head)"

if [ ! -z "$JDK_LINK" ]; then
    sudo unlink "$MOZILLA_PLUGINS_DIRECTORY/$JDK_LINK" && \
        printf "The link '%s/%s' was successfully removed.\n" "$MOZILLA_PLUGINS_DIRECTORY" "$JDK_LINK"
fi

exit 1
