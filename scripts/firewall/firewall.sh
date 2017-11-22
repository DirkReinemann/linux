#!/bin/bash

LOG_PREFIX="iptables-dropped: "

usage()
{
    echo "Firewall script"
    echo
    echo "Usage: $0 [start] [stop] [show] [dropped]"
    echo
    printf "  %-20s %s\n" "start" "start firewall"
    printf "  %-20s %s\n" "stop" "stop firewall"
    printf "  %-20s %s\n" "stop" "show firewall"
    printf "  %-20s %s\n" "dropped" "show dropped packages"
    exit 1
}

start()
{
    # delete all rules
    sudo iptables -F

    sudo iptables -L LOGGING > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        sudo iptables -X LOGGING
    fi

    # accept conncetions for localhost
    sudo iptables -A INPUT -i lo -j ACCEPT
    sudo iptables -A OUTPUT -o lo -j ACCEPT

    # reject connections on default
    sudo iptables -P INPUT DROP
    sudo iptables -P FORWARD DROP
    sudo iptables -P OUTPUT DROP

    # accept established connections
    sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    sudo iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    # accept new connections on port
    sudo iptables -A OUTPUT -m conntrack --ctstate NEW -p udp --dport 53 -j ACCEPT #DNS
    sudo iptables -A OUTPUT -m conntrack --ctstate NEW -p udp --dport 67 -j ACCEPT #DHCP
    sudo iptables -A OUTPUT -m conntrack --ctstate NEW -p tcp --dport 22 -j ACCEPT #SSH
    sudo iptables -A OUTPUT -m conntrack --ctstate NEW -p tcp --dport 80 -j ACCEPT #HTTP
    sudo iptables -A OUTPUT -m conntrack --ctstate NEW -p tcp --dport 443 -j ACCEPT #HTTPS
    sudo iptables -A OUTPUT -m conntrack --ctstate NEW -p tcp --dport 21 -j ACCEPT #FTP
    sudo iptables -A OUTPUT -m conntrack --ctstate NEW -p tcp --dport 25 -j ACCEPT #POP3
    sudo iptables -A OUTPUT -m conntrack --ctstate NEW -p tcp --dport 995 -j ACCEPT #POP3S
    sudo iptables -A OUTPUT -m conntrack --ctstate NEW -p tcp --dport 110 -j ACCEPT #SMTP
    sudo iptables -A OUTPUT -m conntrack --ctstate NEW -p tcp --dport 465 -j ACCEPT #SMTPS
    sudo iptables -A OUTPUT -m conntrack --ctstate NEW -p tcp --dport 143 -j ACCEPT #IMAP
    sudo iptables -A OUTPUT -m conntrack --ctstate NEW -p tcp --dport 993 -j ACCEPT #IMAPS

    # enable logging
    sudo iptables -N LOGGING
    sudo iptables -A INPUT -j LOGGING
    sudo iptables -A OUTPUT -j LOGGING
    sudo iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix $LOG_PREFIX --log-level 4
    sudo iptables -A LOGGING -j DROP
}

stop()
{
    # delete all rules
    sudo iptables -F

    sudo iptables -L LOGGING > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        sudo iptables -X LOGGING
    fi

    # accpet input and output connections on default
    sudo iptables -P INPUT ACCEPT
    sudo iptables -P FORWARD ACCEPT
    sudo iptables -P OUTPUT ACCEPT
}

show()
{
    sudo iptables -L
}

dropped()
{
    cat /var/log/syslog | grep $LOG_PREFIX
}

case $1 in
    start)
        start
    ;;
    stop)
        stop
    ;;
    show)
        show
    ;;
    dropped)
        dropped
    ;;
    *)
        usage
    ;;
esac

exit 0
