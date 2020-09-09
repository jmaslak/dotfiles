#!/usr/bin/env raku
use v6.d;

#
# Copyright © 2020 Joelle Maslak
# All Rights Reserved - See License
#

use Terminal::ANSIColor;

my $green       = "green";
my $red         = "bold red";
my $orange      = "yellow";
my $info        = "cyan";

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
            if $buffer.bytes > 40 {
                $channel.send: message.new(:command("LARGECHARS"), :payload($buffer));
                $timer = Promise.in(.05).then: {
                    $channel.send: message.new(:command("TICK"));
                }
            } else {
                $channel.send: message.new(:command("CHARS"), :payload($buffer));
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
        
        $str ~~ s:g/<st> ( \N+ ) $$ /{parse-line($0.Str)}/;

        # Numbers
        $str ~~ s:g/<!after <[:\.0..9]>> (<[0..9]>+) <!before <[:0..9]>> /{numerify($0.Str)}/;

        print $str;
        last if $msg.command eq 'QUIT';
    }
    
    say ‘Program finished’;
    $*IN.close;

}

sub parse-line(Str:D $str is copy -->Str:D) {
    # We want to strip out the control characters at the start of line.
    # This is kind of black magic...
    $str ~~ s/^ (.* <!after \x1b '[23m'> \x1b [ "[K" || "M" ])//;
    my $preamble = $0 // "";

    # Arista prompt (should this be in the Arista parse-line?)
    $str ~~ s/ ( \x1b "[3m --More-- " .* ) //;
    my $trailer = $0 // "";

    $str = parse-line-arista($str);
    $str = parse-line-junos($str);

    return "$preamble$str$trailer";
}

sub parse-line-arista(Str:D $str is copy -->Str:D) {
    my regex num { [ "-" ]? <[0..9\.]>+ }

    #
    # ARISTA
    #

    # BGP

    $str ~~ s/^ ( "  BGP state is " <!before "Established"> \N* ) $/{colored($0.Str, $red)}/;
    $str ~~ s/^ ( "  BGP state is Established"              \N* ) $/{colored($0.Str, $green)}/;

    $str ~~ s/^ ( "BGP neighbor is " \N+       ) $/{colored($0.Str, $info)}/;
    $str ~~ s/^ ( "Local TCP address is " \N+  ) $/{colored($0.Str, $info)}/;
    $str ~~ s/^ ( "Remote TCP address is " \N+ ) $/{colored($0.Str, $info)}/;

    # Interfaces ("show int et1")

    $str ~~ s/^ ( "     0 runts, 0 giants"                 ) $/{colored($0.Str, $green)}/;
    $str ~~ s/^ ( "     " <num> " runts, " <num> " giants" ) $/{colored($0.Str, $red)}/;
    $str ~~ s/^ ( "     0 input errors, 0 CRC, 0 alignment, 0 symbol, 0 input discards"                                         ) $/{colored($0.Str, $green)}/;
    $str ~~ s/^ ( "     " <num> " input errors, " <num> " CRC, " <num> " alignment, " <num> " symbol, " <num> " input discards" ) $/{colored($0.Str, $red)}/;

    $str ~~ s/^ ( "     0 output errors, 0 collisions"                 ) $/{colored($0.Str, $green)}/;
    $str ~~ s/^ ( "     " <num> " output errors, " <num> " collisions" ) $/{colored($0.Str, $red)}/;
    $str ~~ s/^ ( "     0 late collision, 0 deferred, 0 output discards"                         ) $/{colored($0.Str, $green)}/;
    $str ~~ s/^ ( "     " <num> " late collision, " <num> " deferred, " <num> " output discards" ) $/{colored($0.Str, $red)}/;

    $str ~~ s/^ ( <[A..Z]> \S+ " is up, line protocol is up (connected)" ) $/{colored($0.Str, $green)}/;
    $str ~~ s/^ ( <[A..Z]> \S+ " is administratively down," \N+          ) $/{colored($0.Str, $orange)}/;
    $str ~~ s/^ ( <[A..Z]> \S+ " is " \N+ ", line protocol is " \N+      ) $/{colored($0.Str, $red)}/;

    $str ~~ s/^ ( "  Up " \N+   ) $/{colored($0.Str, $green)}/;
    $str ~~ s/^ ( "  Down " \N+ ) $/{colored($0.Str, $red)}/;

    $str ~~ s/^ ( "  " <num> " " \w+ " input rate " <num> " " \N+  ) $/{colored($0.Str, $info)}/;
    $str ~~ s/^ ( "  " <num> " " \w+ " output rate " <num> " " \N+ ) $/{colored($0.Str, $info)}/;

    # Interfaces ("show int status")

    $str ~~ s/^ ( <[A..Z]><[a..z]><[0..9]> \N+ " connected "   \N+ ) $/{colored($0.Str, $green)}/;
    $str ~~ s/^ ( <[A..Z]><[a..z]><[0..9]> \N+ " disabled "    \N+ ) $/{colored($0.Str, $orange)}/;
    $str ~~ s/^ ( <[A..Z]><[a..z]><[0..9]> \N+ " errdisabled " \N+ ) $/{colored($0.Str, $red)}/;
    $str ~~ s/^ ( <[A..Z]><[a..z]><[0..9]> \N+ " notconnect "  \N+ ) $/{colored($0.Str, $red)}/;

    # Interfaces ("show int description")

    $str ~~ s/^ ( <[A..Z]><[a..z]><[0..9]> \S* \s+ "up"         \s+ "up" \s+ \N+ ) $/{colored($0.Str, $green)}/;
    $str ~~ s/^ ( <[A..Z]><[a..z]><[0..9]> \S* \s+ "admin down" \s+ \S+  \s+ \N+ ) $/{colored($0.Str, $orange)}/;
    $str ~~ s/^ ( <[A..Z]><[a..z]><[0..9]> \S* \s+ " down"      \s+ \S+  \s+ \N+ ) $/{colored($0.Str, $red)}/;
    
    # Interfaces ("show int transceiver")
    my regex lowlight { [ "-30." <[0..9]>**2 ] || [ "-2" <[5..9]> "." <[0..9]>**2 ] };
    my regex light    { "N/A" || <num> };

    $str ~~ s/^ ( <[A..Z]><[a..z]><[0..9]> \S* [ \s+ <light> ]**4 \s+ <lowlight> \s+ \S+ " ago" ) $ /{colored($0.Str, $red)}/;
    $str ~~ s/^ ( <[A..Z]><[a..z]><[0..9]> \S* [ \s+ <light> ]**5                \s+ \S+ " ago" ) $ /{colored($0.Str, $info)}/;
    $str ~~ s/^ ( <[A..Z]><[a..z]><[0..9]> \S* [ \s+ 'N/A' ]**6 \s*                             ) $ /{colored($0.Str, $orange)}/;

    return $str;
}

sub parse-line-junos(Str:D $str is copy -->Str:D) {
    my regex num { [ "-" ]? <[0..9\.]>+ }

    #
    # JunOS
    #
    $str ~~ s/^ ( "Physical interface: " \S* " Enabled, Physical link is Up" )   $/{colored($0.Str, $green)}/;
    $str ~~ s/^ ( "Physical interface: " \S* " Enabled, Physical link is Down" ) $/{colored($0.Str, $red)}/;
    $str ~~ s/^ ( "Physical interface: " \S* " " \S+ " Physical link is Down" )  $/{colored($0.Str, $orange)}/;

    $str ~~ s/^ ( "  Input rate     : " <num> \N+ ) $/{colored($0.Str, $info)}/;
    $str ~~ s/^ ( "  Output rate    : " <num> \N+ ) $/{colored($0.Str, $info)}/;

    $str ~~ s/^ ( "  Active alarms  : None"                  ) $/{colored($0.Str, $green)}/;
    $str ~~ s/^ ( "  Active alarms  : " <!before "None"> \N+ ) $/{colored($0.Str, $red)}/;
    $str ~~ s/^ ( "  Active defects : None"                  ) $/{colored($0.Str, $green)}/;
    $str ~~ s/^ ( "  Active defects : " <!before "None"> \N+ ) $/{colored($0.Str, $red)}/;

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
    return UNDERLINE() ~ $str ~ UNDERLINE_OFF();
}
