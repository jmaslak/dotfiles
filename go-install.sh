#!/bin/bash

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

GOLANGVER=1.21.0
GOARCH=linux-amd64

URL="https://go.dev/dl/go$GOLANGVER.$GOARCH.tar.gz"
echo $URL

doit() {
    # Defensive umask
    if [ "$(umask)" == '0000' ] ; then
        umask 0002
    fi

    CWD=$(pwd)
    cd "$HOME" || exit
    if [ ! -d .go ] ; then
        mkdir .go
    fi
    cd .go || exit
    if [ -d go ] ; then
        chmod -R u+w go
        rm -rf go
    fi

    curl -L https://go.dev/dl/go{$GOLANGVER}.linux-amd64.tar.gz | tar -xvzf -

    # shellcheck disable=SC2155
    export GOROOT="$(pwd)/go"
    # shellcheck disable=SC2155
    export PATH="$(pwd)/go/bin:$PATH"

    cd "$CWD" || echo >/dev/null

    ./go-modules.sh
}

doit "$@"
