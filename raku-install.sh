#!/bin/bash

#
# Copyright © 2018-2020 Joelle Maslak
# All Rights Reserved - See License
#

# Specify RAKUVER if you want to override.  For instance, you can do
# something like:
#   ./raku-install.sh blead
#
if [ "$RAKUVER" = "" ] ; then
    RAKUVER=2020.01
fi

doit() {
    # Defensive umask
    if [ $(umask) == '0000' ] ; then
        umask 0002
    fi

    echo " --->>  Switching to root directory"
    cd ~
    if [ ! -d .rakudobrew ] ; then
        git clone https://github.com/tadzik/rakudobrew ~/.rakudobrew
    fi

    cd .rakudobrew
    git pull
    cd ..

    export PATH="~/.rakudobrew/bin:$PATH"
    eval "$(~/.rakudobrew/bin/rakudobrew init Bash)"
   
    echo " --->>  Building moar"
    rakudobrew build moar $RAKUVER

    if [ "$SKIPSWITCH" == "" ] ; then
        echo " --->>  Switching active moar"
        rakudobrew switch moar-$RAKUVER
    fi

    echo " --->>  Building zef"
    rakudobrew build zef
}

doit


