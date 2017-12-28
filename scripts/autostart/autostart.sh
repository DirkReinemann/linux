#!/bin/bash

usage()
{
    echo "autostart script."
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-20s %s\\n" "-d" "disable sleep"
    printf "  %-20s %s\\n" "-x" "disable camera and touchpad"
    printf "  %-20s %s\\n" "-s" "update screenlayout scripts"
    exit 1
}

dpmsconfig()
{
    sleep 1 && xset s off
    sleep 1 && xset s 0 0
    sleep 1 && xset -dpms
}

disablexinput()
{
    local id
    id=$(xinput | grep "$1" | grep -o 'id=[0-9]*' | grep -o '[0-9]*')
    if [ ! -z "$id" ]; then
        xinput disable "$id"
    fi
}

xinputconfig()
{
    disablexinput "Camera"
    disablexinput "TouchPad"
}

screenlayoutconfig()
{
    local vga
    local lvds
    local layoutfile

    vga=$(xrandr | grep -o 'VGA[0-9]')
    lvds=$(xrandr | grep -o 'LVDS[0-9]')

    layoutdir="$HOME/.screenlayout"

    for layoutfile in $layoutdir/*.sh; do
        if [ ! -z "$vga" ]; then
            sed -i "s/VGA[0-9]/$vga/" "$layoutfile"
        fi
        if [ ! -z "$lvds" ]; then
            sed -i "s/LVDS[0-9]/$lvds/" "$layoutfile"
        fi
    done
}

if [ $# == 0 ]; then
    usage
fi

while getopts "dxs" opt; do
    case $opt in
        d)
            dpmsconfig
        ;;
        x)
            xinputconfig
        ;;
        s)
            screenlayoutconfig
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
