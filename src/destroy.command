#!/bin/bash

# destroy extra disk and create new
#

#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# get App's Resources folder
res_folder=$(cat ~/coreos-xhyve-ui/.env/resouces_path)

# get VM IP
vm_ip=$(<~/coreos-xhyve-ui/.env/ip_address)

LOOP=1
while [ $LOOP -gt 0 ]
do
    VALID_MAIN=0
    echo "VM will be stopped and extra disk recreated !!!"
    echo "Do you want to continue [y/n]"

    read RESPONSE
    XX=${RESPONSE:=Y}

    if [ $RESPONSE = y ]
    then
        VALID_MAIN=1

        # check VM status
        status=$(ps aux | grep "[c]oreos-xhyve-ui/bin/xhyve" | awk '{print $2}')
        if [[ $status = *[!\ ]* ]]; then
            echo " "
            echo "CoreOS VM is running, it will be  stopped !!!"

            # Stop VM
            ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$vm_ip sudo halt

            # wait till VM is stopped
            echo " "
            echo "Waiting for VM to shutdown..."
            spin='-\|/'
            i=0
            until "${res_folder}"/check_vm_status.command | grep "VM is stopped" >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
        fi

        # delete extra.image
        rm -f ~/coreos-xhyve-ui/extra.img

        # create new extra.image
        cd ~/coreos-xhyve-ui/
        echo "  "
        echo "Please type extra disk size in GB followed by [ENTER]:"
        echo -n [default is 5]:
        read disk_size
        if [ -z "$disk_size" ]
        then
            echo "Creating 5GB disk ..."
            dd if=/dev/zero of=extra.img bs=1024 count=0 seek=$[1024*5120]
        else
            echo "Creating "$disk_size"GB disk ..."
            dd if=/dev/zero of=extra.img bs=1024 count=0 seek=$[1024*$disk_size*1024]
        fi
        echo "-"
        echo "Done, please start VM with 'Up' ..."
        echo " "
        pause 'Press [Enter] key to continue...'
        LOOP=0
    fi

    if [ $RESPONSE = n ]
    then
        VALID_MAIN=1
        LOOP=0
    fi

    if [ $VALID_MAIN != y ] || [ $VALID_MAIN != n ]
    then
        continue
    fi
done




