#!/bin/bash

#  Reload VM
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# get App's Resources folder
res_folder=$(cat ~/coreos-xhyve-ui/.env/resouces_path)

# get VM IP
vm_ip=$(<~/coreos-xhyve-ui/.env/ip_address)

# Stop VM
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$vm_ip sudo halt
# wait till VM is stopped
echo " "
echo "Waiting for VM to shutdown..."
spin='-\|/'
i=0
until "${res_folder}"/check_vm_status.command | grep "VM is stopped" >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
#
spin='-\|/'
i=0
until [ ! -e ~/coreos-xhyve-ui/.env/.console ] >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
#

echo " "
# Check if set channel's images are present
check_for_images
#

# Start VM
rm -f ~/coreos-xhyve-ui/.env/.console
echo " "
echo "Starting VM ..."
"${res_folder}"/bin/dtach -n ~/coreos-xhyve-ui/.env/.console -z "${res_folder}"/start_VM.command
#

# wait till VM is booted up
echo "You can connect to VM console from menu 'Attach to VM's console' "
echo "When you done with console just close it's window/tab with CMD+W "
echo "Waiting for VM to boot up..."
spin='-\|/'
i=0
while ! ping -c1 $vm_ip >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
echo " "

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-xhyve-ui/bin:$PATH

# set fleetctl endpoint
export FLEETCTL_ENDPOINT=http://$vm_ip:2379
export FLEETCTL_DRIVER=etcd
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false

# wait till VM is ready
echo "Waiting for VM to be ready..."
spin='-\|/'
i=0
until curl -o /dev/null http://$vm_ip:2379 >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done

#
echo " "
echo "fleetctl list-machines:"
fleetctl list-machines
echo ""

# deploy fleet units from ~/coreos-xhyve-ui/my_fleet
deploy_my_fleet_units
#

echo "CoreOS VM was reloaded !!!"
echo ""
pause 'Press [Enter] key to continue...'
