#!/bin/sh
set -evu

if [ -z $1 ]; then
  echo "USAGE: $0 ip"
  exit 1
fi

# set the ip
ip=$1

# replace the hostname in the deploy.conf with the ip
sed -i .bak "s/^host .*/host $ip/" deploy.conf

# setup the deploy with the ip address
./deploy nko setup

# undo the ip address replacement
mv deploy.conf.bak deploy.conf
