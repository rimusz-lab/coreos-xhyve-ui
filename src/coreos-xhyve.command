#!/bin/bash

#  coreos-xhyve.command
# run commands on VM via ssh

# get App's Resources folder
res_folder=$(cat ~/coreos-xhyve-ui/.env/resouces_path)

# get VM IP
#vm_ip=$( ~/coreos-xhyve-ui/mac2ip.sh $(cat ~/coreos-xhyve-ui/.env/mac_address))
vm_ip=$(cat ~/coreos-xhyve-ui/.env/ip_address)

# pass some arguments via $1 $2 ...
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$vm_ip $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12}
