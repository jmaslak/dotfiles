#!/bin/bash

#
# Copyright (C) 2025 Joelle Maslak
# All Rights Reserved - See License
#

# Install some packages needed for other tasks (such as building Perl)

doit() {
    brew install bc
    brew install countdown  # Display countdown timer
    brew install entr       # Watch files for change and exec commands
    brew install lesspipe   # Handle piping of less from non-files
    brew install mtr
    brew install nmap
    brew install nodejs
    brew install protobuf
    brew install tmux
    brew install readline   # GNU Readline (used by Dist::Zilla!)
    brew install reattach-to-user-namespace   # Used so tmux can access clipboard
    brew install secretive  # Use hardware enclave for SSH key
    brew install shellcheck # Shell linter
    brew install tcl-tk
    brew install telnet
    brew install tmux
    brew install redis
    brew install watch
    brew install xz

    brew services start redis
}

doit "$@"

