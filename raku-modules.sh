#!/bin/bash

#
# Copyright (C) 2016-2020 Joelle Maslak
# All Rights Reserved - See License
#

doit() {
    # Defensive umask
    if [ $(umask) == '0000' ] ; then
        umask 0002
    fi

    # Workaround Solaris which that doesn't return a useful value (grrr!)
    ZEF="$( which zef 2>/dev/null )"
    RAKU="$( which raku 2>/dev/null )"

    if [ -x "$ZEF" -a -x "$RAKU" ] ; then
        install_modules
    else
        echo ""
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "You should install Rakudo (Raku) and zef."
        echo ""
        echo "Use the raku-install.sh script in this directory to do"
        echo "that."
        echo ""
        echo "Not installing Perl 6 modules."
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo ""
    fi
}

install_modules() {
    install_module_force LWP::Simple    # Does network tests

    install_module App::Mi6
    install_module DateTime::Monotonic
    install_module Digest::SHA1::Native
    install_module Linenoise            # For REPL
    install_module IO::Socket::SSL      # p6doc ends up failing without this
    install_module NativeHelpers::Blob
    install_module Net::Netmask
    install_module OO::Monitors
    install_module P5getpriority        # For getppid
    install_module P5localtime
    install_module StrictClass
    # install_module StrictNamedArguments # Doesn't work in 6.d
    install_module Sys::Domainname
    install_module TCP::LowLevel
    install_module Terminal::ANSIColor
    install_module Term::ReadKey
    install_module Term::termios
    install_module YAMLish
    install_module if
    install_module p6doc
}

install_module_force() {
    MODULE="$1"
    zef locate "$MODULE" 2>/dev/null >/dev/null
    if [ $? -ne 0 ] ; then
        zef install --force-test "$MODULE"
    else
        echo "$MODULE already installed."
    fi
}

install_module() {
    MODULE="$1"
    zef locate "$MODULE" 2>/dev/null >/dev/null
    if [ $? -ne 0 ] ; then
        zef install "$MODULE"
    else
        echo "$MODULE already installed."
    fi
}

doit


