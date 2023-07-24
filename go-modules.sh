#!/bin/bash

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

doit() {
    go install golang.org/x/tools/cmd/goimports@latest
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
}

doit "$@"


