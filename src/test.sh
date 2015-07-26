#!/bin/bash

spin='-\|/'
i=0
until [ ! -e ~/coreos-xhyve-ui/.env/.console ] >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
