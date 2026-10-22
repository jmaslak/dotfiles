#!/bin/bash

#
# Copyright (C) 2025-2026 Joelle Maslak
# All Rights Reserved - See License
#

# Install some packages needed for other tasks (such as building Perl)

brewinstall() {
    mod="$1"

    if brew list --versions "$mod" >/dev/null 2>&1 ; then
        echo "$mod already installed"
    else
        brew install -y "$mod"
    fi
}

doit() {
    brewinstall bat        # Alternative to cat
    brewinstall bc
    brewinstall clisp      # Common lisp
    brewinstall countdown  # Display countdown timer
    brewinstall entr       # Watch files for change and exec commands
    brewinstall gdb
    brewinstall graphviz
    brewinstall lesspipe   # Handle piping of less from non-files
    brewinstall librdkafka # Add kafka library
    brewinstall mtr
    brewinstall nmap
    brewinstall nodejs
    brewinstall pngquant   # Quantize (go to 8 bit color depth) PNGs
    brewinstall protobuf
    brewinstall pv         # Pipe Viewer to see throughput
    brewinstall rg         # Ripgrep
    brewinstall tmux
    brewinstall readline   # GNU Readline (used by Dist::Zilla!)
    brewinstall reattach-to-user-namespace   # Used so tmux can access clipboard
    brewinstall rlwrap     # Readline wrapper
    brewinstall roswell    # Roswell (LISP implementation manager)
    brewinstall sbcl       # Another common lisp
    brewinstall secretive  # Use hardware enclave for SSH key
    brewinstall shellcheck # Shell linter
    brewinstall starship   # Shell prompt
    brewinstall tcl-tk
    brewinstall inetutils  # telnet, rsh, etc.
    brewinstall tmux
    brewinstall redis
    brewinstall watch
    brewinstall wget
    brewinstall x3270      # X windows 3270 server
    brewinstall xterm      # Xterm
    brewinstall xz

    brew install --cask xquartz  # OSX X server
    brew install --cask font-3270  # X 3270 fonts

    brew services start redis >/dev/null

    # Init roswell
    if [ ! -d ~/.roswell ] ; then
        ros init
        ros install sbcl
        ros use sbcl
    fi

    # Install tmuxlayout
    curl -fsSL https://raw.githubusercontent.com/jmaslak/tmuxlayout/main/install.sh | sh

    # X3270 font
    if [ ! -d ~/.fonts/3270 ]; then
        mkdir -p ~/.fonts/3270
        cp /Users/jmaslak/git/third-party/suite3270-4.6/obj/arm-apple-darwin27.0.0/x3270/3270gt32.pcf.gz ~/.fonts/3270/
        /opt/X11/bin/mkfontdir ~/.fonts/3270
        /opt/X11/bin/xset +fp ~/.fonts/3270
        /opt/X11/bin/xset fp rehash
        /opt/X11/bin/xset q | grep -A1 'Font Path'   # confirm it's listed
    fi
}

doit "$@"

