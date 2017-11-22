#!/bin/bash

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
    VGA=$(xrandr | grep -o VGA[0-9])
    LVDS=$(xrandr | grep -o LVDS[0-9])

    LAYOUTDIR="$HOME/.screenlayout"
    LAYOUTFILES=( Dual.sh Single.sh )

    for L in ${LAYOUTFILES[@]}; do
        LAYOUTFILE="$LAYOUTDIR/$L"

        if [ ! -f $LAYOUTFILE ]; then
            printf "The layoutfile '$LAYOUTFILE' doesn't exist!\n"
        else
            if [ ! -z $VGA ]; then
                sed -i "s/VGA[0-9]/$VGA/" "$LAYOUTDIR/$L"
            fi

            if [ ! -z $LVDS ]; then
                sed -i "s/LVDS[0-9]/$LVDS/" "$LAYOUTDIR/$L"
            fi

        fi
    done
}

dpmsconfig
xinputconfig
screenlayoutconfig

exit 0
