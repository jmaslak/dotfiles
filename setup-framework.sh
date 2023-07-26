#!/bin/bash

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

doit() {
    sudo dpkg -i $(ls src/framework-tweaks/framework-tweaks*.deb | tail -1)
    echo "You'll want to reboot to get your brightness buttons working!"
}

doit "$@"


