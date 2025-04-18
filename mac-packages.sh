#!/bin/bash

#
# Copyright (C) 2025 Joelle Maslak
# All Rights Reserved - See License
#

# Install some packages needed for other tasks (such as building Perl)

doit() {
    brew install entr       # Watch files for change and exec commands
    brew install lesspipe   # Handle piping of less from non-files
    brew install tmux
    brew install readline   # GNU Readline (used by Dist::Zilla!)
    brew install reattach-to-user-namespace   # Used so tmux can access clipboard
    brew install watch
    brew install xz
}

foo() {
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
        expect \
        fonts-noto \
        git \
        graphicsmagick \
        imagemagick \
        iputils-ping \
        libbz2-dev \
        libc-ares-dev \
        libffi-dev \
        libglib2.0-dev \
        liblzma-dev \
        libncurses-dev \
        libpodofo-utils \
        libpq-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        liblzma-dev \
        lzma \
        man \
        mupdf-tools \
        ncal \
        netcat \
        net-tools \
        postgresql-common \
        rsync \
        shellcheck \
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
    sudo apt-get install -y linux-firmware

    if [ "$DISPLAY" != "" ] ; then
        sudo apt-get install -y emacs-gtk
    fi
}

doit "$@"


