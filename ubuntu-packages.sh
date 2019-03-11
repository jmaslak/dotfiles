#!/bin/bash

#
# Copyright (C) 2018 Joelle Maslak
# All Rights Reserved - See License
#

# Install some packages needed for other tasks (such as building Perl)

doit() {
    sudo apt-get install build-essential libssl-dev curl tmux vim
}

doit "$@"


