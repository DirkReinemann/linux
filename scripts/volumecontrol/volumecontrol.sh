#!/bin/bash

max=150
cur=$(pactl list sinks | grep Volume | head -1 | awk '{ print $5 }')
cur=${cur%\%}

usage()
{
    echo "volume utility for pulseaudio"
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-20s %s\n" "-s" "gives the actual volume in percent"
    printf "  %-20s %s\n" "-i" "increases the volume by 10 percent"
    printf "  %-20s %s\n" "-d" "decreases the volume by 10 percent"
    printf "  %-20s %s\n" "-m" "mute/unmute volume"
    exit 1
}

state()
{
    mut=$(pactl list sinks | grep Mute | awk '{ print $2 }')
    if [ "$mut" == "yes" ]; then
        mut="MUTE"
    else
        mut="UNMUTE"
    fi
    printf "%s\t%s\n" "$cur%" "$mut"
}

change()
{
    pactl -- set-sink-volume 0 $1% > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error while changing the volume!"
        exit 1
    fi
}

increase()
{
    new=$(($cur+10))
    if [ $new -ge $max ]; then
        change "$max"
    else
        change "$new"
    fi
}

decrease()
{
    new=$(($cur-10))
    if [ $new -le 0 ]; then
        change "0"
    else
        change $new
    fi
}

mute()
{
    pactl -- set-sink-mute 0 toggle > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error while muting the volume!"
        exit 1
    fi
}

if [ $# == 0 ]; then
    usage
fi

while getopts "sidm" opt; do
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
        m)
            mute
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
