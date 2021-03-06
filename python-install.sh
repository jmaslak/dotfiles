#!/bin/bash

#
# Copyright (C) 2020-2021 Joelle Maslak
# All Rights Reserved - See License
#

PYTHON36=3.6.12
PYTHON37=3.7.9
PYTHON38=3.8.7
PYTHON39=3.9.5

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

        cd "$HOME/.pyenv/" && git pull && cd -
    fi

    # Install pyenv-virtualenv
    if [ ! -d "$HOME/.pyenv/plugins/pyenv-virtualenv" ] ; then
        cd "$HOME/.pyenv/plugins"
        git clone git://github.com/yyuu/pyenv-virtualenv.git pyenv-virtualenv
    fi

    install $PYTHON36
    install $PYTHON37
    install $PYTHON38
    install $PYTHON39

    echo "Setting Python version to $PYTHON39"
    pyenv global "$PYTHON39"
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

