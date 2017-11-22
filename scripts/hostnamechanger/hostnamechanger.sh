#!/bin/bash

length=16
hostname=

usage()
{
    echo "Change hostname."
    echo
    echo "Usage: $0 [Options]"
    echo
    printf "  %-20s %s\n" "-l" "hostname length (when no hostname is given and generated)"
    printf "  %-20s %s\n" "-h" "hostname to set"
    exit 1
}

start()
{
    if [ -z $hostname ]; then
        hostname=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c $length)
    fi

    sudo sed -i "s/^127\.0\.0\.1.*/127.0.0.1\tlocalhost\t$hostname/" /etc/hosts
    sudo sed -i "s/^::1.*/::1\t\tlocalhost\t$hostname/" /etc/hosts
    sudo sh -c "echo $hostname > /etc/hostname"
    sudo hostname $hostname

    echo "Changed hostname to: $hostname."
}

while getopts "l:n:h" opt; do
    case $opt in
        l)
            length=$OPTARG
        ;;
        n)
            hostname=$OPTARG
        ;;
        h)
            usage
        ;;
        \?)
            usage
        ;;
        :)
            usage
        ;;
    esac
done

start

exit 0
