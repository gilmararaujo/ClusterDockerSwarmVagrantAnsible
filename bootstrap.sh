#!/bin/bash
if [ -f /etc/debian_version ]; then
  codename="$(lsb_release -c | awk {'print $2}')"
  if [[ $codename == "xenial" ]]; then
    sudo apt-get update && \
    sudo apt-get -y install python-simplejson
  fi
fi
