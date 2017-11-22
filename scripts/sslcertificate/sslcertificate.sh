#!/bin/bash

COUNTRY=DE
STATE=Berlin
LOCATION=Berlin
ORGANIZATION=
UNIT=
STRENGTH=4096
DAYS=365

failure()
{
    echo $1
    exit 1
}

matches_regex()
{
    if ! [[ $2 =~ $1 ]] ; then
        echo $3
        exit 1
    fi
}

is_valid_number()
{
    matches_regex '^[0-9]+$' "$1" "$2"
}

is_valid_domain()
{
    matches_regex '^([a-z0-9-]+\.){2,}[a-z]{2,}$' $1 'The given domain value is not valid!'
}

usage()
{
    echo "create self signed ssl certificates"
    echo
    echo "Usage: $0 [OPTIONS] DOMAIN"
    echo
    printf "%-22s %18s %s\n" "Options:" "" "Defaults:"
    printf "  %-20s %-20s %s\n" "-c" "country" "$COUNTRY"
    printf "  %-20s %-20s %s\n" "-s" "state" "$STATE"
    printf "  %-20s %-20s %s\n" "-l" "location" "$LOCATION"
    printf "  %-20s %-20s %s\n" "-o" "organization" "DOMAIN"
    printf "  %-20s %-20s %s\n" "-u" "unit" "DOMAIN"
    printf "  %-20s %-20s %s\n" "-p" "strength" "$STRENGTH"
    printf "  %-20s %-20s %s\n" "-d" "days" "$DAYS"
    exit 1
}

view()
{
    openssl x509 -in $1 -noout -text
}

start()
{
    is_valid_domain $DOMAIN
    is_valid_number $STRENGTH "The given strength value is not valid!"
    is_valid_number $DAYS "The given days value is not valid!"

    PASSWORD=
    while [ -z $PASSWORD ]; do
        read -sp "Password: " PASSWORD
        echo
    done

    if [ -z $ORGANIZATION ]; then
        ORGANIZATION=$DOMAIN
    fi

    if [ -z $UNIT ]; then
        UNIT=$DOMAIN
    fi

    openssl genrsa -des3 -out $DOMAIN.key.secure -passout pass:$PASSWORD $STRENGTH > /dev/null 2>&1 && echo "Secure privat key generation successful." || failure "Secure privat key generation failed."
    openssl rsa -in $DOMAIN.key.secure -out $DOMAIN.key -passin pass:$PASSWORD > /dev/null 2>&1 && echo "Insecure privat key generation successful." || failure "Insecure privat key generation failed."
    openssl req -new -key $DOMAIN.key -out $DOMAIN.csr -subj "/C=$COUNTRY/ST=$STATE/L=$LOCATION/O=$ORGANIZATION/OU=$UNIT/CN=$DOMAIN" > /dev/null 2>&1 && echo "Certificate singing request successful." || failure "Certificate singing request failed."
    openssl x509 -req -days $DAYS -in $DOMAIN.csr -signkey $DOMAIN.key -out $DOMAIN.crt > /dev/null 2>&1 && echo "Self-signed Certificate generation successful." || failure "Self-signed Certificate failed."

    chmod 400 $DOMAIN*
}

while getopts ":c:s:l:o:u:p:d:" OPT; do
    case $OPT in
    c)
        COUNTRY=$OPTARG
        ;;
    s)
        STATE=$OPTARG
        ;;
    l)
        LOCATION=$OPTARG
        ;;
    o)
        ORGANIZATION=$OPTARG
        ;;
    u)
        UNIT=$OPTARG
        ;;
    p)
        STRENGTH=$OPTARG
        ;;
    d)
        DAYS=$OPTARG
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

DOMAIN=$@

if [ -z $DOMAIN ]; then
    usage
fi

start

exit 0
