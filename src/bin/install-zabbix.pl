#!/usr/bin/perl

#
# Copyright (C) 2021 Joelle Maslak
# All Rights Reserved - See License
#

use v5.24;
use strict;
use warnings;

use feature qw(signatures);
no warnings qw(experimental::signatures);

use autodie;

my $SERVER   = "192.168.64.11";
my $DOMAIN   = "antelope.net";
my $CONFFILE = "/etc/zabbix/zabbix_agentd.conf";
my $PWFILE   = "/etc/zabbix/agent.key";

MAIN: {
    check_root();
    install_package();
    generate_zabbix_password();
    configure_zabbix();
    restart_zabbix();

    say("");
    say("Zabbix is now configured");
    say( " Hostname: " . get_hostname() );
    say( " PSK: " . get_zabbix_password() );
    say( " PSK Identity: PSK_" . get_hostname() );
    say("");
}

sub check_root() {
    if ( $> != 0 ) {
        die("Must run as root");
    }
}

sub install_package() {
    system("apt-get update");
    system("apt-get -y install openssl zabbix-agent");
    return;
}

sub configure_zabbix() {
    my $conf = slurp($CONFFILE);

    my $host = get_hostname();

    $conf =~ s/^Server=.*$/Server=$SERVER/m;
    $conf =~ s/^ServerActive=.*$/ServerActive=$SERVER/m;
    $conf =~ s/^Hostname=.*/Hostname=$host/m;
    $conf =~ s/^(# )?TLSConnect=.*$/TLSConnect=psk/m;
    $conf =~ s/^(# )?TLSAccept=.*$/TLSAccept=psk/m;
    $conf =~ s/^(# )?TLSPSKFile=.*$/TLSPSKFile=$PWFILE/m;
    $conf =~ s/^(# )?TLSPSKIdentity=.*$/TLSPSKIdentity=PSK_$host/m;

    spurt( $CONFFILE, $conf );
    return;
}

sub restart_zabbix() {
    system("systemctl restart zabbix-agent");
    system("systemctl status zabbix-agent");
    return;
}

sub slurp($filename) {
    open my $fh, "<", $filename;
    local $/ = undef;
    my $data = <$fh>;
    close $fh;

    return $data;
}

sub spurt ( $filename, $data ) {
    open my $fh, ">", $filename;
    print $fh $data;
    close $fh;
    return;
}

sub generate_zabbix_password() {
    return if ( -f $PWFILE );

    spurt( $PWFILE, generate_new_password() );
    system( "chmod", "640",    $PWFILE );
    system( "chown", "zabbix", $PWFILE );
    system( "chgrp", "zabbix", $PWFILE );

    return;
}

sub get_zabbix_password() {
    my $pw = slurp($PWFILE);
    chomp($pw);
    return $pw;
}

sub generate_new_password() {
    my $pw = `openssl rand -hex 32`;
    chomp($pw);

    return $pw;
}

sub get_hostname() {
    my $host = fc(`hostname -f`);
    chomp($host);

    my $domain = fc($DOMAIN);
    $domain =~ s/\./\\./g;
    if ( !( $host =~ m/\.${domain}$/ ) ) {
        die("'hostname -f' does not return an $domain domain name");
    }

    return $host;
}

