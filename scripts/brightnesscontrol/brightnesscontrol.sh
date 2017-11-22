#!/bin/bash

CUR=$(cat /sys/class/backlight/intel_backlight/brightness)
MAX=$(cat /sys/class/backlight/intel_backlight/max_brightness)
TEN=$(awk -v MAX="$MAX" 'BEGIN { printf "%2.0f\n", (MAX/100)*10 }')

usage()
{
    echo "Brightness utility for thinkpad."
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-20s %s\n" "-s" "gives the actual brightness in percent"
    printf "  %-20s %s\n" "-i" "increases the brightness by 10 percent"
    printf "  %-20s %s\n" "-d" "decreases the brightness by 10 percent"
    exit 1
}

state()
{
    awk -v cur="$cur" -v max="$max" 'BEGIN { printf "%2.0f\n", (cur/max)*100 }'
}

change()
{
    echo "$1" | sudo tee -a /sys/class/backlight/intel_backlight/brightness > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error while changing brightness!"
        exit 1
    fi
}

increase()
{
    local new=$(awk -v cur="$cur" -v max="$max" 'BEGIN { printf "%2.0f\n", cur+((max/100)*10) }')
    if [ $new -ge $max ]; then
        change "$max"
    else
        change "$new"
    fi
}

decrease()
{
    local new=$(awk -v cur="$cur" -v max="$max" 'BEGIN { printf "%2.0f\n", cur-((max/100)*10) }')
    if [ $new -le 0 ]; then
        change "0"
    else
        change $new
    fi
}

if [ $# == 0 ]; then
    usage
fi

while getopts "sid" opt; do
    case $opt in
        s)
            state
        ;;
        i)
            increase
        ;;
        d)
            decrease
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
