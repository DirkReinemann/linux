#!/bin/bash

usage()
{
    echo "Autostart script."
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-20s %s\n" "-d" "disable sleep"
    printf "  %-20s %s\n" "-x" "disable camera and touchpad"
    printf "  %-20s %s\n" "-s" "update screenlayout scripts"
    exit 1
}

dpmsconfig()
{
    sleep 1 && xset s off
    sleep 1 && xset s 0 0
    sleep 1 && xset -dpms
}

getxinputid()
{
    xinput | grep $1 | grep -o 'id=[0-9]*' | grep -o '[0-9]*'
}


xinputconfig()
{
    xinput disable $(getxinputid "Camera")
    xinput disable $(getxinputid "TouchPad")
}

screenlayoutconfig()
{
    local vga=$(xrandr | grep -o VGA[0-9])
    local lvds=$(xrandr | grep -o LVDS[0-9])

    layoutdir="$HOME/.screenlayout"
    layoutfiles=( Dual.sh Single.sh )

    for layout in ${layoutfiles[@]}; do
        layoutfile="$layoutdir/$layout"

        if [ ! -f $layoutfile ]; then
            echo "The layoutfile '$layoutfile' doesn't exist."
        else
            if [ ! -z $vga ]; then
                sed -i "s/VGA[0-9]/$vga/" "$layoutfile"
            fi

            if [ ! -z $LVDS ]; then
                sed -i "s/LVDS[0-9]/$LVDS/" "$layoutfile"
            fi

        fi
    done
}

if [ $# == 0 ]; then
    usage
fi

while getopts "lb" opt; do
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
