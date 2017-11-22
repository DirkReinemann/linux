#!/bin/bash

DBUS_SOCKET="/run/user/$(id -u)/bus"
DBUS_ADDRESS="unix:path=$DBUS_SOCKET"

if [ -S $DBUS_SOCKET ]; then
    dbus-monitor --address "$DBUS_ADDRESS" "type='signal',member='PropertiesChanged',interface='org.freedesktop.DBus.Properties'" | awk '/PlaybackStatus/,/)/ { if (length($3) > 0) { system("pkill -SIGRTMIN+13 i3blocks"); } }'
else
    echo "The given dbus socket '$DBUS_SOCKET' was not found."
    exit 1
fi

exit 0
