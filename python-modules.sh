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

    which pip3 2>/dev/null >/dev/null
    if [ $? -eq 0 ] ; then  # Installed
        pip3 install google-api-python-client
        pip3 install oauth2client
    else
        echo ""
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "You should install Python3/Pip."
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo ""
    fi
}

doit


