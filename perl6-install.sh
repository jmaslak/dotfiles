#!/bin/bash

#
# Copyright (C) 2018 Joelle Maslak
# All Rights Reserved - See License
#

doit() {
    echo " --->>  Switching to root directory"
    cd ~
    git clone https://github.com/tadzik/rakudobrew ~/.rakudobrew
    export PATH="~/.rakudobrew/bin:$PATH"
   
    echo " --->>  Building moar"
    rakudobrew build moar 2018.08

    echo " --->>  Switching active moar"
    rakudobrew switch moar-2018.08

    echo " --->>  Building zef"
    rakudobrew build zef
}

doit


