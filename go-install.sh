#!/bin/bash

#
# Copyright (C) 2024-2025 Joelle Maslak
# All Rights Reserved - See License
#

set -euo pipefail

GOLANGVER=1.25.4
BASEURL="https://go.dev/dl/"

doit() {
    macharch=$(uname -om)
    case "$macharch" in
        "Darwin arm64")
            goarch="darwin-arm64"
            ;;
        "x86_64 GNU/Linux")
            goarch="linux-amd64"
            ;;
        *)
            echo "Cannot determine go arch for $macharch" >&2
            exit 1
            ;;
    esac

    echo "Go architecture: $goarch"

    URL="https://go.dev/dl/go$GOLANGVER.$goarch.tar.gz"
    tmpfile=$(mktemp /tmp/go-download.tgz.XXXXXX)
    curl -L https://go.dev/dl/go{$GOLANGVER}.${goarch}.tar.gz >$tmpfile

    echo "Downloaded!"
    echo ""
    echo "You may be asked to provide your password to install golang:"

    sudo tar -xvzf $tmpfile --cd /usr/local
    rm $tmpfile

    # shellcheck disable=SC2155
    export GOROOT="/usr/local/go"
    # shellcheck disable=SC2155
    export PATH="$HOME/go/bin:$(pwd)/go/bin:$PATH"

    ./go-modules.sh
}

doit "$@"
