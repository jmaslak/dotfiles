#!/usr/bin/perl

#
# Copyright (C) 2015 Joel Maslak
# All Rights Reserved - See License
#

use strict;
use warnings;
# use autodie;  # This is incompatible with older perl

use Carp;
use Cwd;
use File::Copy qw(move);

# Files to ignore
my %IGNORE_FILENAME = (
    '.'           => 1,
    '..'          => 1,
    '.git'        => 1,
    '.gitignore'  => 1,
    'nytprof.out' => 1
);

my %IGNORE_SUFFIX = ( '.swp' => 1 );

MAIN: {
    if ( !defined( $ENV{HOME} ) ) {
        die "Please set \$HOME environmental variable";
    }

    my $home    = $ENV{HOME};
    my $current = getcwd;

    my $rename_old = 1;    # We rename old files
    if ( -e "$home/.dotfiles.installed" ) {

        # We don't rename if we've already installed stuff
        $rename_old = undef;
    }

    opendir( my $dh, "$current/src" );
    my @files = sort readdir($dh);
    closedir $dh;

  LOOP:
    foreach my $file (@files) {
        print "File: $file -> ";
        if ( exists( $IGNORE_FILENAME{$file} ) ) {
            print "ignoring\n";
            next;
        }
        foreach my $suffix ( keys %IGNORE_SUFFIX ) {
            if ( $file =~ m/${suffix}$/ ) {
                print "ignoring\n";
                next LOOP;
            }
        }

        if ( -e "$home/$file" ) {
            if ($rename_old) {
                print "backing up old file ... ";
                move( "$home/$file", "$home/$file.bak" );
            } else {
                print "file already exists, skipping\n";
                next;
            }
        }

        print "symlinking ... ";
        symlink( "$current/src/$file", "$home/$file" );

        print "done\n";
    }
}

