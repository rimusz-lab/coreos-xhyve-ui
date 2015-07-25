#!/bin/bash

#  check VM status
#

# get App's Resources folder
res_folder=$(cat ~/coreos-xhyve-ui/.env/resouces_path)

status=$(ps aux | grep "[c]oreos-xhyve-ui/bin/xhyve" | awk '{print $2}')

if [ "$status" = "" ]; then
    echo "VM is stopped"
else
    echo "VM is running"
fi
