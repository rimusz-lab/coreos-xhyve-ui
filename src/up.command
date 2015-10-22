#!/bin/bash

# up.command
#

#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# get App's Resources folder
res_folder=$(cat ~/coreos-xhyve-ui/.env/resouces_path)

# copy xhyve to bin folder
cp -f "${res_folder}"/bin/xhyve ~/coreos-xhyve-ui/bin
chmod 755 ~/coreos-xhyve-ui/bin/xhyve

# Stop webserver just in case it was left running
"${res_folder}"/bin/webserver stop

# check for password file
if [ ! -f ~/coreos-xhyve-ui/.env/password ]
then
    echo "File with saved password is not found: "
    save_password
fi

# Check if set channel's images are present
check_for_images

new_vm=0
# check if root disk exists, if not create it
if [ ! -f $HOME/coreos-xhyve-ui/root.img ]; then
    echo " "
    echo "ROOT disk does not exist, it will be created now ..."
    create_root_disk
    new_vm=1
fi

# Start docker registry
cd ~/coreos-xhyve-ui
# stop first just in case it was running
"${res_folder}"/bin/docker_registry stop
# start
"${res_folder}"/bin/docker_registry start

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
while [ ! -f ~/coreos-xhyve-ui/.env/ip_address ]; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
# get VM IP
vm_ip=$(cat ~/coreos-xhyve-ui/.env/ip_address);
# wait for VM to be ready
i=0
while ! ping -c1 $vm_ip >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done

# Set the environment variables
# docker daemon
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
sleep 1

echo "fleetctl list-machines:"
fleetctl list-machines
echo " "

# deploy fleet units
if [ $new_vm = 1 ]
then
    deploy_fleet_units
fi

# deploy fleet units from my_fleet folder
deploy_my_fleet_units

#
echo "fleetctl list-units:"
fleetctl list-units
echo " "

#
cd ~/coreos-xhyve-ui

# open bash shell
/bin/bash
