#!/bin/bash

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

doit() {
    # Defensive umask
    if [ "$(umask)" == '0000' ] ; then
        umask 0002
    fi

    sudo dnf -y groupinstall 'Development Tools'
    sudo dnf -y install libcap-devel
    sudo dnf -y install libX11-devel
    sudo dnf -y install mysql-devel
    sudo dnf -y install openssl-devel
    sudo dnf -y install postgresql-devel
    sudo dnf -y install readline-devel
    sudo dnf -y install perl-File-Copy
    sudo dnf -y install perl-Net-Ping
}

doit


