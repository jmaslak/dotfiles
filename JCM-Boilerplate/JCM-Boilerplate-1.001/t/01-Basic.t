#!/usr/bin/perl -T
# Yes, we want to make sure things work in taint mode

#
# Copyright (C) 2015 Joel Maslak
# All Rights Reserved - See License
#

# Basic testing

use Test::More tests => 2;

# Instantiate the object
require_ok('JCM::Boilerplate');

# Verify switch statement works
# (This is turned on in the boilerplate)
eval {
    use JCM::Boilerplate;

    my $test=1;
    given ($test) {
        when (/1/) {
            pass('Boilerplate works!');
        }
    }
} or fail('Boilerplate fails');

