#!/usr/bin/env raku
use v6.d;

sub MAIN() {
    for (^$*KERNEL.cpu-cores) {
        start { sleep 1; loop {} };
    }
    sleep;
}


