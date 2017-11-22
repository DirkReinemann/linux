#!/bin/bash

PLAYBOOK=
HOSTNAME=vagrant

create()
{
    cp Vagrantfile.template Vagrantfile
    sed -i "s/PLAYBOOK/$PLAYBOOK/g" Vagrantfile
    sed -i "s/HOSTNAME/$HOSTNAME/g" Vagrantfile
}

usage()
{
    echo "create vagrant file for ansible playbook"
    echo
    echo "Usage: $0 [OPTIONS] PLAYBOOK"
    echo
    printf "%-22s %18s %s\n" "Options:" "" "Defaults:"
    printf "  %-20s %-18s %s\n" "-h" "hostname" "vagrant"
    exit 1
}

while getopts ":h:" OPT; do
    case $OPT in
    h)
        HOSTNAME=$OPTARG
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

PLAYBOOK=$@

if [ -z $PLAYBOOK ]; then
    usage
fi

create

exit 0