#!/bin/bash

#  fetch latest iso
#

# get App's Resources folder
res_folder=$(cat ~/coreos-xhyve-ui/.env/resouces_path)

function pause(){
read -p "$*"
}

echo "Fetching lastet iso ..."
echo " "

cd ~/coreos-xhyve-ui/
"${res_folder}"/bin/coreos-xhyve-fetch -f custom.conf

echo " "
pause 'Press [Enter] key to continue...'
