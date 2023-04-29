#!/bin/bash

#
# Copyright (C) 2018-2023 Joelle Maslak
# All Rights Reserved - See License
#

CURRENTPERL=perl-5.36.0
PERLBREW_MAJOR=0
PERLBREW_MINOR=86

doit() {
    # Defensive umask
    if [ "$(umask)" == '0000' ] ; then
        umask 0002
    fi
    
    # Check for installation of curl
    if ! command -v curl >/dev/null ; then
        echo "" >&2
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
        echo "Please install curl first" >&2
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
        echo "" >&2

        exit 1
    fi


    if [ ! -d ~/perl5/perlbrew ] ; then
        echo " --->> Installing perlbrew"
        curl -L https://install.perlbrew.pl | bash
    fi
    
    # Source the bashrc
    # shellcheck source=/home/jmaslak/perl5/perlbrew/etc/bashrc
    . ~/perl5/perlbrew/etc/bashrc

    MAJOR=$(perlbrew --version | sed -e 's/.*\///' | sed -e 's/\..*//' )
    MINOR=$(perlbrew --version | sed -e 's/.*\/0\.//')
    if [ "$MAJOR" -lt "$PERLBREW_MAJOR" ] ; then
        echo " --->> Upgrading perlbrew"
        perlbrew self-upgrade
    elif [ "$MAJOR" -gt "$PERLBREW_MAJOR" ] ; then
        # We're new enough
        true
    elif [ "$MINOR" -lt "$PERLBREW_MINOR" ] ; then
        echo " --->> Upgrading perlbrew"
        perlbrew self-upgrade
    fi

    if [ ! -d ~/perl5/perlbrew/perls/$CURRENTPERL ] ; then
        echo " --->> Installing perl"
        perlbrew install --notest $CURRENTPERL -Accflags=-fPIC -j 8

        echo " --->> Activating perl"
        perlbrew switch $CURRENTPERL

        echo " !!!>> You will need to log out and back in to switch versions"
    fi

}

doit "$@"


