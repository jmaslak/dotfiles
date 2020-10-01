#!/bin/bash

#
# Copyright (C) 2020 Joelle Maslak
# All Rights Reserved - See License
#

PYTHON2=2.7.18
PYTHON3=3.8.5

doit() {
    # Defensive umask
    if [ $(umask) == '0000' ] ; then
        umask 0002
    fi

    CWD=$(pwd)

    # Install pyenv
    if [ ! -d "$HOME/.pyenv" ] ; then
        cd "$HOME"
        git clone git://github.com/yyuu/pyenv.git .pyenv
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
    else
        which pyenv >/dev/null 2>/dev/null
        if [ $? -ne 0 ] ; then
            # pyenv not in path.
            export PYENV_ROOT="$HOME/.pyenv"
            export PATH="$PYENV_ROOT/bin:$PATH"
            eval "$(pyenv init -)"
        fi
    fi

    # Install pyenv-virtualenv
    if [ ! -d "$HOME/.pyenv/plugins/pyenv-virtualenv" ] ; then
        cd "$HOME/.pyenv/plugins"
        git clone git://github.com/yyuu/pyenv-virtualenv.git pyenv-virtualenv
    fi    

    install $PYTHON2
    install $PYTHON3

    echo "Setting Python version to $PYTHON3"    
    pyenv global "$PYTHON3"
    pyenv rehash

    cd "$CWD"
}

install() {
    PYVER="$1"

    PYVERREGEX=${PYVER//./\\.}

    # Install python
    pyenv versions 2>/dev/null | grep -P " $PYVERREGEX(\s.*)?$" >/dev/null
    if [ $? -ne 0 ] ; then
        PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install "$PYVER"
    fi
}

doit "$@"

