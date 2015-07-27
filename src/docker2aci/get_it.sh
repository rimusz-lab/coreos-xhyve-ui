#!/bin/bash

# get go binary of docker2aci

rm -f ~/golang/bin/docker2aci
go get github.com/appc/docker2aci
cp -f ~/golang/bin/docker2aci ../files
