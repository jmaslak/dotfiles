#!/usr/bin/env raku
use v6.d;

sub MAIN() {
    for ^($*KERNEL.cpu-cores) {
        start {
            my $i = 0;
            loop {
                $i++;
            }
        }
    }
    loop {
        sleep 1;
    }
}


