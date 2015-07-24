#!/bin/bash

#  first-init.command
#  CoreOS-xhyve UI
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

### Set release channel
LOOP=1
while [ $LOOP -gt 0 ]
do
    VALID_MAIN=0
    echo " "
    echo " Set CoreOS Release Channel:"
    echo " 1)  Alpha "
    echo " 2)  Beta "
    echo " 3)  Stable "
    echo " "
    echo "Select an option:"

    read RESPONSE
    XX=${RESPONSE:=Y}

    if [ $RESPONSE = 1 ]
    then
        VALID_MAIN=1
        sed -i "" "s/CHANNEL=stable/CHANNEL=alpha/" ~/coreos-xhyve-ui/custom.conf
        sed -i "" "s/CHANNEL=beta'/CHANNEL=alpha/" ~/coreos-xhyve-ui/custom.conf
        LOOP=0
    fi

    if [ $RESPONSE = 2 ]
    then
        VALID_MAIN=1
        sed -i "" "s/CHANNEL=alpha/CHANNEL=beta/" ~/coreos-xhyve-ui/custom.conf
        sed -i "" "s/CHANNEL=stable/CHANNEL=beta/" ~/coreos-xhyve-ui/custom.conf
        LOOP=0
    fi

    if [ $RESPONSE = 3 ]
    then
        VALID_MAIN=1
        sed -i "" "s/CHANNEL=alpha/CHANNEL=stable/" ~/coreos-xhyve-ui/custom.conf
        sed -i "" "s/CHANNEL=beta/channel=stable/" ~/coreos-xhyve-ui/custom.conf
        LOOP=0
    fi

    if [ $VALID_MAIN != 1 ]
    then
        continue
    fi
done
### Set release channel

# first up to fetch ISO file
echo "Setting up CoreOS-xhyve VM on OS X"
echo " "
echo "Fetching lastet iso ..."
echo " "
cd ~/coreos-xhyve-ui/
./coreos-xhyve-fetch -f custom.conf
echo " "

# Start VM
open -a Terminal.app  ~/coreos-xhyve-ui/run.sh &

# get VM IP
vm_ip=$( ~/coreos-xhyve-ui/mac2ip.sh $(cat ~/coreos-xhyve-ui/.env/mac_address))

# wait till VM is booted up
while ! ping -c1 $vm_ip &>/dev/null; do sleep 1; done
 
## Load docker images if there any
# Set the environment variable for the docker daemon
export DOCKER_HOST=tcp://$vm_ip:2375

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-xhyve-ui/bin:$PATH


echo " "
echo "# It can upload your docker images to CoreOS VM # "
echo "If you want copy your docker images in *.tar format to ~/coreos-xhyve-ui/docker_images folder !!!"
pause 'Press [Enter] key to continue...'

cd ~/coreos-xhyve-ui/docker_images

if [ "$(ls | grep -o -m 1 tar)" = "tar" ]
then
    for file in *.tar
    do
        echo "Loading docker image: $file"
        docker load < $file
    done
    echo "Done with docker images !!!"
else
    echo "Nothing to upload !!!"
fi
echo " "
##

# set fleetctl endpoint and install fleet units
export FLEETCTL_ENDPOINT=http://$vm_ip:2379
export FLEETCTL_DRIVER=etcd
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
echo "fleetctl list-machines:"
fleetctl list-machines
echo " "
fleetctl list-units
echo " "

#
echo "Installation has finished, CoreOS VM is up and running !!!"
echo "Enjoy CoreOS-xhyve VM on your Mac !!!"
echo ""
echo "Run from menu 'OS Shell' to open a terninal window with docker, fleetctl, etcdctl and rkt pre-set !!!"
echo ""
pause 'Press [Enter] key to continue...'

