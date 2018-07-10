#!/bin/bash

#
# Copyright (C) 2016,2018 Joelle Maslak
# All Rights Reserved - See License
#

doit() {
    ZEF="$( which zef )"  # Workaround Solaris which that doesn't
                          # return a useful value (grrr!)
    if [ -x "$ZEF" ] ; then
        install_modules
    else
        echo ""
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "You should install Rakudo (Perl 6) and zef."
        echo ""
        echo "Use the perl6-install.sh script in this directory to do"
        echo "that."
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
    zef locate "$MODULE" 2>/dev/null >/dev/null
    if [ $? -ne 0 ] ; then
        zef install "$MODULE"
    else
        echo "$MODULE already installed."
    fi
}

doit


