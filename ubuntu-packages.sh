#!/bin/bash

#
# Copyright (C) 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

# Install some packages needed for other tasks (such as building Perl)

doit() {
    sudo apt-get update
    sudo apt-get install \
        bash-completion \
        bc \
        build-essential \
        curl \
        dnsutils \
        git \
        iputils-ping \
        libbz2-dev \
        libffi-dev \
        libncurses-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        man \
        netcat \
        net-tools \
        python-autopep8 \
        rsync \
        sqlite3 \
        tmux \
        traceroute \
        vim \
        virtualenv \
        wget \
        whois \
        zlib1g-dev
    sudo apt-get install \
        neovim \
        emacs25-nox
    sudo apt-get install docker.io
    sudo apt-get install ubuntu-release-upgrader-core
}

doit "$@"


