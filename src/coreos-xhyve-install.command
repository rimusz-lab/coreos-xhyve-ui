#!/bin/bash

#  coreos-xhyve-install.command
#

    # create in "coreos-xhyve-ui" all required folders and files at user's home folder where all the data will be stored
    mkdir -p ~/.coreos-xhyve/imgs
    mkdir ~/coreos-xhyve-ui
    ln -s ~/.coreos-xhyve/imgs ~/coreos-xhyve-ui/imgs
    mkdir ~/coreos-xhyve-ui/tmp
    mkdir ~/coreos-xhyve-ui/bin
    mkdir ~/coreos-xhyve-ui/cloud-init
    mkdir ~/coreos-xhyve-ui/fleet
    ###mkdir ~/coreos-xhyve-ui/docker_images
    ###mkdir ~/coreos-xhyve-ui/rkt_images

    # cd to App's Resources folder
    cd "$1"

    # copy files to ~/coreos-xhyve-ui/bin
    cp -f "$1"/files/* ~/coreos-xhyve-ui/bin
    # copy xhyve to bin folder
    cp -f "$1"/bin/xhyve ~/coreos-xhyve-ui/bin
    chmod 755 ~/coreos-xhyve-ui/bin/*

    # copy user-data
    cp -f "$1"/settings/user-data ~/coreos-xhyve-ui/cloud-init
    cp -f "$1"/settings/user-data-format-root ~/coreos-xhyve-ui/cloud-init

    # copy custom.conf
    cp -f "$1"/settings/custom.conf ~/coreos-xhyve-ui

    # copy fleet units
    cp -R "$1"/fleet/ ~/coreos-xhyve-ui/fleet
    #

    # initial init
    open -a iTerm.app "$1"/first-init.command
