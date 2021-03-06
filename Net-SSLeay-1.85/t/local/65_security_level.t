#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Net::SSLeay;

plan skip_all => 'openssl-1.1.0 required' unless Net::SSLeay::SSLeay >= 0x10100001;

plan tests => 20;


my $ctx = Net::SSLeay::CTX_new();
ok( defined Net::SSLeay::CTX_get_security_level($ctx),
    "CTX_get_security_context() returns a value"
);

ok( Net::SSLeay::CTX_get_security_level($ctx) >= 0,
    "CTX_get_security_context() is non-negative"
);

for (0..7) {
    Net::SSLeay::CTX_set_security_level($ctx, $_);
    is( Net::SSLeay::CTX_get_security_level($ctx),
        $_, "CTX_get_security_level() matches CTX_set_security_level($_)" );
}

my $ssl = Net::SSLeay::new($ctx);
ok( defined Net::SSLeay::get_security_level($ssl),
    "get_security_context() returns a value"
);

ok( Net::SSLeay::get_security_level($ssl) >= 0,
    "get_security_context() is non-negative"
);

for (0..7) {
    Net::SSLeay::set_security_level($ssl, $_);
    is( Net::SSLeay::get_security_level($ssl),
        $_, "get_security_level() matches set_security_level($_)" );
}
