#!/usr/bin/env bash

#
# Copyright (C) 2016-2024 Joelle Maslak
# All Rights Reserved - See License
#

doit() {
    # Defensive umask
    if [ "$(umask)" == '0000' ] ; then
        umask 0002
    fi

    # Workaround Solaris which that doesn't return a useful value (grrr!)
    ZEF="$( command -v zef )"
    RAKU="$( command -v raku )"

    if [ -x "$ZEF" ] && [ -x "$RAKU" ] ; then
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
    install_module App::Heater
    install_module App::Tasks
    install_module BusyIndicator
    install_module cro Cro
    install_module DateTime::Monotonic
    install_module Digest::SHA1::Native
    install_module JSON::Fast
    install_module Linenoise            # For REPL
    install_module IO::Socket::SSL      # p6doc ends up failing without this
    install_module NativeHelpers::Blob
    install_module Net::Netmask
    install_module OO::Monitors
    install_module P5getpriority        # For getppid
    install_module_force P5localtime
    install_module StrictClass
    # install_module StrictNamedArguments # Doesn't work in 6.d
    install_module Sys::Domainname
    install_module TCP::LowLevel
    install_module Terminal::ANSIColor
    install_module Term::ReadKey
    install_module Term::termios
    install_module YAMLish
    install_module if
    install_module rakudoc Pod::Cache
}

install_module_force() {
    MODULE="$1"
    if [ "$MODULE_NAME" == "" ] ; then
        MODULE_NAME="$MODULE"
    fi

    if ! raku -M "$MODULE_NAME" -e exit 2>/dev/null >/dev/null ; then
        zef install --force-test "$MODULE"
    else
        echo "$MODULE already installed."
    fi
}

install_module() {
    MODULE="$1"
    MODULE_NAME="$2"
    if [ "$MODULE_NAME" == "" ] ; then
        MODULE_NAME="$MODULE"
    fi

    if ! raku -M "$MODULE_NAME" -e exit 2>/dev/null >/dev/null ; then
        zef install "$MODULE"
    else
        echo "$MODULE already installed."
    fi
}

doit

