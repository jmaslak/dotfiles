#!/bin/bash

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

# Specify PERLVER if you want to override.  For instance, you can do
# something like:
#   ./perl6-install.sh blead
#
if [ "$PERLVER" = "" ] ; then
    PERLVER=2019.07.1
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
    rakudobrew build moar $PERLVER

    echo " --->>  Switching active moar"
    rakudobrew switch moar-$PERLVER

    echo " --->>  Building zef"
    rakudobrew build zef
}

doit


