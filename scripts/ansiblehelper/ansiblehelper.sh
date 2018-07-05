#!/bin/bash

print_usage()
{
    echo "Ansible helper script"
    echo
    printf "Usage: %s [Options]" "$0"
    echo
    echo "Options:"
    printf "  %-20s %s\n" "-l [Variable File]" "print a list of variables from the given variable file"
    printf "  %-20s %s\n" "-u [Variable File] [Playbook Directory]" "print a list of unused varibales for the playbooks in the given directory"
    exit 1
}

check_file()
{
    local filename="$1"
    if [ ! -f "$filename" ]; then
        printf "The filename '%s' doesn't exist.\n" "$filename"
        exit 2
    fi
}

check_directory()
{
    local directory="$1"
    if [ ! -d "$directory" ]; then
        printf "The directory '%s' doesn't exist.\n" "$directory"
        exit 3
    fi
}

list_all_variables()
{
    local filename="$1"
    check_file "$filename"
    cat "$filename" | grep -E '^[A-Za-z]' | awk -F':' '{ print $1 }'
}

list_unused_variables()
{
    local filename="$1"
    check_file "$filename"

    local directory="$2"
    check_directory "$directory"

    local variable
    for variable in $(list_all_variables "$filename"); do
        if ! grep -rE "{{[ ]*$variable[ ]*}}" "$directory" >/dev/null 2>&1; then
            echo "$variable"
        fi
    done
}



if [ $# -eq 0 ]; then
    print_usage
fi

while getopts ":l:u:" opt; do
    case $opt in
        l)
            list_all_variables "$OPTARG"
        ;;
        u)
            shift $((OPTIND-2))
            list_unused_variables "$1" "$2"
        ;;
        \?)
            print_usage
        ;;
        :)
            print_usage
        ;;
    esac
done

exit 0
