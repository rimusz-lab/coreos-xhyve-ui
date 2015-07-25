#!/bin/bash

#  Reload VM
#

# get App's Resources folder
res_folder=$(cat ~/coreos-xhyve-ui/.env/resouces_path)

# get VM IP
vm_ip=$(<~/coreos-xhyve-ui/.env/ip_address)

function pause(){
read -p "$*"
}

# Stop VM
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$vm_ip sudo halt
# wait till VM is stopped
echo "Waiting for VM to shutdown..."
spin='-\|/'
i=0
until "${res_folder}"/check_vm_status.command | grep "VM is stopped" >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
#

sleep 3
echo " "
echo "CoreOS VM will be started in a new Terminal.app window ..."
# Start VM
open -a Terminal.app "${res_folder}"/CoreOS-xhyve_UI_VM.command
#

# wait till VM is booted up
echo "Waiting for VM to boot up..."
spin='-\|/'
i=0
until ! ping -c1 $vm_ip >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
echo " "

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-xhyve-ui/bin:$PATH

# set fleetctl endpoint
export FLEETCTL_ENDPOINT=http://$vm_ip:2379
export FLEETCTL_DRIVER=etcd
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
#
echo "fleetctl list-machines:"
fleetctl list-machines
echo ""

# deploy fleet units from ~/coreos-xhyve-ui/fleet
if [ "$(ls ~/coreos-xhyve-ui/fleet | grep -o -m 1 service)" = "service" ]
then
    cd ~/coreos-xhyve-ui/fleet
    echo " "
    echo "Starting all fleet units in ~/coreos-xhyve-ui/fleet:"
    fleetctl start *.service
    echo " "
    echo "fleetctl list-units:"
    fleetctl list-units
    echo " "
fi
#
echo "CoreOS VM was reloaded !!!"
echo ""
pause 'Press [Enter] key to continue...'
