#!/bin/bash -x

# Start VM
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# get App's Resources folder
res_folder=$(cat ~/coreos-xhyve-ui/.env/resouces_path)

# Get UUID
UUID=$(cat ~/coreos-xhyve-ui/custom.conf | grep UUID= | head -1 | cut -f2 -d"=")
# Get password
my_password=$(cat ~/coreos-xhyve-ui/.env/password | base64 --decode )
# Get mac address and save it
echo -e "$my_password\n" | sudo -S "${res_folder}"/bin/uuid2mac $UUID > ~/coreos-xhyve-ui/.env/mac_address

# Get VM's IP and save it to file
"${res_folder}"/bin/get_ip &

# Start webserver
cd ~/coreos-xhyve-ui/cloud-init
"${res_folder}"/bin/webserver start

# Start VM
echo "Waiting for VM to boot up... "
cd ~/coreos-xhyve-ui
export XHYVE=~/coreos-xhyve-ui/bin/xhyve
"${res_folder}"/bin/coreos-xhyve-run -f custom.conf coreos-xhyve-ui

# Stop webserver
"${res_folder}"/bin/webserver stop
