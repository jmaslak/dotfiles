#!/bin/bash

#
# Copyright (C) 2022 Joelle Maslak
# All Rights Reserved - See License
#

/usr/bin/hostname -I | /usr/bin/grep -Eqv '(^| )192\.168\.15[07]\.'

