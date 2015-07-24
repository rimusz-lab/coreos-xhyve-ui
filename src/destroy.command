#!/bin/bash

# destroy extra disk and create new
#


# get App's Resources folder
res_folder=$(cat ~/coreos-xhyve-ui/.env/resouces_path)

# get VM IP
vm_ip=$(<~/coreos-xhyve-ui/.env/ip_address)

function pause(){
read -p "$*"
}

LOOP=1
while [ $LOOP -gt 0 ]
do
    VALID_MAIN=0
    echo "VM will be stopped and extra disk recreated !!!""
    echo "Do you want to continue [y/n]"

    read RESPONSE
    XX=${RESPONSE:=Y}

    if [ $RESPONSE = y ]
    then
        VALID_MAIN=1
        # Stop VM
        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$vm_ip sudo halt

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
        #
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



