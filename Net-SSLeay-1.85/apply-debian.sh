#!/bin/bash

#
# Copyright (C) 2019 Joelle Maslak
# All Rights Reserved - See License
#

patch --strip 1 <Adapt-to-OpenSSL-1.1.1.patch
# patch --strip 1 <Adapt-CTX_get_min_proto_version-tests-to-system-wide.patch
patch --strip 1 <Avoid-SIGPIPE-in-t-local-36_verify.t.patch
patch --strip 1 <Move-SSL_ERROR_WANT_READ-SSL_ERROR_WANT_WRITE-retry-.patch
patch --strip 1 <Move-SSL_ERROR_WANT_READ-SSL_ERROR_WANT_WRITE-retry-from_write_partial.patch
patch --strip 1 <20no-stray-libz-link.patch
patch --strip 1 <add-security-level-routines.patch
patch --strip 1 <test-with-security-level-1.patch
patch --strip 1 <ok-result-is-no-error.patch
patch --strip 1 <set_num_tickets-min-version.patch
# patch --strip 1 <debian-min-tls-ver.patch
