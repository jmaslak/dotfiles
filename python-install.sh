#!/bin/bash

#
# Copyright (C) 2019 Joelle Maslak
# All Rights Reserved - See License
#

PYVER=3.7.2

pkginstall() {
    dpkg -l "$1" >/dev/null 2>/dev/null
    if [ $? -ne 0 ] ; then
        echo "Package $1 not found.  Installing with root privileges."
        sudo apt-get install -y "$1"
    fi
}

doit() {
    # Defensive umask
    if [ $(umask) == '0000' ] ; then
        umask 0002
    fi

    CWD=$(pwd)

    # Install packages
    which apt-get 2>/dev/null >/dev/null
    if [ $? -eq 0 ] ; then
        pkginstall zlib1g-dev
        pkginstall libffi-dev
        pkginstall libbz2-dev
        pkginstall libreadline-dev
        pkginstall libsqlite3-dev
    fi

    # Install pyenv
    if [ ! -d "$HOME/.pyenv" ] ; then
        cd "$HOME"
        git clone git://github.com/yyuu/pyenv.git .pyenv
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT:$PATH"
        eval "$(pyenv init -)"
    fi

    # Install python
    pyenv versions 2>/dev/null | grep " $PYVER " >/dev/null
    if [ $? -ne 0 ] ; then
        PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install "$PYVER"
        pyenv global "$PYVER"
        pyenv rehash
    fi

    cd "$CWD"
}

doit "$@"


