#!/bin/bash

#
# Copyright (C) 2015-2018 Joelle Maslak
# All Rights Reserved - See License
#

doit() {
    if [ "$PERLBREW_HOME" != "" ] ; then
        cpan install App::ccdiff
        cpan install CPAN
        cpan install JTM::Boilerplate
    else
        echo ""
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "You should install Perlbrew."
        echo ""
        echo "The perl templates will not function properly otherwise."
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo ""
    fi
}

doit


