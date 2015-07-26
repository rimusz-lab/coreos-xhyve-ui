#!/bin/bash 

#  update OS X clients
#

#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# get App's Resources folder
res_folder=$(cat ~/coreos-xhyve-ui/.env/resouces_path)

# get VM IP
vm_ip=$(cat ~/coreos-xhyve-ui/.env/ip_address)

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-xhyve-ui/bin:$PATH

# check VM status and exit if not running
check_vm_status

# copy files to ~/coreos-xhyve-ui/bin
cp -f "${res_folder}"/files/* ~/coreos-xhyve-ui/bin
# copy xhyve to bin folder
cp -f "${res_folder}"/bin/xhyve ~/coreos-xhyve-ui/bin
chmod 755 ~/coreos-xhyve-ui/bin/*

# download latest versions of fleetctl and docker clients
download_osx_clients
#

echo " "
echo "Update has finished !!!"
pause 'Press [Enter] key to continue...'

