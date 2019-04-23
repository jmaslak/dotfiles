#!/bin/bash

#
# Copyright (C) 2015-2019 Joelle Maslak
# All Rights Reserved - See License
#

doit() {
    # Defensive umask
    if [ $(umask) == '0000' ] ; then
        umask 0002
    fi

    which pip 2>/dev/null >/dev/null
    if [ $? -eq 0 ] ; then  # Installed
        pip install --upgrade pip
        pip install google-api-python-client
        pip install oauth2client
        pip install PyYAML
        pip install virtualenv
    else
        echo ""
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "You should install Python3/Pip."
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo ""
    fi
}

doit


