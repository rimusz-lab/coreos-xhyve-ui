#!/bin/bash

# console.command
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# get App's Resources folder
res_folder=$(cat ~/coreos-xhyve-ui/.env/resouces_path)

# check VM status and exit if not running
check_vm_status

# Attach to VM's console
echo "Attaching to VM's console ..."
echo " "
"${res_folder}"/bin/dtach -a ~/coreos-xhyve-ui/.env/.console
