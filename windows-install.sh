#!/bin/bash

#
# Copyright (C) 2016 Joel Maslak
# All Rights Reserved - See License
#
#
# This is intended to be run from Cygwin
# It installs vim defaults to _vim and _vimrc in the user's Windows
# home directory on Windows
#
# It also assumes that the user has already executed the Unix script
#

doit() {
    if [ "$(uname -o)" != 'Cygwin' ] ; then
        die_error "You do not appear to be executing this from Cygwin"
    fi

    if [ ! -f ~/.dotfiles.installed ] ; then
        die_error "You must install the Unix dotfiles first"
    fi

    if [ \( "$HOMEPATH" != "" \) -a \( "$HOMEPATH" != "\\" \) ] ; then
        CYGWINHOME=$(cygpath $HOMEPATH)
    elif [ "$USERPROFILE" != "" ] ; then
        CYGWINHOME=$(cygpath $USERPROFILE)
    fi
    if [ "$CYGWINHOME" == "" ] ; then
        die_error "Could not determine Windows home directory"
    fi

    echo "User Windows home dir: $CYGWINHOME"

    echo "Syncing .vim"
    rsync -av ~/.vim/ $CYGWINHOME/vimfiles/
    echo ""

    echo "Syncing .vimrc"
    cp ~/.vimrc $CYGWINHOME/_vimrc
    echo ""
}

die_error() {
    echo $* >&2
    exit 1
}

doit


