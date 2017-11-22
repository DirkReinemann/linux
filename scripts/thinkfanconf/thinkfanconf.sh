#!/bin/bash

conffile=/etc/thinkfan.conf
tempfile=$(find /sys/devices/virtual/hwmon -name temp1_input | head -1)


if [ -f $tempfile ]; then
    sudo sed -i "s;^hwmon.*;hwmon $tempfile;" $conffile
fi

sudo systemctl restart thinkfan

exit 0
