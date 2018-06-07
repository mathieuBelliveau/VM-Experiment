#!/bin/bash
# ensure script is running as sudo
[ `whoami` = root ] || exec sudo "$0" "$@"

vmname="windows10vm"
if ps -A | grep -q $vmname; then
    # settings
    config_files="/home/ddgadmin/config/res"

    

    exit 0
else
    echo "$vmname is already running." &
    exit 1
fi

