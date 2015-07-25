#!/bin/bash

#  halt.command
# stop VM via ssh

# get App's Resources folder
res_folder=$(cat ~/coreos-xhyve-ui/.env/resouces_path)

# get VM IP
#vm_ip=$( ~/coreos-xhyve-ui/mac2ip.sh $(cat ~/coreos-xhyve-ui/.env/mac_address))
vm_ip=$(cat ~/coreos-xhyve-ui/.env/ip_address)

# check VM status
status=$(ps aux | grep "[c]oreos-xhyve-ui/bin/xhyve" | awk '{print $2}')
if [ "$status" = "" ]; then
    echo "CoreOS VM is not running !!!"
    exit 1
fi

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$vm_ip sudo halt
