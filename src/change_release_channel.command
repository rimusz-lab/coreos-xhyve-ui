#!/bin/bash

#  change release channel
#

### Set release channel
LOOP=1
while [ $LOOP -gt 0 ]
do
    VALID_MAIN=0
    echo " "
    echo " CoreOS Release Channel:"
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
        sed -i "" "s/CHANNEL=beta/CHANNEL=alpha/" ~/coreos-xhyve-ui/custom.conf
        channel="Alpha"
        LOOP=0
    fi

    if [ $RESPONSE = 2 ]
    then
        VALID_MAIN=1
        sed -i "" "s/CHANNEL=alpha/CHANNEL=beta/" ~/coreos-xhyve-ui/custom.conf
        sed -i "" "s/CHANNEL=stable/CHANNEL=beta/" ~/coreos-xhyve-ui/custom.conf
        channel="Beta"
        LOOP=0
    fi

    if [ $RESPONSE = 3 ]
    then
        VALID_MAIN=1
        sed -i "" "s/CHANNEL=alpha/CHANNEL=stable/" ~/coreos-xhyve-ui/custom.conf
        sed -i "" "s/CHANNEL=beta/CHANNEL=stable/" ~/coreos-xhyve-ui/custom.conf
        channel="Stable"
        LOOP=0
    fi

    if [ $VALID_MAIN != 1 ]
    then
        continue
    fi
done
### Set release channel

function pause(){
read -p "$*"
}

#
echo "The 'custom.conf' file was updated to $channel channel !!!"
echo "You need to run from menu 'Reload' to get VM restarted with the new channel ..."
pause 'Press [Enter] key to continue...'
