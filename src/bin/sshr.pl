#!/usr/bin/env perl

#
# Copyright (C) 2021 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

use List::Util qw(any);
use Regexp::Common qw/net number/;

# Ugly! But we need multidimensional arrays to work to get access to the
# syntactic sugar in Regexp::Common. Unfortunately, this feature didn't
# exist until recently (it was defaulting to being on).
BEGIN {
    if ( $PERL_VERSION gt v5.33.0 ) {
        feature->import::into( __PACKAGE__, qw(multidimensional) );
    }
}

my $GREEN  = "\e[32m";      # Green ANSI code
my $RED    = "\e[1;31m";    # Bold + Red ANSI code
my $ORANGE = "\e[33m";      # Orange
my $INFO   = "\e[36m";      # Cyan
my $RESET  = "\e[0m";

my @BGCOLORS = (
    "\e[30m\e[47m",    # black on white
    "\e[30m\e[41m",    # black on red
    "\e[30m\e[42m",    # black on green
    "\e[30m\e[43m",    # black on yellow (orange)
    "\e[37m\e[44m",    # white on blue
    "\e[30m\e[45m",    # black on magenta
    "\e[30m\e[46m",    # black on cyan
);

my $TIMER = 0.01;

my $NUM      = qr/$RE{num}{real}/;
my $INT      = qr/$RE{num}{int}{-sign => ''}/;
my $POSINT   = qr/(?!0)$INT/;
my $LOWLIGHT = qr/ (?: -30\. [0-9]{2} ) | (?: [ -2 [5-9] \. [0-9]{2} ) /xx;
my $LIGHT    = qr/ (?: $NUM ) | (?: N\/A ) /xx;

my $IPV4CIDR = qr/ $RE{net}{IPv4}
                   (?: \/
                       (?:
                             (?:[12][0-9])
                           | (?:3[0-2])
                           | (?:[0-9])
                        )
                    )?
                /xx;

my $IPV6CIDR = qr/ $RE{net}{IPv6}
                   (?: \/
                       (?:
                             (?:1[01][0-9])
                           | (?:12[0-8])
                           | (?:[1-9][0-9])
                           | (?:[0-9])
                        )
                    )?
                /xx;

my @INTERFACE_IGNORES = ( "bytes", "packets input", "packets output", );
my @INTERFACE_INFOS   = ( "PAUSE input", "PAUSE output", );

my @bgcolors = (
    "\e[30m\e[47m",    # black on white
    "\e[30m\e[41m",    # black on red
    "\e[30m\e[42m",    # black on green
    "\e[30m\e[43m",    # black on yellow (orange)
    "\e[37m\e[44m",    # white on blue
    "\e[30m\e[45m",    # black on magenta
    "\e[30m\e[46m",    # black on cyan
);

MAIN: {
    STDOUT->autoflush(1);
    STDIN->blocking(0);

    my $buffer = '';
    my $rin    = '';
    vec( $rin, fileno(STDIN), 1 ) = 1;
    while (1) {
        select( my $rout = $rin, undef, my $eout = $rin, $TIMER );
        if ( vec( $rout, fileno(STDIN), 1 ) || vec( $eout, fileno(STDIN), 1 ) ) {
            # We have characters to potentially read
            my $tmp = '';
            read STDIN, $tmp, 65535, 0;
            if ( length($tmp) ) {
                $buffer .= $tmp;

                # We want to process complete lines only, without a
                # timeout.
                my ( $process, $newbuf ) = $buffer =~ m/^ (.*) (\n .*) $/sxx;
                $buffer = $newbuf // $buffer;

                if ( defined($process) ) {
                    process($process);
                } elsif ( length($buffer) == 1 ) {
                    # One exception to processing complete lines is
                    # single character buffers - for these, we want to
                    # output the single character quickly to not cause
                    # lag in interactive sessions.
                    process($buffer);
                    $buffer = '';
                }
            } else {
                # End of file
                process($buffer) unless $buffer eq '';
                exit;
            }
        } else {
            # Timeout!
            if ( $buffer ne "" ) {
                process($buffer);
                $buffer = "";
            }
        }
    }
}

sub process ($text) {
    $text =~ s/^ \x1b \[ \Q3m --More-- \E \x1b \[ 23m \x1b \[ K \r \x1b \[ K //gmsxx;
    while ( $text =~ m/([^\n\r]*[\r]?[\n]?)/g ) {
        my $line = parse_line($1);
        print $line;
    }
}

sub parse_line ($text) {
    my ( $line, $eol ) = $text =~ m/([^\n]*)(\n?)/;

    # We want to strip out the control characters at the start of the
    # line. This is kind of black magic...
    my $preamble = '';
    if ( $line =~ s/^ ( .* (?<! \x1b \[23m) \x1b (?: \[K | M)) //sxx ) {
        $preamble = $1;
    }

    # Arista "More" prompt (should this be in the Arista parse-line?)
    $line =~ s/ ^ ( \x1b \[ \Q3m --More-- \E .* \x0d \x1b \[K )//sxx;

    my $trailer = "";
    if ( $line =~ s/(\x0d) $//sxx ) {
        $trailer = $1;
    }

    $line = parse_line_arista($line);
    $line = parse_line_vyos($line);
    $line = parse_line_junos($line);

    # IPv4
    $line =~ s/($IPV4CIDR)/ipv4ify($1)/egxx;

    # IPv6
    $line =~ s/ ( (?<! [a-fA-F0-9:\-]) $IPV6CIDR (?! [\w:\.\/]) ) /ipv6ify($1)/egxx;

    # Numbers
    # We need to make sure we don't highlight undesirably, such as in an
    # escape sequence.
    $line =~ s/ ( (?<! [:\.0-9]) (?<! \e \[) [0-9]+ (?! [:0-9]) ) /numerify($1)/egxx;

    return "$preamble$line$trailer$eol";
}

sub parse_line_arista ($line) {
    #
    # Arista & Cisco
    #

    # BGP
    $line =~ s/^ ( \Q  BGP state is Established\E \N* ) $/colored($1, $GREEN)/exx;
    $line =~ s/^ ( \Q  BGP state is \E            \N* ) $/colored($1, $RED)/exx;

    $line =~
s/^ ( \Q  Last \E (?: sent || rcvd) \  (?: socket-error || notification) : \N+ ) $/colored($1, $INFO)/exx;

    $line =~ s/^ ( \ \ (?: Inbound || Outbound) \Q route map is \E \N* )$/colored($1, $INFO)/exx;
    $line =~
s/^ ( \Q  Inherits configuration from and member of peer-group \E \N+ ) $/colored($1, $INFO)/exx;

    $line =~ s/^ ( \Q    \E (?: IPv4 | IPv6) \Q Unicast:     \E \N* ) $/colored($1, $INFO)/exx;
    $line =~
s/^ ( \Q  Configured maximum total number of routes is \E \d+ \Q, warning limit is \E \d+ ) $/colored($1, $INFO)/exx;

    # BGP Errors
    my $errors = qr/
        ^
        \Q    \E
        (?:
            \QAS path loop detection\E
            | \QEnforced First AS\E
            | \QMalformed MPBGP routes\E
            | \QAS path loop detection\E
            | \QOriginator ID matches local router ID\E
            | \QNexthop matches local IP address\E
            | \QResulting in removal of all paths in update (treat as withdraw)\E
            | \QResulting in AFI\E \/ \QSAFI disable\E
            | \QResulting in attribute ignore\E
            | \QDisabled AFI\E \/ \QSAFIs\E
            | \QIPv4 labeled-unicast NLRIs dropped due to excessive labels\E
            | \QIPv6 labeled-unicast NLRIs dropped due to excessive labels\E
            | \QIPv4 local address not available\E
            | \QIPv6 local address not available\E
            | \QUnexpected IPv6 nexthop for IPv4 routes\E
        )
        \Q: \E
        $POSINT
        $
    /xx;
    $line =~ s/($errors)/colored($1, $RED)/e;

    $line =~ s/^ ( \QBGP neighbor is \E \N+ ) $/colored($1, $INFO)/exx;
    $line =~ s/^ ( (?: Local | Remote) \Q TCP address is \E \N+ ) $/colored($1, $INFO)/exx;

    #
    # Interfaces
    #

    # We look for information lines
    if ( $line =~ m/^     ((?:$INT [^,]+, )*$INT [^,]+)$/ ) {
        my (%values) =
          map { reverse split / /, $_, 2 }
          split ', ', $1;

        if ( any { exists( $values{$_} ) } @INTERFACE_IGNORES ) {
            # Do nothing.
        } elsif ( any { exists( $values{$_} ) } @INTERFACE_INFOS ) {
            $line = colored( $line, $INFO );
        } elsif ( any { $values{$_} } keys %values ) {
            $line = colored( $line, $RED );
        } else {
            $line = colored( $line, $GREEN );
        }
    }

    my $INTERFACE = qr/ [A-Z] \S+ /xx;
    my $INTSHORT  = qr/ [A-Z][a-z][0-9] \N+ /xx;

    # "show int" up/down
    $line =~
s/^ ( $INTERFACE \Q is up, line protocol is up\E \Q (connected)\E? ) $/colored($1, $GREEN)/exx;
    $line =~
s/^ ( $INTERFACE \Q is administratively down,\E \N+                ) $/colored($1, $ORANGE)/exx;
    $line =~
      s/^ ( $INTERFACE \Q is \E \N+ \Q, line protocol is \E \N+          ) $/colored($1, $RED)/exx;

    $line =~ s/^ ( \Q  Up \E   \N+ ) $/colored($1, $GREEN)/exx;
    $line =~ s/^ ( \Q  Down \E \N+ ) $/colored($1, $RED)/exx;

    # "show int" rates
    $line =~
s/^ ( \Q  \E $NUM \s \w+ \s (?: input | output) \s rate \s $NUM \s \N+ ) $/colored($1, $INFO)/exx;

    # "show int status"
    $line =~ s/^ ( $INTSHORT \N+ \Q connected \E   \N+ ) $/colored($1, $GREEN)/exx;
    $line =~ s/^ ( $INTSHORT \N+ \Q disabled \E    \N+ ) $/colored($1, $ORANGE)/exx;
    $line =~ s/^ ( $INTSHORT \N+ \Q errdisabled \E \N+ ) $/colored($1, $RED)/exx;
    $line =~ s/^ ( $INTSHORT \N+ \Q notconnect \E  \N+ ) $/colored($1, $RED)/exx;

    # "show int description"
    $line =~ s/^ ( $INTSHORT \s+ up             \s+ up  (?: \s+ \N+)? ) $/colored($1, $GREEN)/exx;
    $line =~ s/^ ( $INTSHORT \s+ \Qadmin down\E \s+ \S+ (?: \s+ \N+)? ) $/colored($1, $ORANGE)/exx;
    $line =~ s/^ ( $INTSHORT \s+ down           \s+ \S+ (?: \s+ \N+)? ) $/colored($1, $RED)/exx;

    # "show int transceiver"
    $line =~
      s/^ ( $INTSHORT (?: \s+ $LIGHT){4} \s+ $LOWLIGHT \s+ \S+ \s ago ) $/colored($1, $RED)/exx;
    $line =~
      s/^ ( $INTSHORT (?: \s+ $LIGHT){5}               \s+ \S+ \s ago ) $/colored($1, $INFO)/exx;
    $line =~
      s/^ ( $INTSHORT (?: \s+ N\/A  ){6} \s*                          ) $/colored($1, $ORANGE)/exx;

    #
    # LLDP Neighbors Detail
    #
    $line =~
s/^ ( \QInterface\E \s \S+ \s detected \s $POSINT \Q LLDP neighbors:\E ) $/colored($1, $INFO)/exx;
    $line =~ s/^ ( \Q  Neighbor \E \S+ \s age \s $POSINT \s seconds ) $/colored($1, $INFO)/exx;
    $line =~ s/^ ( \Q  Discovered \E \N+ \Q; Last changed \E \N+ \s ago ) $/colored($1, $INFO)/exx;
    $line =~ s/^ ( \Q  - System Name: \E \N+ ) $/colored($1, $INFO)/exx;
    $line =~ s/^ ( \Q    Port ID     :\E \N+ ) $/colored($1, $INFO)/exx;
    $line =~ s/^ ( \Q    Management Address        : \E \N+ ) $/colored($1, $INFO)/exx;

    return $line;
}

sub parse_line_junos ($line) {

    #
    # JunOS
    #

    # Show Interfaces
    $line =~
s/^ ( \QPhysical interface: \E \S+ \Q Enabled, Physical link is Up\E   ) $/colored($1, $GREEN)/exx;
    $line =~
s/^ ( \QPhysical interface: \E \S+ \Q Enabled, Physical link is Down\E ) $/colored($1, $RED)/exx;
    $line =~
s/^ ( \QPhysical interface: \E \S+ \s \S+ \Q Physical link is Down\E   ) $/colored($1, $ORANGE)/exx;

    $line =~ s/^ ( \Q  Input rate     : \E $NUM \N+ ) $/colored($1, $INFO)/exx;
    $line =~ s/^ ( \Q  Output rate    : \E $NUM \N+ ) $/colored($1, $INFO)/exx;

    $line =~ s/^ ( \Q  Active alarms  : None\E ) $/colored($1, $GREEN)/exx;
    $line =~ s/^ ( \Q  Active alarms  : \E \N+ ) $/colored($1, $RED)/exx;
    $line =~ s/^ ( \Q  Active defects : None\E ) $/colored($1, $GREEN)/exx;
    $line =~ s/^ ( \Q  Active defects : \E \N+ ) $/colored($1, $RED)/exx;

    my $AE    = qr/ (?: ae [0-9\.]+       ) /xx;
    my $BME   = qr/ (?: bme [0-9\.]+      ) /xx;
    my $ETH   = qr/ (?: [gx] e- [0-9\/\.]+) /xx;
    my $JSRV  = qr/ (?: jsrv [0-9\.]*     ) /xx;
    my $LO    = qr/ (?: lo [0-9\.]+       ) /xx;
    my $ME    = qr/ (?: me [0-9\.]+       ) /xx;
    my $VCP   = qr/ (?: vcp- [0-9\/\.]+   ) /xx;
    my $VLAN  = qr/ (?: vlan\. [0-9]+     ) /xx;
    my $OTHER = qr/ dsc | gre | ipip | jsrv | lsi | mtun | pimd | pime | tap | vlan | vme /xx;

    my $IFACES = qr/$AE|$BME|$ETH|$LO|$ME|$JSRV|$VCP|$VLAN|$OTHER/xx;

    $line =~ s/^ ( (?: $IFACES) \s+ up \s+ up \N*   ) $/colored($1, $GREEN)/exx;
    $line =~ s/^ (     $ETH     \s+ VCP             ) $/colored($1, $GREEN)/exx;
    $line =~ s/^ ( (?: $IFACES) \s+ up \s+ down \N* ) $/colored($1, $RED)/exx;
    $line =~ s/^ ( (?: $IFACES) \s+ down \s+ \N*    ) $/colored($1, $ORANGE)/exx;

    return $line;
}

sub parse_line_vyos ($line) {

    #
    # VyOS (Stuff the Arista/Cisco commands did not do
    #

    # BGP
    $line =~ s/^ ( \Q  BGP state = \E (?!Established) \N* ) $/colored($1, $RED)/exx;
    $line =~ s/^ ( \Q  BGP state = Established\E              \N* ) $/colored($1, $GREEN)/exx;

    $line =~
s/^ ( \Q  Route map for \E (?: incoming|outgoing ) \Q advertisements is \E \N* ) $/colored($1, $INFO)/exx;
    $line =~ s/^ ( \Q  \E \S+ \Q peer-group member\E \N+ ) $/colored($1, $INFO)/exx;

    $line =~ s/^ ( \Q  \E $INT \Q accepted prefixes\E \N+ ) $/colored($1, $INFO)/exx;

    $line =~ s/^ ( \QLocal host: \E   \N+ ) $/colored($1, $INFO)/exx;
    $line =~ s/^ ( \QForeign host: \E \N+ ) $/colored($1, $INFO)/exx;

    return $line;
}

sub ipv4ify ($ip) {
    my ( $subnet, $len ) = split "/", $ip;
    $len //= 32;

    my (@oct) = split /\./, $subnet;
    my $val   = 0;
    foreach my $i (@oct) {
        $val *= 256;
        $val += $i;
    }
    $val = $val * 256 + $len;
    my $color = $BGCOLORS[ $val % scalar(@BGCOLORS) ];
    return colored( $ip, $color );
}

sub ipv6ify ($ip) {
    my ($subnet, $len) = split "/", $ip;
    $len //= 128;

    my ($first, $second) = split "::", $subnet;

    my (@fparts) = split /:/, $first;
    push(@fparts, ('','','','','','','',''));
    @fparts = @fparts[0..7];

    my (@sparts);
    if (defined($second)) {
        (@sparts) = reverse split /:/, $second;
    }
    push(@sparts, ('','','','','','','',''));
    @sparts = reverse @sparts[0..7];

    my $val = 0;
    for my $i (0..7) {
        $val *= 16;
        $val += hex($fparts[$i] . $sparts[$i]);
    }
    $val *= 32;
    $val += $len;
    
    my $color = $BGCOLORS[ $val % scalar(@BGCOLORS) ];
    return colored( $ip, $color );
}

sub numerify($num) {
    my $output = "";
    while (length($num) > 3) {
        $output = substr($num, -3) . $output;
        $num = substr($num, 0, length($num)-3);

        my $next3;
        if (length($num) > 3) {
            $next3 = substr($num, -3);
            $num = substr($num, 0, length($num)-3);
        } else {
            $next3 = $num;
            $num = '';
        }
        $output = highlight($next3) . $output;
    }
    $output = $num . $output;

    return $output;
}

sub highlight($str) {
    return "\e[4m$str\e[24m";
}

sub colored ( $text, $color ) {
    $text = $color . $text;
    $text =~ s/ \Q$RESET\E / $color /;
    $text = $text . $RESET;
    return $text;
}
