#!/bin/bash

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

GOLANGVER=1.20.6
GOARCH=linux-amd64

URL="https://go.dev/dl/go$GOLANGVER.$GOARCH.tar.gz"
echo $URL

doit() {
    # Defensive umask
    if [ "$(umask)" == '0000' ] ; then
        umask 0002
    fi

    CWD=$(pwd)
    cd $(HOME)
    if [ -d go ] ; then
        chmod -r a+w go
        rm -rf go
    fi
    mkdir go

    curl -L https://go.dev/dl/go1.20.6.linux-amd64.tar.gz | tar -xvzf -

    cd "$CWD" || echo >/dev/null

    ./go-modules.sh
}

doit "$@"

