#!/bin/bash

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

doit() {
    go install golang.org/x/tools/cmd/goimports@latest
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
}

doit "$@"


