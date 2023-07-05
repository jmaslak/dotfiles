#!/bin/bash

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

if [ \! -d ~/pdf ] ; then
    echo "You must create a ~/pdf directory and put your input file there." >&2
    exit 1
fi
docker run -it --user $(id -u):$(id -g) -v ~/pdf:/usr/pdf jmaslak/format-scan-pdf "$@"


