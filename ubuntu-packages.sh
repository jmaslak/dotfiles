#!/bin/bash

#
# Copyright (C) 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

# Install some packages needed for other tasks (such as building Perl)

doit() {
    sudo apt-get update
    sudo apt-get install \
        bc \
        build-essential \
        curl \
        docker.io \
        git \
        iputils-ping \
        libbz2-dev \
        libffi-dev \
        libncurses-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        netcat \
        rsync \
        sqlite3 \
        tmux \
        traceroute \
        ubuntu-release-upgrader-core \
        vim \
        whois \
        zlib1g-dev
    sudo apt-get install \
        neovim \
        emacs25-nox
}

doit "$@"


