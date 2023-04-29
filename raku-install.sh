#!/bin/bash

#
# Copyright © 2018-2023 Joelle Maslak
# All Rights Reserved - See License
#

# Specify RAKUVER if you want to override.  For instance, you can do
# something like:
#   ./raku-install.sh blead
#
if [ "$RAKUVER" = "" ] ; then
    RAKUVER=2022.12
fi

doit() {
    # Defensive umask
    if [ "$(umask)" == '0000' ] ; then
        umask 0002
    fi

    echo " --->>  Switching to root directory"
    cd ~ || echo >/dev/null
    if [ ! -d .rakubrew ] ; then
        mkdir .rakubrew
        cd .rakubrew || echo >/dev/null
        # This works for Linux.  For MacOS replace "perl" with "macos"
        curl https://rakubrew.org/perl/rakubrew >rakubrew
        chmod a+x rakubrew
        cd .. || echo >/dev/null
    fi

    export PATH="$HOME/.rakubrew:$PATH"
    eval "$(~/.rakubrew/rakubrew init Bash)"
   
    echo " --->>  Building moar"
    rakubrew build $RAKUVER

    if [ "$SKIPSWITCH" == "" ] ; then
        echo " --->>  Switching active moar"
        rakubrew switch moar-$RAKUVER
    fi

    echo " --->>  Building zef"
    rakubrew build zef
}

doit


