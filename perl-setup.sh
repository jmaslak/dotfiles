#!/bin/bash

#
# Copyright (C) 2015-2018 Joelle Maslak
# All Rights Reserved - See License
#

doit() {
    # Defensive umask
    if [ $(umask) == '0000' ] ; then
        umask 0002
    fi

    if [ "$PERLBREW_HOME" == "" ] ; then
        echo "" >&2
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
        echo "You should install Perlbrew." >&2
        echo "" >&2
        echo "The perl templates will not function properly otherwise." >&2
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
        echo "" >&2

        exit 1
    fi

    # Check for use of Perlbrew
    which perl 2>/dev/null | grep perlbrew 2>/dev/null >/dev/null
    if [ $? -ne 0 ] ; then
        echo "" >&2
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
        echo "You should use a Perlbrew perl (perlbrew switch)." >&2
        echo "" >&2
        echo "The perl templates will not function properly otherwise." >&2
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
        echo "" >&2

        exit 2
    fi

    cpan install App::ack
    cpan install App::ccdiff
    cpan install App::RouterColorizer
    cpan install CPAN
    cpan install JTM::Boilerplate
}

doit
