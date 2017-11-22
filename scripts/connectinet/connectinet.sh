#!/bin/bash

configfile=/etc/wpa_supplicant/wpa_supplicant.conf
interface=""

usage()
{
    echo "connect to internet"
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-20s %s\n" "-c [interface]" "connect"
    printf "  %-20s %s\n" "-d" "disconnect"
    exit 1
}

exists_interface()
{
    local found=0
    for iface in `networkctl | awk '{ print $2 }' | grep -v 'LINK' | grep -v 'links' | grep -v '^$'`; do
        if [ ${iface} == $interface ]; then
            found=1
            break
        fi
    done

    if [ $found -eq 0 ]; then
        echo "The given network interface '$interface' doesn't exist."
        exit 1
    fi
}

connect()
{
    exists_interface
    nmcli networking off
    sudo killall wpa_supplicant
    sudo killall dhclient
    sudo wpa_supplicant -B -D wext -i $interface -c $configfile
    sudo dhclient $interface
}

disconnect()
{
    sudo killall wpa_supplicant
    sudo killall dhclient
    nmcli networking on
}

if [ $# == 0 ]; then
    usage
fi

while getopts ":c:d" opt; do
    case $opt in
        c)
            interface=$OPTARG
            connect
        ;;
        d)
            disconnect
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
