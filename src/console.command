#!/bin/bash

# console.command
#

# get App's Resources folder
res_folder=$(cat ~/coreos-xhyve-ui/.env/resouces_path)

function pause(){
    read -p "$*"
}

# check VM status
status=$(ps aux | grep "[c]oreos-xhyve-ui" | awk '{print $2}')
if [ "$status" = "" ]; then
    echo " "
    echo "CoreOS VM is not running, please start VM !!!"
    pause "Press any key to continue ..."
    exit 1
fi

# Attach to VM's console
echo "Attaching to VM's console ..."
echo " "
"${res_folder}"/bin/dtach -a ~/coreos-xhyve-ui/.env/.coreos-xhyve.console
