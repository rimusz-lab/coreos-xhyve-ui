#!/bin/bash

# shared functions library

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


function pause(){
    read -p "$*"
}

function check_vm_status() {
# check VM status
status=$(ps aux | grep "[c]oreos-xhyve-ui/bin/xhyve" | awk '{print $2}')
if [ "$status" = "" ]; then
    echo " "
    echo "CoreOS VM is not running, please start VM !!!"
    pause "Press any key to continue ..."
    exit 1
fi
}


function release_channel(){
# Set release channel
LOOP=1
while [ $LOOP -gt 0 ]
do
    VALID_MAIN=0
    echo " "
    echo "Set CoreOS Release Channel:"
    echo " 1)  Alpha "
    echo " 2)  Beta "
    echo " 3)  Stable "
    echo " "
    echo -n "Select an option: "

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
}


function download_osx_clients() {
# download fleetctl file
LATEST_RELEASE=$(ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$vm_ip 'fleetctl version' | cut -d " " -f 3- | tr -d '\r')
cd ~/coreos-xhyve-ui/bin
echo "Downloading fleetctl v$LATEST_RELEASE for OS X"
curl -L -o fleet.zip "https://github.com/coreos/fleet/releases/download/v$LATEST_RELEASE/fleet-v$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "fleet.zip" "fleet-v$LATEST_RELEASE-darwin-amd64/fleetctl"
rm -f fleet.zip
echo "fleetctl was copied to ~/coreos-xhyve-ui/bin "
#

# download docker file
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
echo "docker was copied to ~/coreos-xhyve-ui/bin"
}


function check_for_images() {
# Check if set channel's images are present
CHANNEL=$(cat ~/coreos-xhyve-ui/custom.conf | grep CHANNEL= | head -1 | cut -f2 -d"=")
LATEST=$(ls -r ~/coreos-xhyve-ui/imgs/${CHANNEL}.*.vmlinuz | head -n 1 | sed -e "s,.*${CHANNEL}.,," -e "s,.coreos_.*,," )
if [[ -z ${LATEST} ]]; then
    echo "Couldn't find anything to load locally (${CHANNEL} channel)."
    echo "Fetching lastest $CHANNEL channel ISO ..."
    echo " "
    cd ~/coreos-xhyve-ui/
    "${res_folder}"/bin/coreos-xhyve-fetch -f custom.conf
fi
}


function deploy_fleet_units() {
# deploy fleet units from ~/coreos-xhyve-ui/fleet
if [ "$(ls ~/coreos-xhyve-ui/fleet | grep -o -m 1 service)" = "service" ]
then
    cd ~/coreos-xhyve-ui/fleet
    echo " "
    echo "Starting all fleet units in ~/coreos-xhyve-ui/fleet:"
    fleetctl start *.service
    echo " "
    echo "fleetctl list-units:"
    fleetctl list-units
    echo " "
fi
}
