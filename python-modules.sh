#!/bin/bash

#
# Copyright (C) 2015-2020 Joelle Maslak
# All Rights Reserved - See License
#

doit() {
    # Defensive umask
    if [ $(umask) == '0000' ] ; then
        umask 0002
    fi

    # Use pyenv if it's installed but we haven't re-logged in
    if [ -d "$HOME/.pyenv" ] ; then
        which pyenv >/dev/null 2>/dev/null
        if [ $? -ne 0 ] ; then
            # pyenv not in path.
            export PYENV_ROOT="$HOME/.pyenv"
            export PATH="$PYENV_ROOT/bin:$PATH"
            eval "$(pyenv init -)"
        fi
    fi

    which pip 2>/dev/null >/dev/null
    if [ $? -eq 0 ] ; then  # Installed
        pip install --upgrade pip
        pip install google-api-python-client
        pip install icecream
        pip install oauth2client
        pip install PyYAML
        pip install virtualenv
        pip install ansicolors
    else
        echo ""
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "You should install Python3/Pip."
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo ""
    fi
}

doit


