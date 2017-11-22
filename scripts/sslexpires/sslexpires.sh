#!/bin/bash

DOMAINS=(www.dirkreinemann.com owncloud.dirkreinemann.com blog.dirkreinemann.com wiki.dirkreinemann.com zuendstoff.dirkreinemann.com etherpad.dirkreinemann.com)

for DOMAIN in "${DOMAINS[@]}"; do
    EXPIRES=$(curl --insecure --head -v https://$DOMAIN 2>&1 | grep expire | grep -o 'date: .*')
    echo "$DOMAIN: $EXPIRES"
done

exit 0
