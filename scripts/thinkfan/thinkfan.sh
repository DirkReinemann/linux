9#!/bin/bash

fanfile=/proc/acpi/ibm/fan

usage()
{
    echo "control fan on thinkpad"
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-20s %s\n" "-s" "show fan speed and level"
    printf "  %-20s %s\n" "-l [1-7|auto]" "set fan level to given value"
    exit 1
}

level()
{
    local value=$1
    if [[ $value =~ ([1-7]|auto) ]]; then
        sudo bash -c "echo 'level $value' > /proc/acpi/ibm/fan"
        echo "Changed fan level sucessfully to '$value'."
    else
        echo "Error while changing the fan level. The given value must be between 1 and 7 or auto."
        exit 2
    fi
}

show()
{
    local speed=$(grep ^speed $fanfile | awk '{ print $2 }')
    local level=$(grep ^level $fanfile | awk '{ print $2 }')
    printf "%-10s %-10s\n" "Speed:" "$speed"
    printf "%-10s %-10s\n" "Level:" "$level"
}

if [ $# == 0 ]; then
    usage
fi

while getopts ":l:s" opt; do
    case $opt in
        l)
            level $OPTARG
        ;;
        s)
            show
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
