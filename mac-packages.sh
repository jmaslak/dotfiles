#!/bin/bash

#
# Copyright (C) 2025 Joelle Maslak
# All Rights Reserved - See License
#

# Install some packages needed for other tasks (such as building Perl)

brewinstall() {
    mod="$1"

    if ! brew list --versions "$mod" >/dev/null 2>&1 ; then
        brew install "$mod"
    fi
}

doit() {
    brewinstall bc
    brewinstall countdown  # Display countdown timer
    brewinstall entr       # Watch files for change and exec commands
    brewinstall lesspipe   # Handle piping of less from non-files
    brewinstall mtr
    brewinstall nmap
    brewinstall nodejs
    brewinstall protobuf
    brewinstall tmux
    brewinstall readline   # GNU Readline (used by Dist::Zilla!)
    brewinstall reattach-to-user-namespace   # Used so tmux can access clipboard
    brewinstall secretive  # Use hardware enclave for SSH key
    brewinstall shellcheck # Shell linter
    brewinstall tcl-tk
    brewinstall telnet
    brewinstall tmux
    brewinstall redis
    brewinstall watch
    brewinstall xz

    brew services start redis >/dev/null
}

doit "$@"

