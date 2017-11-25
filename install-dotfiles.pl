#!/usr/bin/perl

#
# Copyright (C) 2015 Joelle Maslak
# All Rights Reserved - See License
#

use strict;
use warnings;
# use autodie;  # This is incompatible with older perl

use Carp;
use Cwd;
use File::Copy qw(move);
use Symbol;

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

    my $copyright;
    if ( -e "$home/.dotfiles.copyright" ) {
        $copyright = slurp("$home/.dotfiles.copyright");
        if ($copyright =~ m/Joel\W/s) { # We want to change this always!
            $copyright = undef;
        }
    }

    if (!defined($copyright)) {
        print "Please enter the name to use for copyright in templates:\n";
        local $| = 1;
        print " > ";
        $copyright = <STDIN>;
        chomp($copyright);

        print "Creating $home/.dotfiles.copyright ...";
        spitout("$home/.dotfiles.copyright", $copyright);
        print "\n";
    }

    install_files($rename_old);
    install_vim_templates($copyright);

    if ( ! -d "$home/tmp" ) {
        print "Creating temporary directory...";
        mkdir "$home/tmp";
        print "\n";
    }

    system "$current/perl-setup.sh";
    system "$current/perl6-modules.sh";
}

sub install_files {
    if (scalar(@_) != 1) { confess 'invalid call'; }
    my $rename_old = shift;

    my $home    = $ENV{HOME};
    my $current = getcwd;

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

sub install_vim_templates {
    if (scalar(@_) != 1) { confess 'invalid call'; }
    my $copyright = shift;

    my $home    = $ENV{HOME};
    my $current = getcwd;

    opendir( my $dh, "$current/src/.vim/templates" );
    my @files = sort readdir($dh);
    closedir $dh;

  LOOP:
    foreach my $file (@files) {
        print "Template: $file -> ";
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

        if (! ( $file =~ m/\.base$/ ) ) {
            print "ignoring\n";
            next LOOP;
        }

        my $basefile = $file;
        $basefile =~ s/\.base$//;

        print "Creating ... ";
        my $out = slurp( "$current/src/.vim/templates/$file" );
        $out =~ s/_COPYRIGHT_/$copyright/g;
        spitout("$home/.vim/templates/$basefile", $out);

        # Make executable if needed
        if ( -x "$current/src/.vim/templates/$file" ) {
            chmod 0755, "$home/.vim/templates/$basefile";
        }

        print "done\n";
    }
}

sub slurp {
    if (scalar(@_) != 1) { confess 'invalid call' }
    my $fn = shift;

    # Be compatible with old Perl
    my $fh = gensym();
    open($fh, '<', $fn) or die($!);
    my @out = <$fh>;
    close($fh);

    return join('', @out);
}

sub spitout {
    if (scalar(@_) != 2) { confess 'invalid call' }
    my ($fn, $val) = @_;

    my $fh = gensym();
    open($fh, '>', $fn) or die("Couldn't create $fn - $!\n");
    print $fh $val or die($!);
    close($fh);
}
