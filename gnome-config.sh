#!/bin/bash

#
# Copyright (C) 2019 Joelle Maslak
# All Rights Reserved - See License
#

# Disable auto-resizing of windows
gsettings set org.gnome.mutter edge-tiling false

BG_COLOR="#EEEEEECC99FF"
FG_COLOR="#444444444444"

if [ "$(which gconftool-2)" == "" ] ; then
    echo "Please install the gconf2 package" >&2
    exit 1
fi

gconftool-2 --set "/apps/gnome-terminal/profiles/Default/use_theme_background" --type bool false
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/use_theme_colors" --type bool false
# gconftool-2 --set "/apps/gnome-terminal/profiles/Default/palette" --type string "$PALETTE"
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/background_color" --type string "$BG_COLOR"
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/foreground_color" --type string "$FG_COLOR"
