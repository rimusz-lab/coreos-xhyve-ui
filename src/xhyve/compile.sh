#!/bin/bash

# compile xhyve from source

git clone https://github.com/mist64/xhyve
cd xhyve
make
cp -f build/xhyve ../xhyve/bin
cd ..
rm -rf xhyve
../bin/xhyve -v
