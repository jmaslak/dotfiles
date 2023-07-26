#!/bin/bash

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

doit() {
    dpkg-deb --build --root-owner-group root framework-tweaks_0.1-1_amd64.deb
}

doit "$@"


