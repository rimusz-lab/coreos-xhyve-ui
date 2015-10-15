#!/bin/bash

#  Pre-set OS shell
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# get App's Resources folder
res_folder=$(cat ~/coreos-xhyve-ui/.env/resouces_path)

# get VM IP
#vm_ip=$(cat ~/coreos-xhyve-ui/.env/ip_address)
vm_ip=$(<~/coreos-xhyve-ui/.env/ip_address)

# Set the environment variable for the docker daemon
export DOCKER_HOST=tcp://$vm_ip:2375

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-xhyve-ui/bin:$PATH

# set etcd endpoint
export ETCDCTL_PEERS=http://$vm_ip:2379
echo " "
echo "etcdctl ls /:"
etcdctl --no-sync ls /
echo " "

# set fleetctl endpoint
export FLEETCTL_ENDPOINT=http://$vm_ip:2379
export FLEETCTL_DRIVER=etcd
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
echo "fleetctl list-machines:"
fleetctl list-machines
echo " "
echo "fleetctl list-units:"
fleetctl list-units
echo " "

export KUBERNETES_MASTER=http://$vm_ip:8080

cd ~/coreos-xhyve-ui

# open bash shell
/bin/bash
