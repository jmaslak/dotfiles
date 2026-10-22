#!/usr/bin/env bash

#
# Copyright (C) 2020-2026 Joelle Maslak
# All Rights Reserved - See License
#

PYTHON313=3.13.16
PYTHON314=3.14.8
PYTHON315=3.15.0

PREFERRED="$PYTHON314"

doit() {
    # Defensive umask
    if [ "$(umask)" == '0000' ] ; then
        umask 0002
    fi

    CWD=$(pwd)

    # Install pyenv
    if [ ! -d "$HOME/.pyenv" ] ; then
        cd "$HOME" || echo >/dev/null
        git clone https://github.com/yyuu/pyenv.git .pyenv
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
    else
        if ! command -v pyenv >/dev/null ; then
            # pyenv not in path.
            export PYENV_ROOT="$HOME/.pyenv"
            export PATH="$PYENV_ROOT/bin:$PATH"
            eval "$(pyenv init -)"
        fi

        cd "$HOME/.pyenv/" && git pull && cd - || echo >/dev/null
    fi

    # Install pyenv-virtualenv
    if [ ! -d "$HOME/.pyenv/plugins/pyenv-virtualenv" ] ; then
        cd "$HOME/.pyenv/plugins" || echo >/dev/null
        git clone https://github.com/yyuu/pyenv-virtualenv.git pyenv-virtualenv
    fi

    install $PYTHON313
    install $PYTHON314
    install $PYTHON315

    echo "Setting Python version to $PREFERRED"
    pyenv global "$PREFERRED"
    pyenv rehash

    cd "$CWD" || echo >/dev/null
}

install() {
    PYVER="$1"
    PYVERREGEX=${PYVER//./\\.}

    # Install python
    if ! pyenv versions 2>/dev/null | egrep " $PYVERREGEX(\s.*)?$" >/dev/null ; then
        PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install "$PYVER"
    fi
}

uninstall() {
    PYVER="$1"
    PYVERREGEX=${PYVER//./\\.}

    if pyenv versions 2>/dev/null | egrep " $PYVERREGEX(\s.)?$" >/dev/null ; then
        pyenv uninstall "$PYVER"
    fi
}

doit "$@"

