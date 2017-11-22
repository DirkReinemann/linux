#!/bin/bash

# INSTALL:
#
# - sudo cp cleanhistory.cp /usr/bin/cleanhistory
# - sudo cp cleanhistory.service /etc/systemd/system/cleanhistory.service
# - sudo service enable cleanhistory.service
# - sudo service start cleanhistory.service

configfile="/home/dirk/.config/cleanhistory.cnf"
sublimefile="/home/dirk/.config/sublime-text-3/Local/Session.sublime_session"

usage()
{
    echo "Clean history files."
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-20s %s\n" "-c" "clean history files"
    printf "  %-20s %s\n" "-j" "clean journal log"
    printf "  %-20s %s\n" "-p" "clean pacman cache"
    printf "  %-20s %s\n" "-s" "clean sublime history"
    printf "  %-20s %s\n" "-l" "list history files"
    printf "  %-20s %s\n" "-t" "test history files"
    printf "  %-20s %s\n" "-o" "remove unused pacman packages"
    exit 1
}

cleanfiles()
{
    while read line; do
        sudo rm -vrf $line
    done < $configfile
}

listfiles()
{
    while read line; do
        echo $line
    done < $configfile
}

checkfiles()
{
    while read line; do
        if [ ! -f $line ] && [ ! -d $line ]; then
            printf "\e[31m%s\n" "$line"
        else
            printf "\e[32m%s\n" "$line"
        fi
    done < $configfile
}

journallog()
{
    sudo journalctl --rotate --flush && sudo journalctl --vacuum-size=1K --vacuum-time=1s
}

pacmancache()
{
    sudo pacman -Sc --noconfirm
}

sublimehistory()
{
    jq '.folder_history = []' $sublimefile | sponge $sublimefile
    jq '.settings.new_window_settings.file_history = []' $sublimefile | sponge $sublimefile
    jq '.windows[].file_history = []' $sublimefile | sponge $sublimefile
    jq '.settings.new_window_settings.find_state.find_history = []' $sublimefile | sponge $sublimefile
    jq '.windows[].find_state.find_history = []' $sublimefile | sponge $sublimefile
    jq '.settings.new_window_settings.find_state.replace_history = []' $sublimefile | sponge $sublimefile
    jq '.windows[].find_state.replace_history = []' $sublimefile | sponge $sublimefile
    jq '.settings.new_window_settings.console.history = []' $sublimefile | sponge $sublimefile
    jq '.windows[].console.history = []' $sublimefile | sponge $sublimefile
    jq '.settings.new_window_settings.find_in_files.where_history = []' $sublimefile | sponge $sublimefile
    jq '.windows[].find_in_files.where_history = []' $sublimefile | sponge $sublimefile
}

unusedpackages()
{
    sudo pacman -Rns --noconfirm $(pacman -Qtdq)
}

if [ $# == 0 ]; then
    usage
fi

if [ ! -f $configfile ]; then
    touch $configfile && echo "The configuration file '$configfile' was not found and therefore created."
fi

while getopts "cljptso" opt; do
    case $opt in
        c)
            cleanfiles
        ;;
        l)
            listfiles
        ;;
        j)
            journallog
        ;;
        p)
            pacmancache
        ;;
        s)
            sublimehistory
        ;;
        t)
            checkfiles
        ;;
        o)
            unusedpackages
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
