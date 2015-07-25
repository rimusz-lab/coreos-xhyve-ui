#!/bin/bash

#  fetch latest iso
#

# get App's Resources folder
res_folder=$(cat ~/coreos-xhyve-ui/.env/resouces_path)

CHANNEL=$(cat ~/coreos-xhyve-ui/custom.conf | grep CHANNEL= | head -1 | cut -f2 -d"=")

function pause(){
read -p "$*"
}

echo " "
echo "Fetching lastest CoreOS $CHANNEL channel ISO ..."
echo " "

cd ~/coreos-xhyve-ui/
"${res_folder}"/bin/coreos-xhyve-fetch -f custom.conf

echo " "
pause 'Press [Enter] key to continue...'
