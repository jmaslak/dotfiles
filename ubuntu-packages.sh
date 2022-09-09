#!/bin/bash

#
# Copyright (C) 2018-2022 Joelle Maslak
# All Rights Reserved - See License
#

# Install some packages needed for other tasks (such as building Perl)

doit() {
    sudo apt-get update
    sudo apt-get install -y \
        bash-completion \
        bc \
        build-essential \
        cmake \
        curl \
        dnsutils \
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
        neovim \
        emacs25-nox
    sudo apt-get install -y docker.io
    sudo apt-get install -y ubuntu-release-upgrader-core
    sudo apt-get install -y libfindbin-libs-perl
    sudo apt-get install -y time
    sudo apt-get install -y python-autopep8
    sudo apt-get install -y python3-autopep8
    sudo apt-get install -y python3-venv tox
    sudo apt-get install -y rustc
}

doit "$@"


