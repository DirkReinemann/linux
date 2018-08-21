#!/bin/bash

DOMAIN="antinet.ddnss.de"

SUBDOMAINS=(
"zuendstoff"
"dav"
)

for SUBDOMAIN in "${SUBDOMAINS[@]}"; do
    FQDN="${SUBDOMAIN}.${DOMAIN}"
    EXPDATE="$( \
        curl -k -I -v "https://$FQDN" 2>&1 | \
            grep 'expire' | \
            awk -F': ' '{ print $2 }'
    )"
    EXPDATEFORMAT="$(date --date="$EXPDATE" "+%d.%m.%Y %H:%M:%S")"
    printf "%-50s %s\\n" "$FQDN" "$EXPDATEFORMAT"
done

exit 0
