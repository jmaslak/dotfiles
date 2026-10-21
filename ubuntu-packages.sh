#!/bin/bash

#
# Copyright (C) 2018-2026 Joelle Maslak
# All Rights Reserved - See License
#

# Install some packages needed for other tasks (such as building Perl)

doit() {
    sudo apt-get update
    local PACKAGES=(
        bash-completion
        bc
        build-essential
        c3270  # console 3270 emulator
        cmake
        curl
        dnsutils
        entr  # Execute things when a file is modified
        ethtool
        expect
        fonts-3270  # 3270 terminal fonts
        fonts-noto
        git
        graphicsmagick
        imagemagick
        iputils-ping
        libbz2-dev
        libc-ares-dev
        libffi-dev
        libgdbm-compat-dev  # NDBM compat headers (Python dbm.ndbm)
        libgdbm-dev  # GNU dbm headers (Python dbm.gnu)
        libglib2.0-dev
        liblzma-dev
        libmpdec-dev  # Decimal arithmetic library (Python decimal)
        libncurses-dev
        libpodofo-utils
        libpq-dev
        libreadline-dev
        libsqlite3-dev
        libssl-dev
        libzstd-dev  # Zstandard compression headers (Python compression.zstd)
        liblzma-dev
        lzma
        man
        mupdf-tools
        ncal
        netcat-openbsd
        net-tools
        pkg-config  # Library detection used by Python's configure
        postgresql-common
        rsync
        shellcheck
        sqlite3
        tk-dev  # Tcl/Tk headers (Python tkinter)
        tmux
        traceroute
        unzip
        uuid-dev  # UUID library headers (Python uuid)
        vim
        virtualenv
        wget
        whois
        x3270  # X-windows 3270 terminal
        xfonts-x3270-misc  # x3270 fonts
        xterm
        zlib1g-dev
    )
    sudo apt-get install -y "${PACKAGES[@]}"
    sudo apt-get install -y \
        neovim
    sudo apt-get install -y docker.io
    sudo apt-get install -y ubuntu-release-upgrader-core
    sudo apt-get install -y libfindbin-libs-perl
    sudo apt-get install -y libusb-1.0-0.dev
    sudo apt-get install -y time
    sudo apt-get install -y python3-autopep8
    sudo apt-get install -y python3-venv tox
    sudo apt-get install -y rustc
    sudo apt-get install -y linux-firmware

    if [ "$DISPLAY" != "" ] ; then
        sudo apt-get install -y emacs-gtk
    fi

    # Install tmuxlayout
    curl -fsSL https://raw.githubusercontent.com/jmaslak/tmuxlayout/main/install.sh | sh
}

doit "$@"


