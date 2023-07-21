#!/bin/bash

#
# Copyright (C) 2023 Netflix
# All Rights Reserved - See License
#

doit() {
    docker run -d --name redis-stack-server -p 6379:6379 redis/redis-stack-server:latest
}

doit "$@"


