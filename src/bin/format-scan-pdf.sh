#!/bin/bash

#
# Copyright (C) 2023-2025 Joelle Maslak
# All Rights Reserved - See License
#

set -e

if [ \! -d ~/pdf ] ; then
    mkdir ~/pdf
fi

SRC="$1"
DST="$2"
if DST="" ; then
    DST="$1"
fi
cp "$SRC" ~/pdf/in.$$.pdf
docker run -it --user $(id -u):$(id -g) -v ~/pdf:/usr/pdf jmaslak/format-scan-pdf in.$$.pdf out.$$.pdf
cp ~/pdf/out.$$.pdf "$DST"

