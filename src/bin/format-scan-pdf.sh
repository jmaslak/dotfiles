#!/bin/bash

#
# Copyright (C) 2023-2024 Joelle Maslak
# All Rights Reserved - See License
#

set -e

if [ \! -d ~/pdf ] ; then
    mkdir ~/pdf
fi

SRC="$1"
DST="$2"
cp "$SRC" ~/pdf/in.$$.pdf
docker run -it --user $(id -u):$(id -g) -v ~/pdf:/usr/pdf jmaslak/format-scan-pdf in.$$.pdf out.$$.pdf
cp ~/pdf/out.$$.pdf "$DST"

