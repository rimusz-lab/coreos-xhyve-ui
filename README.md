CoreOS-xhyve UI for OS X
============================

CoreOS-xhyve UI for Mac OS X is a Mac Status bar App which works like a wrapper around the [coreos-xhyve](https://github.com/coreos/coreos-xhyve) command line tool. It supports only a standalone CoreOS VM, cluster one (Vagrant based) is at [CoreOS-Vagrant Cluster GUI](https://github.com/rimusz/coreos-osx-gui-cluster).

Fully supports etcd2 in all CoresOS channels.


![CoreOS-xhyve-UI](coreos-xhyve-ui.png "CoreOS-xhyve-UI")


How to install CoreOS-xhyve UI
----------

**WARNING**
 -----------
  - You must be running OS X 10.10.3 Yosemite or later and 2010 or later Mac for this to work.

  - If you are, or were, running any version of VirtualBox, prior to 4.3.30 or 5.0,
and attempt to run xhyve your system will immediately crash as a kernel panic is
triggered. This is due to a VirtualBox bug (that got fixed in newest VirtualBox
versions) as VirtualBox wasn't playing nice with OSX's Hypervisor.framework used
by [xhyve](https://github.com/mist64/xhyve). To get around this you either have to update to newest VirtualBox 4.3 or 5.0 or, if you for some reason are unable to update, to reboot your Mac after using VirtualBox and before attempting to use xhyve. (see issues [#5](https://github.com/mist64/xhyve/issues/5) and [#9](https://github.com/mist64/xhyve/issues/9) for the full context)


####Required software:
* The only required software is [iTerm 2](http://www.iterm2.com/#/section/downloads) 
* As [xhyve](https://github.com/mist64/xhyve) comes with the App.

####Download:
* Download `CoreOS-xhyve UI latest.dmg` from the [Releases Page](https://github.com/rimusz/coreos-xhyve-ui/releases), open it and drag the App e.g to your Desktop.

###Install:

Start the `CoreOS-xhyve UI` and from menu `Setup` choose `Initial setup of CoreOS-xhyve UI` 
and the install will do the following:


- All dependent files/folders will be put under "coreos-xhyve-ui" folder in the user's home folder e.g /Users/someuser/coreos-xhyve-ui
- User's Mac password will be stored in `/Users/someuser/coreos-xhyve-ui/.env/password` and encrypted with `base64`, it will be used to pass to `sudo` command which needs to be used starting VM with xhyve
- ISO images are stored under ~/.coreos-xhyve/imgs and symlinked to it from ~/coreos-xhyve-ui/imgs
That allows to share the same images between different coreos-xhyve Apps and also speeds up this App's reinstall
- user-data file will have fleet, etcd, and Docker Socket for the API enabled
- Will download latest CoreOS ISO image and run `xhyve` to initialise VM with docker 2375 port pre-set for docker OS X client
- Will download and install `fleetctl` and `docker` OS X clients to ~/coreos-xhyve-ui/bin/
- A small shell script `rkt` will be installed to ~/coreos-xhyve-ui/bin/ which allows to call via ssh remote `rkt` binary on CoreOS VM
- A small shell script `etcdctl` will be installed to ~/coreos-xhyve-ui/bin/ which allows to call via ssh remote `etcdctl` binary on CoreOS VM
- `docker-exec `script (docker exec -it $1 bash -c 'export TERM=xterm && bash') is installed 
 into ~/coreos-xhyve-ui/bin/ too, which allows to enter container with just a simple command:
 docker-exec container_name 
- Also `docker2aci` binary will be installed to ~/coreos-xhyve-ui/bin/, which allows to convert docker images to rkt aci images
- Will install DockerUI and Fleet-UI via unit files
- Via assigned static IP (it will be shown in first boot and will survive VM's reboots) you can access any port on CoreOS VM
- user-data file enables docker flag `--insecure-registry` to access insecure registries.
- Extra persistant disk will be created and mounted to `/var/lib/docker`


How it works
------------

Just start `CoreOS-xhyve UI` application and you will find a small icon with the CoreOS logo with `h`in the Status Bar.

* There you can `Up`, `Halt`, `Reload` CoreOS VM
* `SSH to core-01` (vagrant ssh) will open VM shell
* `Attach to VM's console` will open console
* Under `Up` OS Shell will be opened when VM boot finishes up and it will have such environment pre-set:

````
DOCKER_HOST=tcp://192.168.64.xxx:2375
ETCDCTL_PEERS=http://192.168.64.xxx:2379
FLEETCTL_ENDPOINT=http://192.168.64.xxx:2379
FLEETCTL_DRIVER=etcd
Path to ~/coreos-xhyve-ui/bin where docker and fleetctl binaries, rkt and etcdclt shell 
scripts are stored
```` 
Also under 'Up" local webserver `python -m SimpleHTTPServer 18000` serves customized local user-data.

* `OS Shell` opens OS Shell with the same enviroment preset as `Up`
* `Updates/Check updates for OS X fleetctl and docker clients` will update fleet and docker OS X clients to the same versions as CoreOS VM runs.
* `Updates/Fetch latest CoreOS ISO` will download the lasted CoreOS ISO file for the currently set release channel. 
* [Fleet-UI](http://fleetui.com) dashboard will show running `fleet` units and etc
* [DockerUI](https://github.com/crosbymichael/dockerui) will show all running containers and etc
* Put your fleet units into `~/coreos-xhyve-ui/fleet` and they will be automaticly deployed on each VM boot.
* This App has as much automation as possible to make easier to use CoreOS on OS X, e.g. you can change CoreOS release channel and reload VM and your downloaded docker images will remain stored in an extra persistant disk. 

To-dos
-----------
* Add Kubernetes solo cluster setup as an extra Add-on option
* Mount /Users folder via nfs to CoreOS VM
* Enable/disable menu option depending on VM's status

Credits
-----------
* To [Michael Steil](https://github.com/mist64) for the awesome [xhyve](https://github.com/mist64/xhyve) lightweight OS X virtualization solution
* To CoreOS team for [coreos-xhyve](https://github.com/coreos/coreos-xhyve) version
* To [Antonio Meireles](https://github.com/AntonioMeireles) for his awesome tweaks spree to improve coreos-xhyve

Other links for Vagrant based VMs
-----------
* A standalone CoreOS VM version of OS X App can be found here [CoreOS-Vagrant GUI](https://github.com/rimusz/coreos-osx-gui).
* Cluster one CoreOS VM App can be found here [CoreOS-Vagrant Cluster GUI](https://github.com/rimusz/coreos-osx-gui-cluster).
* A standalone Kubernetes CoreOS VM App can be found here [CoreOS-Vagrant Kubernetes Solo GUI](https://github.com/rimusz/coreos-osx-gui-kubernetes-solo).
* Kubernetes Cluster one CoreOS VM App can be found here [CoreOS-Vagrant Kubernetes Cluster GUI ](https://github.com/rimusz/coreos-osx-gui-kubernetes-cluster).

