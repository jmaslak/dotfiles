#!/bin/bash

#
# Copyright (C) 2024-2026 Joelle Maslak
# All Rights Reserved - See License
#

set -euo pipefail

GOLANGVER=1.26.0
BASEURL="https://go.dev/dl"

doit() {
    if [ -x /usr/local/go/bin/go ] ; then
        ver=$(/usr/local/go/bin/go version | awk '{print $3}')
        if [ "$ver" == "go$GOLANGVER" ] ; then
            echo "/usr/local/go/bin/go is up-to-date"
            return
        else
            echo "/usr/local/go/bin/go is out-of-date ($ver), updating..."
        fi
    fi

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

    url="$BASEURL/go$GOLANGVER.$goarch.tar.gz"
    tmpfile=$(mktemp /tmp/go-download.tgz.XXXXXX)
    curl -L "$url" >"$tmpfile"

    echo "Downloaded!"
    echo ""
    echo "You may be asked to provide your password to install golang:"

    if [ -d /usr/local/go ] ; then
        sudo rm -rf /usr/local/go
    fi
    sudo tar -xvzf "$tmpfile" --cd /usr/local
    rm "$tmpfile"

    # shellcheck disable=SC2155
    export GOROOT="/usr/local/go"
    # shellcheck disable=SC2155
    export PATH="$HOME/go/bin:$(pwd)/go/bin:$PATH"

    ./go-modules.sh
}

doit "$@"
