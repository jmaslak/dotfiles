#!/bin/bash

#
# Copyright (C) 2016-2023 Joelle Maslak
# All Rights Reserved - See License
#

doit() {
    # Defensive umask
    if [ "$(umask)" == '0000' ] ; then
        umask 0002
    fi

    yum -y groupinstall 'Development Tools'
    yum -y install libcap-devel
    yum -y install libX11-devel
    yum -y install mysql-devel
    yum -y install openssl-devel
    yum -y install postgresql-devel
    yum -y install readline-devel

    ### REDHAT 5:
    wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-5.noarch.rpm
    rpm --install epel-release-latest-5.noarch.rpm
    rm epel-release-latest-5.noarch.rpm
    yum update
    yum -y install git
}

doit


