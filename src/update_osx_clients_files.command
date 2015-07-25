#!/bin/bash 

#  update OS X clients
#

# get App's Resources folder
res_folder=$(cat ~/coreos-xhyve-ui/.env/resouces_path)

# get VM IP
vm_ip=$(cat ~/coreos-xhyve-ui/.env/ip_address)

function pause(){
read -p "$*"
}

# check VM status
status=$(ps aux | grep "[c]oreos-xhyve-ui/bin/xhyve" | awk '{print $2}')
if [ "$status" = "" ]; then
    echo " "
    echo "CoreOS VM is not running, please start VM !!!"
    pause "Press any key to continue ..."
    exit 1
fi
#

# copy files to ~/coreos-xhyve-ui/bin
cp -f "${res_folder}"/files/* ~/coreos-xhyve-ui/bin
# copy xhyve to bin folder
cp -f "${res_folder}"/bin/xhyve ~/coreos-xhyve-ui/bin
chmod 755 ~/coreos-xhyve-ui/bin/*

# download latest versions of etcdctl and fleetctl
#
LATEST_RELEASE=$(ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$vm_ip "etcdctl --version" | cut -d " " -f 3- | tr -d '\r' )
cd ~/coreos-xhyve-ui/bin
echo "Downloading etcdctl $LATEST_RELEASE for OS X"
curl -L -o etcd.zip "https://github.com/coreos/etcd/releases/download/v$LATEST_RELEASE/etcd-v$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "etcd.zip" "etcd-v$LATEST_RELEASE-darwin-amd64/etcdctl"
rm -f etcd.zip
echo "etcdctl was copied to ~/coreos-xhyve-ui/bin "
#
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
#

echo " "
echo "Update has finished !!!"
pause 'Press [Enter] key to continue...'

