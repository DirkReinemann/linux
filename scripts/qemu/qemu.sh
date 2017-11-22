#!/bin/bash

# Creates a virtual machine and starts the given iso image. Redirects the ssh port 22 to the local port 10022.

# ssh <USER>@localhost -p10022

RAM=2048
ISO=
USB=

usage()
{
    echo "start virtual machine with qemu"
    echo
    echo "Usage: $0 [-r RAM] [-u USB_HOSTBUS,USB_HOSTADDRESS] ISO"
    echo
    printf "  %-20s %s\n" "-r" "ram size"
    printf "  %-20s %s\n" "-u" "usb hostbus and hostaddress"
    exit 1
}

start()
{
    if [ ! -f $ISO ]; then
        echo "The given iso file doesn't exist"
        exit 2
    fi

    COMMAND="qemu-system-x86_64 -enable-kvm -boot d -cdrom $ISO -m $RAM -net user,hostfwd=tcp::10022-:22 -net nic"

    if [ ! -z $USB ]; then
        HOSTBUS=${USB%,*}
        HOSTADD=${USB#*,}
        COMMAND="$COMMAND -usb -device usb-host,hostbus=$HOSTBUS,hostaddr=$HOSTADD"
    fi

    eval $COMMAND
}

while getopts ":r:u:" OPT; do
    case $OPT in
    r)
        RAM=$OPTARG
        ;;
    u)
        USB=$OPTARG
        ;;
    \?)
        usage
        ;;
    :)
        usage
        ;;
    esac
done

shift $(( OPTIND - 1 ))

ISO=$@

if [ -z $ISO ]; then
    usage
fi

start

exit 0
