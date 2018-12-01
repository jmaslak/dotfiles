#!/bin/bash

#
# Copyright © 2018 Joelle Maslak
# All Rights Reserved - See License
#

PERLVER=2018.11

doit() {
    echo " --->>  Switching to root directory"
    cd ~
    git clone https://github.com/tadzik/rakudobrew ~/.rakudobrew
    export PATH="~/.rakudobrew/bin:$PATH"
   
    echo " --->>  Building moar"
    rakudobrew build moar $PERLVER

    echo " --->>  Switching active moar"
    rakudobrew switch moar-$PERLVER

    echo " --->>  Building zef"
    rakudobrew build zef
}

doit


