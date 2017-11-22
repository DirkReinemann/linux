#!/bin/bash

pidfile=/tmp/bashradio.pid
logfile=/tmp/bashradio.log
cnffile=/home/$USER/.config/bashradio.cnf

usage()
{
    echo "Play radio streams and music files in bash."
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-20s %s\n" "-p [NUMBER|FILE]" "play stream with number"
    printf "  %-20s %s\n" "-s" "stop stream"
    printf "  %-20s %s\n" "-l" "list stream"
    exit 1
}

url()
{
    local url=""
    local i=1
    while read radio; do
        if [ $1 -eq $i ]; then
            URL=$(echo $radio | awk -F\; '{ print $2 }')
        fi
        I=$(expr $i + 1)
    done < $cnffile
    echo "$url"
}

play()
{
    nohup vlc -I dummy "$1" > $logfile 2>&1 &
    echo $! > $pidfile
    if [ -f $pidfile ]; then
        echo "Stream started sucessfully."
    else
        echo "Error while starting the stream. Please check logfile '$logfile' for mor information."
        exit 2
    fi
}

play_radio()
{
    local url=$(url $1)

    if [ -z $url ]; then
        echo "Error while starting the stream. The given stream number doesn't exist."
        exit 1
    fi

    play $url
}

stop()
{
    if [ -f $pidfile ]; then
        pkill -F $pidfile && rm $pidfile
        echo "Stream stopped successfully."
    else
        echo "Error while stopping the stream. The pidfile '$pidfile' was not found."
        exit 3
    fi
}

list()
{
    sort -o $cnffile $cnffile

    local i=1
    while read radio; do
        name=$(echo $radio | awk -F\; '{ print $1 }')
        echo "$I. $name"
        I=$(expr $I + 1)
    done < $cnffile
}

if [ $# == 0 ]; then
    usage
fi

if [ ! -f $cnffile ]; then
    touch $cnffile
    echo "The configuration file '$cnffile' was created sucessfully."
    exit 4
fi

while getopts ":p:sl" opt; do
    case $opt in
        p)
            if [[ $OPTARG =~ ^[0-9]*$ ]]; then
                play_radio $OPTARG
            elif [[ -f $OPTARG ]]; then
                play "$OPTARG"
            else
                echo "Error while starting the stream. The given input value in neither a number nor a file."
                exit 1
            fi
        ;;
        s)
            stop
        ;;
        l)
            list
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
