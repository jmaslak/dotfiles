#!/bin/bash

#
# Copyright (C) 2016 Joel C. Maslak
# All Rights Reserved - See License
#

doit() {
    which panda >/dev/null
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
    install_module StrictNamedArguments
}

install_module() {
    MODULE="$1"
    panda --installed list | egrep "^$MODULE " >/dev/null
    if [ $? -ne 0 ] ; then
        panda install $MODULE
    else
        echo "$MODULE already installed."
    fi
}

doit


