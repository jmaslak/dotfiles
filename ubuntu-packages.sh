#!/bin/bash

#
# Copyright (C) 2018-2023 Joelle Maslak
# All Rights Reserved - See License
#

# Install some packages needed for other tasks (such as building Perl)

doit() {
    sudo apt-get update
    # entr = Execute things when a file is modified
    sudo apt-get install -y \
        bash-completion \
        bc \
        build-essential \
        cmake \
        curl \
        dnsutils \
        entr \
        ethtool \
        fonts-noto \
        git \
        iputils-ping \
        libbz2-dev \
        libc-ares-dev \
        libffi-dev \
        libglib2.0-dev \
        liblzma-dev \
        libncurses-dev \
        libpq-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        liblzma-dev \
        lzma \
        man \
        ncal \
        netcat \
        net-tools \
        postgresql-common \
        rsync \
        sqlite3 \
        tmux \
        traceroute \
        unzip \
        vim \
        virtualenv \
        wget \
        whois \
        zlib1g-dev
    sudo apt-get install -y \
        neovim
    sudo apt-get install -y docker.io
    sudo apt-get install -y ubuntu-release-upgrader-core
    sudo apt-get install -y libfindbin-libs-perl
    sudo apt-get install -y libusb-1.0-0.dev
    sudo apt-get install -y time
    sudo apt-get install -y python3-autopep8
    sudo apt-get install -y python3-autopep8
    sudo apt-get install -y python3-venv tox
    sudo apt-get install -y rustc

    if [ "$DISPLAY" != "" ] ; then
        sudo apt-get install -y emacs-gtk
    fi
}

doit "$@"


