#!/bin/bash

# up.command
#

# get App's Resources folder
res_folder=$(cat ~/coreos-xhyve-ui/.env/resouces_path)

# get VM IP
vm_ip=$(cat ~/coreos-xhyve-ui/.env/ip_address)

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
echo "etcdctl ls /:"
etcdctl --no-sync ls /

# set fleetctl endpoint
export FLEETCTL_ENDPOINT=http://$vm_ip:2379
export FLEETCTL_DRIVER=etcd
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false


# list fleet units
cd ~/coreos-xhyve-ui/fleet
echo " "
echo "Starting fleet units in ~/coreos-xhyve-ui/fleet:"
fleetctl start *.service
echo "fleetctl list-units:"
fleetctl list-units
echo " "

# deploy fleet units from ~/coreos-xhyve-ui/my_fleet
if [ "$machine_status" = "not created" ]
then
    if [ "$(ls ~/coreos-xhyve-ui/my_fleet | grep -o -m 1 service)" = "service" ]
    then
        cd ~/coreos-xhyve-ui/my_fleet
        echo "Start all fleet units in ~/coreos-xhyve-ui/my_fleet:"
        fleetctl start *.service
        echo "fleetctl list-units:"
        fleetctl list-units
        echo " "
    fi
fi

cd ~/

# open bash shell
/bin/bash
