#!/bin/bash

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

doit() {
    flatpak run net.sapples.LiveCaptions
}

doit "$@"


