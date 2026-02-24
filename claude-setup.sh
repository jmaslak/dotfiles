#!/bin/bash

#
# Copyright (C) 2026 Joelle Maslak
# All Rights Reserved - See License
#

install_plugin() {
    plugin="$1"

    if ! claude plugin list | grep -q "$plugin" ; then
        claude plugin install "$plugin"
    fi
}

doit() {
    if ! command -v claude >/dev/null 2>&1 ] ; then
        echo "claude not installed" >&2
        exit 1
    fi
    if ! claude plugin marketplace list | grep -q joelle-plugins ; then
        claude plugin marketplace add ./claude/marketplace
    fi

    install_plugin "idiom-check@joelle-plugins"
}

doit "$@"
