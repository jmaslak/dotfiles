#!/bin/bash

#
# Copyright (C) 2023-2024 Netflix
# All Rights Reserved - See License
#

doit() {
    ID=$(docker ps -f name=redis-stack-server --all --format '{{.ID}}')
    if [ "$ID" != "" ] ; then
        docker rm "$ID"
    fi
    docker run -d --name redis-stack-server -p 6379:6379 redis/redis-stack-server:latest
}

doit "$@"


