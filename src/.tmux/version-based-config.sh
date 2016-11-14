#!/bin/bash

#
# Based on
# https://gist.github.com/vincenthsu/6847a8f2a94e61735034e65d17ca0d66
#

load_tmux_conf() {
    tmux_home=~/.tmux
    tmux_version="$(tmux -V | awk '{print $2}')"
    tmux_major=$(echo $tmux_version | cut -d. -f1)
    tmux_minor=$(echo $tmux_version | cut -d. -f2)

    if (( $tmux_major < 2 )) ; then
        tmux source-file "$tmux_home/tmux_pre_2_2.conf"
    elif (( $tmux_minor >= 2 )) ; then
        tmux source-file "$tmux_home/tmux_2_2.conf"
    elif (( $tmux_major > 2 )) ; then
        tmux source-file "$tmux_home/tmux_2_2.conf"
    else
        # 2.x < 2.2
        tmux source-file "$tmux_home/tmux_pre_2_2.conf"
    fi

    tmux source-file "$tmux_home/tmux_all.conf"
}

load_tmux_conf


