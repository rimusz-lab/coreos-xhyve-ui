#!/bin/bash

# up.command
#

#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# get App's Resources folder
res_folder=$(cat ~/coreos-xhyve-ui/.env/resouces_path)

# get VM IP
vm_ip=$(cat ~/coreos-xhyve-ui/.env/ip_address)

# copy xhyve to bin folder
cp -f "${res_folder}"/bin/xhyve ~/coreos-xhyve-ui/bin
chmod 755 ~/coreos-xhyve-ui/bin/xhyve

# check if VM is already running
#status=$(ps aux | grep "[c]oreos-xhyve-ui/bin/xhyve" | awk '{print $2}')
#if [[ $status = *[!\ ]* ]]; then
#    echo " "
#    pause "CoreOS VM is already running, press any key to continue ..."
#    exit 1
#fi

# Check if set channel's images are present
check_for_images

# Start VM
rm -f ~/coreos-xhyve-ui/.env/.console
echo " "
echo "Starting VM ..."
"${res_folder}"/bin/dtach -n ~/coreos-xhyve-ui/.env/.console -z "${res_folder}"/CoreOS-xhyve_UI_VM.command
#

# wait till VM is booted up
echo "You can connect to VM console from menu 'Attach to VM's console' "
echo "When you done with console just close it's window/tab with CMD+W "
echo "Waiting for VM to boot up..."
spin='-\|/'
i=0
while ! ping -c1 $vm_ip >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done

# Set the environment variable for the docker daemon
export DOCKER_HOST=tcp://$vm_ip:2375

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-xhyve-ui/bin:$PATH

# set etcd endpoint
export ETCDCTL_PEERS=http://$vm_ip:2379
# wait till VM is ready
echo " "
echo "Waiting for VM to be ready..."
spin='-\|/'
i=0
until curl -o /dev/null http://$vm_ip:2379 >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
#
echo " "
echo "etcdctl ls /:"
etcdctl --no-sync ls /
echo " "
#

# set fleetctl endpoint
export FLEETCTL_ENDPOINT=http://$vm_ip:2379
export FLEETCTL_DRIVER=etcd
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
#
echo "fleetctl list-machines:"
fleetctl list-machines
echo " "

# deploy fleet units from ~/coreos-xhyve-ui/fleet
deploy_fleet_units
#

cd ~/

# open bash shell
/bin/bash
