#!/bin/bash

#
# Copyright (C) 2024-2026 Joelle Maslak
# All Rights Reserved - See License
#

doit() {
    go install golang.org/x/tools/cmd/goimports@latest
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
    # go install github.com/go-delve/delve/cmd/dlv@latest
    go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest
    go install github.com/jmaslak/go-busy-indicator/cmd/...@latest
    go install github.com/jmaslak/go-task/cmd/task@latest
    go install github.com/rakyll/gotest@latest   # colorized gotest command
    go install github.com/palkan/mulint@latest  # mutex linter
    go install golang.org/x/vuln/cmd/govulncheck@latest  # Go vulnerability checker
    go install github.com/securego/gosec/v2/cmd/gosec@latest  # Go security scanner
    go install github.com/jmaslak/go-router-colorizer/cmd/router-colorizer@latest  # Router colorizer
    go install honnef.co/go/tools/cmd/staticcheck@latest
}

doit "$@"


