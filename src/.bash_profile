#!/bin/bash
# ~/.bash_profile: executed by bash
# We just run .profile

if [ -e "$HOME/.profile" ] ; then
    # shellcheck source=/home/jmaslak/.profile
    . "$HOME/.profile"
fi
