#!/bin/sh

FANLEVEL=$(cat /proc/acpi/ibm/fan | grep ^level | awk '{ print $2 }')
FANSPEED=$(cat /proc/acpi/ibm/fan | grep ^speed | awk '{ print $2 }')

echo "${FANLEVEL} ${FANSPEED}"
echo "${FANLEVEL} ${FANSPEED}"
echo ""
