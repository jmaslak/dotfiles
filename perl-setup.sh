#!/bin/bash

#
# Copyright (C) 2015 Joel C. Maslak
# All Rights Reserved - See License
#

doit() {
    if [ "$PERLBREW_HOME" != "" ] ; then
        cd JCM-Boilerplate

        DIR=$( ls -Fd JCM-Boilerplate-* | grep / | sort | tail -1 )
        cd "$DIR"
        if [ $? -ne 0 ] ; then
            echo "SORRY, COULDN'T PROCEED."
            exit 1;
        fi
        cpan install CPAN
        cpan .
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


