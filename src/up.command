#!/bin/bash

# up.command
#

#


# get App's Resources folder
res_folder=$(cat ~/coreos-xhyve-ui/.env/resouces_path)

# get VM IP
vm_ip=$(cat ~/coreos-xhyve-ui/.env/ip_address)

function pause(){
    read -p "$*"
}

# check if VM is already running
status=$(ps aux | grep "[c]oreos-xhyve-ui" | awk '{print $2}')
if [[ "$status" -ne "" ]]; then
    echo " "
    pause "CoreOS VM is already running, press any key to continue ..."
    exit 1
fi


echo " "
# Check if set channel's images are present
CHANNEL=$(cat ~/coreos-xhyve-ui/custom.conf | grep CHANNEL= | head -1 | cut -f2 -d"=")
LATEST=$(ls -r ~/coreos-xhyve-ui/imgs/${CHANNEL}.*.vmlinuz | head -n 1 | sed -e "s,.*${CHANNEL}.,," -e "s,.coreos_.*,," )

if [[ -z ${LATEST} ]]; then
    echo "Couldn't find anything to load locally (${CHANNEL} channel)."
    echo "Fetching lastest $CHANNEL channel ISO ..."
    echo " "
    cd ~/coreos-xhyve-ui/
    "${res_folder}"/bin/coreos-xhyve-fetch -f custom.conf
fi


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

cd ~/

# open bash shell
/bin/bash
