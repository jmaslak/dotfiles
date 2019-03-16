#!/usr/bin/perl
# tcpcat.pl - Send a message and receive a reply from TCP server.
#
# Copyright (c) 2003 Sampo Kellomaki <sampo@iki.fi>, All Rights Reserved.
# $Id$
# 17.8.2003, created --Sampo
 
$host = 'localhost' unless $host = shift;
$port = 443         unless $port = shift;
$msg = "get \n\r\n" unless $msg = shift;

print "$host $port $msg\n";
use Net::SSLeay qw(tcpcat);
print tcpcat($host, $port, $msg);
 
__END__
