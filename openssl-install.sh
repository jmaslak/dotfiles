#!/bin/bash

#
# Copyright (C) 2019-2023 Joelle Maslak
# All Rights Reserved - See License
#

OPENSSL=openssl-1.1.1b

if [ ! -e ${OPENSSL}.tar.gz ] ; then
    echo "Downloading OpenSSL"
    curl https://www.openssl.org/source/${OPENSSL}.tar.gz >${OPENSSL}.tar.gz
else
    echo "Skipping download, OpenSSL tarball already exists"
fi

if [ ! -e ${OPENSSL} ] ; then
    echo "Expanding tarball"
    tar -xzvf ${OPENSSL}.tar.gz >/dev/null
else
    echo "Skipping expanding tarball, already expanded"
fi

cd ${OPENSSL} || echo >/dev/null # satisfy shellcheck
./config --prefix="$HOME/openssl" --openssldir="$HOME/openssl" no-ssl2 && \
    make && \
    make test && \
    make install

