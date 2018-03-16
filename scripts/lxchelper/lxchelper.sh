#!/bin/bash

KEYFILE="$HOME/.ssh/id_rsa.pub"
USERNAME="root"
PASSWORD="root"
IMAGEDIR="/usr/share/lxc/templates"
IMAGENAME="lxc-archlinux-custom"
CONTAINERNAME=""
ALL=0

usage_global()
{
    echo "helper script for lxc containers"
    echo
    echo "Usage: $0 [Command]"
    echo
    echo "Commands:"
    printf "  %-20s %s\n" "create" ""
    printf "  %-20s %s\n" "start" ""
    printf "  %-20s %s\n" "stop" ""
    printf "  %-20s %s\n" "login" ""
    printf "  %-20s %s\n" "copy" ""
    printf "  %-20s %s\n" "list" ""
    exit 1
}

exists_container()
{
    sudo lxc-ls -1 | grep '$CONTAINERNAME'
}

create_container()
{
    if [ exists_container ]; then
        printf "The container with the given name '%s' already exists.\n" "$CONTAINERNAME"
        exit 1
    fi
}

start_container()
{
    lcx-start -n "$CONTAINERNAME"
}

stop_container()
{
    if [ $ALL -eq 0 ]; then
        sudo lxc-stop -n "$CONTAINERNAME"
    else
        local container

        for container in $(sudo lxc-ls -1); do
            sudo lxc-stop -n "$container"
        done
    fi
}

login_container()
{

}

copy_container()
{

}

if [ $# == 0 ]; then
    usage
fi

while getopts "s:i" OPT; do
    case $OPT in
    s)
        start $OPTARG
        ;;
    i)
        stop $OPTARG
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
