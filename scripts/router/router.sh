#!/bin/bash

# Starts an access point on the given wireless lan interface and shares the connection of the wlan
# To change the interfaces you also have to edit /etc/hostapd/hostapd.conf and /etc/dnsmasq.conf.
# To change the ip address range of the dns server you have to edit /etc/dnsmasq.conf.
# To add a mac address you have to edit /etc/hostapd/hostapd.accepted.

HOSTAPD_CONFIG=/etc/hostapd/hostapd.conf
DNSMASQ_CONFIG=/etc/dnsmasq.conf
WPA_SUPPLICANT_CONFIG=/etc/wpa_supplicant/wpa_supplicant.conf
LOG_DIR=/var/log/router

usage()
{
    echo "router script"
    echo
    echo " usage: $0 [start] [stop] [clients] [configuration] [change]"
    echo
    printf " %-20s %s\n" "start" "start router"
    printf " %-20s %s\n" "stop" "stop router"
    printf " %-20s %s\n" "clients" "show connected clients"
    exit 1
}

exists_interface()
{
    local FOUND=0
    for IFACE in `netstat -i | awk '{ print $1 }' | grep -v Kernel | grep -v Iface`; do
        if [ $IFACE == $1 ]; then
           local FOUND=1
           break
        fi
    done

    if [ $FOUND -eq 0 ]; then
        echo "The given network interface '$1' doesn't exist."
        exit 1
    fi
}

start()
{
    echo -n "Type the internet interface and press Enter: "
    read INET_IFACE
    exists_interface $INET_IFACE

    echo -n "Type the accesspoint interface and press Enter: "
    read AP_IFACE
    exists_interface $AP_IFACE

    # change hostapd configuration file
    sudo sed -i "s/^interface=[a-z0-9]*/interface=$AP_IFACE/" $HOSTAPD_CONFIG
    sudo sed -i "s/^rsn_preauth_interfaces=[a-z0-9]*/rsn_preauth_interfaces=$AP_IFACE/" $HOSTAPD_CONFIG

    # change dnsmasq configuration file
    sudo sed -i "s/^interface=[a-z0-9]*/interface=$AP_IFACE/" $DNSMASQ_CONFIG
    sudo sed -i "s/^no-dhcp-interface=[a-z0-9,]*/no-dhcp-interface=lo,$INET_IFACE/" $DNSMASQ_CONFIG
    sudo sed -i "s/interface:[a-z0-9]*/interface:$AP_IFACE/" $DNSMASQ_CONFIG

    # disable netorking of network manager
    nmcli networking off
    sleep 1
    sudo killall dnsmasq
    sleep 1
    sudo killall wpa_supplicant

    # enable inet
    sudo ifconfig $INET_IFACE up
    sleep 1
    sudo wpa_supplicant -B -i $INET_IFACE -c $WPA_SUPPLICANT_CONFIG
    sleep 1
    sudo dhclient -v $INET_IFACE
    sleep 1

    INET_INFO=$(ifconfig $INET_IFACE | grep "inet " | grep -o "[0-9.]*" | head -1)
    INET_NET=${INET_INFO%.*}.0/24

    echo $INET_INFO
    echo $INET_NET

    # enable access point
    AP_INFO=$(grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' $DNSMASQ_CONFIG | head -1)
    AP_IP=${AP_INFO%.*}.1
    AP_BC=${AP_INFO%.*}.255
    AP_NM=255.255.255.0

    echo $AP_IP
    echo $AP_BC

    sudo ifconfig $AP_IFACE up
    sleep 1
    sudo ifconfig $AP_IFACE $AP_IP broadcast $AP_BC netmask $AP_NM
    sleep 1

    # configure routing between interfaces
    sudo iptables -F
    sudo iptables -X
    sudo iptables -t nat -F

    sudo sysctl -w net.ipv4.ip_forward=1
    sudo iptables -A FORWARD -o $INET_IFACE -i $AP_IFACE -s $INET_NET -m conntrack --ctstate NEW -j ACCEPT
    sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    sudo iptables -t nat -A POSTROUTING -o $INET_IFACE -j MASQUERADE
    sleep 1

    # echo "nameserver 8.8.8.8" | sudo tee --append /var/run/dnsmasq/resolv.conf

    # restart hostapd and dnsmasq
    sudo /etc/init.d/hostapd restart
    sudo /etc/init.d/dnsmasq restart
}

clients()
{
    nmap -sL 192.168.10.101-110
}

stop()
{
    # stop wpa supplicant
    sudo killall wpa_supplicant
    sleep 1

    # stop hostapd and dnsmasq
    sudo /etc/init.d/hostapd stop
    sudo /etc/init.d/dnsmasq stop
    sleep 1

    # remove iptables entries
    sudo iptables -F
    sudo iptables -X
    sudo iptables -t nat -F

    # enable networking of network-manager
    nmcli networking on
}

if [ "$#" -lt "1" ]; then
    usage
fi

case $1 in
    start)
        start
        ;;
    stop)
        stop
        ;;
    clients)
        clients
        ;;
    *)
        usage
        ;;
esac

exit 0