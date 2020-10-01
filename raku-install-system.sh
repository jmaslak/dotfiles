#!/bin/bash

#
# Copyright (C) 2020 Joelle Maslak
# All Rights Reserved - See License
#

if [ ! -f /etc/apt/sources.list.d/rakudo-pkg.list ] ; then
    echo "Installing Raku package"
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 379CE192D401AB61
    echo "deb https://dl.bintray.com/nxadm/rakudo-pkg-debs `lsb_release -cs` main" \
        | sudo tee -a /etc/apt/sources.list.d/rakudo-pkg.list
    sudo apt-get update && sudo apt-get install rakudo-pkg
else
    echo "Raku package already installed"
fi
