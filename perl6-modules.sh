#!/bin/bash

#
# Copyright (C) 2016,2018 Joelle Maslak
# All Rights Reserved - See License
#

doit() {
    which zef >/dev/null
    if [ $? -eq 0 ] ; then
        install_modules
    else
        echo ""
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "You should install Rakudo Star (Perl 6)."
        echo ""
        echo "Not installing Perl 6 modules."
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo ""
    fi
}

install_modules() {
    install_module App::Mi6
    install_module Net::Netmask
    install_module StrictNamedArguments
}

install_module() {
    MODULE="$1"
    zef list --installed | egrep "^$MODULE:" >/dev/null
    if [ $? -ne 0 ] ; then
        zef install $MODULE
    else
        echo "$MODULE already installed."
    fi
}

doit


