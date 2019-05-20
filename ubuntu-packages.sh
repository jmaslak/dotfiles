#!/bin/bash

#
# Copyright (C) 2018 Joelle Maslak
# All Rights Reserved - See License
#

# Install some packages needed for other tasks (such as building Perl)

doit() {
    sudo apt-get install \
        bc \
        build-essential \
        curl \
        emacs25-nox \
        iputils-ping \
        libbz2-dev \
        libffi-dev \
        libncurses-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        netcat \
        neovim \
        sqlite3 \
        tmux \
        traceroute \
        vim \
        whois \
        zlib1g-dev
}

doit "$@"


