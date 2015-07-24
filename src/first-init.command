#!/bin/bash

#  first-init.command
#


# get App's Resources folder
res_folder=$(cat ~/coreos-xhyve-ui/.env/resouces_path)

function pause(){
read -p "$*"
}

echo " "
echo "Setting up CoreOS-xhyve VM on OS X"

# add ssh key to custom.conf
echo " "
echo "Reading ssh key from $HOME/.ssh/id_rsa.pub  "
file="$HOME/.ssh/id_rsa.pub"
if [ -f "$file" ]
then
    echo "$file found, updating custom.conf..."
    echo "SSHKEY='$(cat $HOME/.ssh/id_rsa.pub)'" >> ~/coreos-xhyve-ui/custom.conf
else
    echo "$file not found."
    echo "please run 'ssh-keygen -t rsa' before you continue !!!"
    pause 'Press [Enter] key to continue...'
    echo "SSHKEY="$(cat $HOME/.ssh/id_rsa.pub)"" >> ~/coreos-xhyve-ui/custom.conf
fi
#

# save user password to file
echo "  "
echo "Please type your password followed by [ENTER] to be saved and used later one for sudo:"
read -s password
echo -n ${password} | base64 > ~/coreos-xhyve-ui/.env/password
#

# create persistant disk
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


# now let's fetch ISO file
echo " "
echo "Fetching lastest iso ..."
echo " "
cd ~/coreos-xhyve-ui/
./coreos-xhyve-fetch -f custom.conf
echo " "
#

echo " "
echo "CoreOS VM will be started in a new Terminal.app window ..."
pause 'Press [Enter] key to continue...'
# Start VM
open -a Terminal.app "${res_folder}"/CoreOS-xhyve_UI_VM.command
#
# wait till VM is booted up
echo "Waiting for VM to boot up..."
spin='-\|/'
i=0
until ! ping -c1 $vm_ip >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done


# get VM IP
vm_ip=$(cat ~/coreos-xhyve-ui/.env/ip_address)

# download etcdctl and fleetctl
#
LATEST_RELEASE=$(ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$vm_ip "etcdctl --version" | cut -d " " -f 3- | tr -d '\r' )
cd ~/coreos-xhyve-ui/bin
echo "Downloading etcdctl $LATEST_RELEASE for OS X"
curl -L -o etcd.zip "https://github.com/coreos/etcd/releases/download/v$LATEST_RELEASE/etcd-v$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "etcd.zip" "etcd-v$LATEST_RELEASE-darwin-amd64/etcdctl"
rm -f etcd.zip
#
LATEST_RELEASE=$(ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$vm_ip 'fleetctl version' | cut -d " " -f 3- | tr -d '\r')
cd ~/coreos-xhyve-ui/bin
echo "Downloading fleetctl v$LATEST_RELEASE for OS X"
curl -L -o fleet.zip "https://github.com/coreos/fleet/releases/download/v$LATEST_RELEASE/fleet-v$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "fleet.zip" "fleet-v$LATEST_RELEASE-darwin-amd64/fleetctl"
rm -f fleet.zip

# download docker client
DOCKER_VERSION=$(ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$vm_ip  'docker version' | grep 'Server version:' | cut -d " " -f 3- | tr -d '\r')

CHECK_DOCKER_RC=$(echo $DOCKER_VERSION | grep rc)
if [ -n "$CHECK_DOCKER_RC" ]
then
    # docker RC release
    if [ -n "$(curl -s --head https://test.docker.com/builds/Darwin/x86_64/docker-$DOCKER_VERSION | head -n 1 | grep "HTTP/1.[01] [23].." | grep 200)" ]
    then
        # we check if RC is still available
        echo "Downloading docker $DOCKER_VERSION client for OS X"
        curl -o ~/coreos-xhyve-ui/bin/docker https://test.docker.com/builds/Darwin/x86_64/docker-$DOCKER_VERSION
    else
        # RC is not available anymore, so we download stable release
        DOCKER_VERSION_STABLE=$(echo $DOCKER_VERSION | cut -d"-" -f1)
        echo "Downloading docker $DOCKER_VERSION_STABLE client for OS X"
        curl -o ~/coreos-xhyve-ui/bin/docker https://get.docker.com/builds/Darwin/x86_64/docker-$DOCKER_VERSION_STABLE
    fi
else
    # docker stable release
    echo "Downloading docker $DOCKER_VERSION client for OS X"
    curl -o ~/coreos-xhyve-ui/bin/docker https://get.docker.com/builds/Darwin/x86_64/docker-$DOCKER_VERSION
fi
# Make it executable
chmod +x ~/coreos-xhyve-ui/bin/docker
#


# set fleetctl endpoint and install fleet units
export FLEETCTL_ENDPOINT=http://$vm_ip:2379
export FLEETCTL_DRIVER=etcd
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
echo "fleetctl list-machines:"
fleetctl list-machines
echo " "
# install fleet units
echo "Installing fleet units from '~/coreos-xhyve-ui/fleet' folder"
cd ~/coreos-xhyve-ui/fleet
~/coreos-xhyve-ui/bin/fleetctl submit *.service
~/coreos-xhyve-ui/bin/fleetctl start *.service
echo "Finished installing fleet units:"
fleetctl list-units
echo " "

#
echo "Installation has finished, CoreOS VM is up and running !!!"
echo "Enjoy CoreOS-xhyve VM on your Mac !!!"
echo ""
echo "Run from menu 'OS Shell' to open a terninal window with rkt, docker, fleetctl and etcdctl pre-set !!!"
echo ""
pause 'Press [Enter] key to continue...'

