#!/usr/bin/env raku
use v6.c;

#
# Copyright © 2020-2021 Joelle Maslak
# All Rights Reserved - See License
#

my $green       = "\e[32m";     # Green ANSI code
my $red         = "\e[1;31m";   # Bold + Red ANSI code
my $orange      = "\e[33m";     # Orange
my $info        = "\e[36m";     # Cyan
my $reset       = "\e[0m";

class message {
    has $.command;
    has $.payload;
};

sub MAIN() {
    # Loop on characters from STDIN
    my $channel = Channel.new;
    start {
        my $timer;
        while $*IN.read -> $buffer {
            $timer = 0;
            if $buffer.bytes > 2 {
                $channel.send: message.new(:command("LARGECHARS"), :payload($buffer));
                $timer = Promise.in(.05).then: {
                    $channel.send: message.new(:command("TICK"));
                }
            } else {
                $channel.send: message.new(:command("LARGECHARS"), :payload($buffer));
                $timer = Promise.in(.01).then: {
                    $channel.send: message.new(:command("TICK"));
                }
                # $channel.send: message.new(:command("CHARS"), :payload($buffer));
            }
        }

        $channel.send: message.new(:command("QUIT"));
    }

    my $buff = buf8.new;
    my $larges;
    while $channel.receive -> $msg {
        if $msg.command eq 'CHARS'|'LARGECHARS' {
            $buff.append: $msg.payload;
        }
        if $msg.command eq 'LARGECHARS' {
            $larges++;
            next;
        }
        if $larges and $msg.command eq 'TICK' {
            $larges--;
            next if $larges; # We wait for the last tick.
        }

        my $str = $buff.decode('utf-8');
        $buff = buf8.new;

        # Handle pagination and backscrowling on Arista:
        my regex st { <?after [ ^ || \n ]> };

        # Remove trailing space/backspace.
        # $str ~~ s:g/ " " \x8 //;
        
        $str ~~ s:g/<st> ( \N+ ) $$ /{parse-line($0)}/;

        # Numbers
        # We need to make sure we don't highlight undesirably, such as
        # in an escape sequence
        $str ~~ s:g/<!after <[:\.0..9]>|[\e \[]> (<[0..9]>+) <!before <[:0..9]>> /{numerify($0)}/;

        print $str;
        last if $msg.command eq 'QUIT';
    }
    
    $*IN.close;

}

sub parse-line(Str:D() $str is copy -->Str:D) {
    # We want to strip out the control characters at the start of line.
    # This is kind of black magic...
    $str ~~ s/^ (.* <!after \x1b '[23m'> \x1b [ "[K" || "M" ])//;
    my $preamble = $0 // "";

    # Arista prompt (should this be in the Arista parse-line?)
    $str ~~ s/ ( \s* [ \x1b "[3m --More-- " .* ]? ) $//;
    my $trailer = $0 // "";

    $str = parse-line-arista($str);
    $str = parse-line-vyos($str);
    $str = parse-line-junos($str);

    return "$preamble$str$trailer";
}

sub parse-line-arista(Str:D $str is copy -->Str:D) {
    my regex num { [ "-" ]? <[0..9\.]>+ }

    #
    # Arista & Cisco
    #

    # BGP

    $str ~~ s/^ ( "  BGP state is " <!before "Established"> \N* ) $/{colored($0, $red)}/;
    $str ~~ s/^ ( "  BGP state is Established"              \N* ) $/{colored($0, $green)}/;

    $str ~~ s/^ ( "  Last " [ "sent" || "rcvd" ] " " [ "socket-error" || "notification" ] ":" \N+ ) $/{colored($0, $info)}/;

    $str ~~ s/^ ( "  " [ "Inbound"|"Outbound" ] " route map is " \N* ) $/{colored($0, $info)}/;
    $str ~~ s/^ ( "  Inherits configuration from and member of peer-group " \N* ) $/{colored($0, $info)}/;

    $str ~~ s/^ ( "    " [ "IPv4"|"IPv6" ] " Unicast:     " \N* ) $/{colored($0, $info)}/;
    $str ~~ s/^ ( "  Configured maximum total number of routes is " \d+ ", warning limit is " \d+ ) $/{colored($0, $info)}/;

    # Display errors
    $str ~~ s/^
        (
            "    "
            [
                "AS path loop detection"
                || "Enforced First AS"
                || "Malformed MPBGP routes"
                || "Originator ID matches local router ID"
                || "Nexthop matches local IP address"
                || "Resulting in removal of all paths in update (treat as withdraw)"
                || "Resulting in AFI/SAFI disable"
                || "Resulting in attribute ignore"
                || "Disabled AFI/SAFIs" # Fix VIM highlighting --> "
                || "IPv4 labeled-unicast NLRIs dropped due to excessive labels"
                || "IPv6 labeled-unicast NLRIs dropped due to excessive labels"
                || "IPv4 local address not available"
                || "IPv6 local address not available"
            ]
            ": "
            <!before "0">  # We aren't interested in errors
            <num>
        ) $ /{colored($0, $red)}/;

    $str ~~ s/^ ( "BGP neighbor is " \N+       ) $/{colored($0, $info)}/;
    $str ~~ s/^ ( "Local TCP address is " \N+  ) $/{colored($0, $info)}/;
    $str ~~ s/^ ( "Remote TCP address is " \N+ ) $/{colored($0, $info)}/;

    # Interfaces ("show int et1")

    $str ~~ s/^ ( "     0 runts, 0 giants"                 ) $/{colored($0, $green)}/;
    $str ~~ s/^ ( "     " <num> " runts, " <num> " giants" ) $/{colored($0, $red)}/;
    $str ~~ s/^ ( "     0 runts, 0 giants, 0 throttles"                        ) $/{colored($0, $green)}/;
    $str ~~ s/^ ( "     " <num> " runts, " <num> " giants, " <num> "throttles" ) $/{colored($0, $red)}/;
    $str ~~ s/^ ( "     0 input errors, 0 CRC, 0 alignment, 0 symbol, 0 input discards"                                         ) $/{colored($0, $green)}/;
    $str ~~ s/^ ( "     " <num> " input errors, " <num> " CRC, " <num> " alignment, " <num> " symbol, " <num> " input discards" ) $/{colored($0, $red)}/;
    $str ~~ s/^ ( "     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored"                                         ) $/{colored($0, $green)}/;
    $str ~~ s/^ ( "     " <num> " input errors, " <num> " CRC, " <num> " frame, " <num> " overrun, " <num> " ignored" ) $/{colored($0, $red)}/;

    $str ~~ s/^ ( "     0 output errors, 0 collisions"                 ) $/{colored($0, $green)}/;
    $str ~~ s/^ ( "     " <num> " output errors, " <num> " collisions" ) $/{colored($0, $red)}/;
    $str ~~ s/^ ( "     0 unknown protocol drops"         ) $/{colored($0, $green)}/;
    $str ~~ s/^ ( "     " <num> " unknown protocol drops" ) $/{colored($0, $red)}/;
    $str ~~ s/^ ( "     0 output errors, 0 collisions, " <num> " interface resets"                 ) $/{colored($0, $green)}/;
    $str ~~ s/^ ( "     " <num> " output errors, " <num> " collisions, " <num> " interface resets" ) $/{colored($0, $red)}/;
    $str ~~ s/^ ( "     0 output errors, " <num> " interface resets"         ) $/{colored($0, $green)}/;
    $str ~~ s/^ ( "     " <num> " output errors, " <num> " interface resets" ) $/{colored($0, $red)}/;
    $str ~~ s/^ ( "     0 late collision, 0 deferred, 0 output discards"                         ) $/{colored($0, $green)}/;
    $str ~~ s/^ ( "     " <num> " late collision, " <num> " deferred, " <num> " output discards" ) $/{colored($0, $red)}/;
    $str ~~ s/^ ( "     0 babbles, 0 late collision, 0 deferred"                         ) $/{colored($0, $green)}/;
    $str ~~ s/^ ( "     " <num> " babbles, " <num> " late collision, " <num> " deferred" ) $/{colored($0, $red)}/;

    $str ~~ s/^ ( <[A..Z]> \S+ " is up, line protocol is up" " (connected)"? ) $/{colored($0, $green)}/;
    $str ~~ s/^ ( <[A..Z]> \S+ " is administratively down," \N+              ) $/{colored($0, $orange)}/;
    $str ~~ s/^ ( <[A..Z]> \S+ " is " \N+ ", line protocol is " \N+          ) $/{colored($0, $red)}/;

    $str ~~ s/^ ( "  Up " \N+   ) $/{colored($0, $green)}/;
    $str ~~ s/^ ( "  Down " \N+ ) $/{colored($0, $red)}/;

    $str ~~ s/^ ( "  " <num> " " \w+ " input rate " <num> " " \N+  ) $/{colored($0, $info)}/;
    $str ~~ s/^ ( "  " <num> " " \w+ " output rate " <num> " " \N+ ) $/{colored($0, $info)}/;

    # Interfaces ("show int status")

    $str ~~ s/^ ( <[A..Z]><[a..z]><[0..9]> \N+ " connected "   \N+ ) $/{colored($0, $green)}/;
    $str ~~ s/^ ( <[A..Z]><[a..z]><[0..9]> \N+ " disabled "    \N+ ) $/{colored($0, $orange)}/;
    $str ~~ s/^ ( <[A..Z]><[a..z]><[0..9]> \N+ " errdisabled " \N+ ) $/{colored($0, $red)}/;
    $str ~~ s/^ ( <[A..Z]><[a..z]><[0..9]> \N+ " notconnect "  \N+ ) $/{colored($0, $red)}/;

    # Interfaces ("show int description")

    $str ~~ s/^ ( <[A..Z]><[a..z]><[0..9]> \S* \s+ "up"         \s+ "up" [ \s+ \N+ ]? ) $/{colored($0, $green)}/;
    $str ~~ s/^ ( <[A..Z]><[a..z]><[0..9]> \S* \s+ "admin down" \s+ \S+  [ \s+ \N+ ]? ) $/{colored($0, $orange)}/;
    $str ~~ s/^ ( <[A..Z]><[a..z]><[0..9]> \S* \s+ " down"      \s+ \S+  [ \s+ \N+ ]? ) $/{colored($0, $red)}/;
    
    # Interfaces ("show int transceiver")
    my regex lowlight { [ "-30." <[0..9]>**2 ] || [ "-2" <[5..9]> "." <[0..9]>**2 ] };
    my regex light    { "N/A" || <num> };

    $str ~~ s/^ ( <[A..Z]><[a..z]><[0..9]> \S* [ \s+ <light> ]**4 \s+ <lowlight> \s+ \S+ " ago" ) $ /{colored($0, $red)}/;
    $str ~~ s/^ ( <[A..Z]><[a..z]><[0..9]> \S* [ \s+ <light> ]**5                \s+ \S+ " ago" ) $ /{colored($0, $info)}/;
    $str ~~ s/^ ( <[A..Z]><[a..z]><[0..9]> \S* [ \s+ 'N/A' ]**6 \s*                             ) $ /{colored($0, $orange)}/;

    # LLDP Neighbors Detail
    $str ~~ s/^ ( "Interface " \S+ " detected " <[0..9]>+ " LLDP neighbors:" ) $/{colored($0, $info)}/;
    $str ~~ s/^ ( "  Neighbor " \S+ " age " <[0..9]>+ " seconds" ) $/{colored($0, $info)}/;
    $str ~~ s/^ ( "  Discovered " \N+ "; Last changed " \N+ " ago" ) $/{colored($0, $info)}/;
    $str ~~ s/^ ( "  - System Name: " \N+ ) $/{colored($0, $info)}/;
    $str ~~ s/^ ( "    Port ID     :" \N+ ) $/{colored($0, $info)}/;
    $str ~~ s/^ ( "    Management Address        : " \N+ ) $/{colored($0, $info)}/;

    return $str;
}

sub parse-line-vyos(Str:D $str is copy -->Str:D) {
    my regex num { [ "-" ]? <[0..9\.]>+ }

    #
    # VyOS (Stuff the Arista/Cisco commands did not do)
    #

    # BGP

    $str ~~ s/^ ( "  BGP state = " <!before "Established"> \N* ) $/{colored($0, $red)}/;
    $str ~~ s/^ ( "  BGP state = Established"              \N* ) $/{colored($0, $green)}/;

    $str ~~ s/^ ( "  Route map for " [ "incoming"|"outgoing" ] " advertisements is " \N* ) $/{colored($0, $info)}/;
    $str ~~ s/^ ( "  " \S+ " peer-group member" \N+ ) $/{colored($0, $info)}/;

    $str ~~ s/^ ( "  " \d+ " accepted prefixes" \N+ ) $/{colored($0, $info)}/;

    $str ~~ s/^ ( "Local host: "   \N+ ) $/{colored($0, $info)}/;
    $str ~~ s/^ ( "Foreign host: " \N+ ) $/{colored($0, $info)}/;

    return $str;
}

sub parse-line-junos(Str:D $str is copy -->Str:D) {
    my regex num { [ "-" ]? <[0..9\.]>+ }

    #
    # JunOS
    #
    $str ~~ s/^ ( "Physical interface: " \S* " Enabled, Physical link is Up" )   $/{colored($0, $green)}/;
    $str ~~ s/^ ( "Physical interface: " \S* " Enabled, Physical link is Down" ) $/{colored($0, $red)}/;
    $str ~~ s/^ ( "Physical interface: " \S* " " \S+ " Physical link is Down" )  $/{colored($0, $orange)}/;

    $str ~~ s/^ ( "  Input rate     : " <num> \N+ ) $/{colored($0, $info)}/;
    $str ~~ s/^ ( "  Output rate    : " <num> \N+ ) $/{colored($0, $info)}/;

    $str ~~ s/^ ( "  Active alarms  : None"                  ) $/{colored($0, $green)}/;
    $str ~~ s/^ ( "  Active alarms  : " <!before "None"> \N+ ) $/{colored($0, $red)}/;
    $str ~~ s/^ ( "  Active defects : None"                  ) $/{colored($0, $green)}/;
    $str ~~ s/^ ( "  Active defects : " <!before "None"> \N+ ) $/{colored($0, $red)}/;

    $str ~~ s/^ (   <[gx]> "e-" <[0..9 \/]>+ \s+ "up" \s+ "up" \N+   ) $/{colored($0, $green)}/;
    $str ~~ s/^ (   <[gx]> "e-" <[0..9 \/]>+ \s+ "VCP"               ) $/{colored($0, $green)}/;
    $str ~~ s/^ (   <[gx]> "e-" <[0..9 \/]>+ \s+ "up" \s+ "down" \N+ ) $/{colored($0, $red)}/;
    $str ~~ s/^ (   <[gx]> "e-" <[0..9 \/]>+ \s+ "down" \s+ \N+      ) $/{colored($0, $orange)}/;

    $str ~~ s/^ (   "ae" <[0..9]>+ \s+ "up" \s+ "up" \N+   ) $/{colored($0, $green)}/;
    $str ~~ s/^ (   "ae" <[0..9]>+ \s+ "up" \s+ "down" \N+ ) $/{colored($0, $red)}/;
    $str ~~ s/^ (   "ae" <[0..9]>+ \s+ "down" \s+ \N+      ) $/{colored($0, $orange)}/;

    $str ~~ s/^ (   "vlan." <[0..9]>+ \s+ "up" \s+ "up" \N+   ) $/{colored($0, $green)}/;
    $str ~~ s/^ (   "vlan." <[0..9]>+ \s+ "up" \s+ "down" \N+ ) $/{colored($0, $red)}/;
    $str ~~ s/^ (   "vlan." <[0..9]>+ \s+ "down" \s+ \N+      ) $/{colored($0, $orange)}/;

    return $str;
}

sub numerify(Str:D() $num is copy -->Str:D) {
    my Str:D $output = "";
    while $num.chars > 3 {
        $output = $num.substr(*-3) ~ $output;
        $num = $num.substr(0, *-3);

        my $next3;
        if $num.chars > 3 {
            $next3 = $num.substr(*-3);
            $num = $num.substr(0, *-3);
        } else {
            $next3 = $num;
            $num = "";
        }
        $output = highlight($next3) ~ $output;
    }
    $output = $num ~ $output;
}

sub highlight(Str:D $str --> Str:D) {
    return "\e[4m" ~ $str ~ "\e[24m"; # Underline
}

sub colored(Str:D() $str, Str:D $color --> Str:D) {
    return $color ~ $str ~ $reset;
}
