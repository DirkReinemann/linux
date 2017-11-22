#!/bin/bash

HTTPPROXYURL="https://premproxy.com/list/"
SOCKSPROXYURL="https://premproxy.com/socks-list/"
PROXYCHAINSCONF="/etc/proxychains.conf"

usage()
{
    echo "script short description"
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-20s %s\n" "-l" "list proxies"
    printf "  %-20s %s\n" "-u" "update proxychain proxies"
    exit 1
}

listproxiespremproxy()
{
    I=100
    if [ ! -z $1 ]; then
        I=$1
    fi

    curl -s $SOCKSPROXYURL | grep -Eo '[0-9]{2}.htm' | sort -u | while read PAGE; do
        curl -s $SOCKSPROXYURL/$PAGE | hxnormalize -x | hxselect 'tr' | sed '/^\s*$/d' | sed -e 's/^[ \t]*//' | hxselect -s '\n\n' 'tr' | sed 's,<td>,,' | sed 's,</td>,,' | awk -vRS='\n\n' -vFS='\n' 'NR>1 { printf "%s;%s;%s\n", $2, $3, $5 }' | grep '^[0-9]' | while read -r PROXY ; do
            IFS=";" read -a DATA <<<"$PROXY"
            IP=${DATA[0]%:*}
            PORT=${DATA[0]#*:}
            TYPE=${DATA[1]}
            COUNTRY=${DATA[2]}
            TIME=$(ping -c1 -w1 $IP | grep -o "time=.*" | grep -o "[0-9.]*")
            if [ ! -z $TIME ]; then
                printf "%-10s %-20s %-10s %-10s %s\n" "$TIME" "$IP" "$PORT" "$TYPE" "$COUNTRY"
                I=$((I-1))
            fi

            if [ $I -le 0 ]; then
                exit $I
            fi
        done

        if [ $? -eq 0 ]; then
            exit 0
        else
            I=$?
        fi
    done
}

listproxiessocksproxy()
{
    I=100
    if [ ! -z $1 ]; then
        I=$1
    fi

    curl -s https://www.socks-proxy.net/ | hxnormalize -x | hxselect 'tr' | sed '/^\s*$/d' | sed -e 's/^[ \t]*//' | hxselect -s '\n\n' 'tr' | sed 's,<td[ a-z"=]*>,,' | sed 's,</td>,,' | awk -vRS='\n\n' -vFS='\n' 'NR>1 { printf "%s;%s;%s;%s\n", $2, $3, $6, $5 }' | grep '^[0-9]' | sort -t ';' -k 4 | while read PROXY; do
        IFS=";" read -a DATA <<<"$PROXY"
        IP=${DATA[0]}
        PORT=${DATA[1]}
        TYPE=${DATA[2]}
        COUNTRY=${DATA[3]}
        TIME=$(ping -c1 -w1 $IP | grep -o "time=.*" | grep -o "[0-9.]*")
        if [ ! -z $TIME ]; then
            printf "%-10s %-20s %-10s %-10s %s\n" "$TIME" "$IP" "$PORT" "$TYPE" "$COUNTRY"
            I=$((I-1))
        fi

        if [ $I -le 0 ]; then
            exit $I
        fi
    done
}

updateproxychain()
{
    sudo sed -i '/\[ProxyList\]/,$d' /etc/proxychains.conf
    echo "[ProxyList]" | sudo tee -a $PROXYCHAINSCONF
    listproxiessocksproxy 10 | awk '{ printf "%-10s %-20s %-10s\n", tolower($4), $2, $3 }' | sudo tee -a $PROXYCHAINSCONF
}

if [ $# == 0 ]; then
    usage
fi

while getopts "lu" OPT; do
    case $OPT in
    l)
        listproxiessocksproxy
        ;;
    u)
        updateproxychain
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
