#!/usr/bin/env bash

#
# Copyright (C) 2015-2024 Joelle Maslak
# All Rights Reserved - See License
#

doit() {
    # Defensive umask
    if [ "$(umask)" == '0000' ] ; then
        umask 0002
    fi

    # Use pyenv if it's installed but we haven't re-logged in
    if [ -d "$HOME/.pyenv" ] ; then
        if ! command -v pyenv >/dev/null ; then
            # pyenv not in path.
            export PYENV_ROOT="$HOME/.pyenv"
            export PATH="$PYENV_ROOT/bin:$PATH"
            eval "$(pyenv init -)"
        fi
    fi

    if command -v pip 2>/dev/null ; then  # Installed
        pip install --upgrade pip
        pip install -r requirements.txt
    else
        echo ""
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "You should install Python3/Pip."
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo ""
    fi
}

doit


