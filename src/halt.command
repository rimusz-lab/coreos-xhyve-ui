#!/bin/bash

#  halt.command
# stop VM via ssh

# get App's Resources folder
res_folder=$(cat ~/coreos-xhyve-ui/.env/resouces_path)

# Stop docker registry
"${res_folder}"/bin/docker_registry stop

# get VM IP
#vm_ip=$( ~/coreos-xhyve-ui/mac2ip.sh $(cat ~/coreos-xhyve-ui/.env/mac_address))
vm_ip=$(cat ~/coreos-xhyve-ui/.env/ip_address)

# send halt to VM
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$vm_ip sudo halt

