#!/usr/bin/env perl
#
# Copyright (C) 2015-2019 Joelle Maslak
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

    if ( umask == 0 ) {
        umask 0002;    # Defensively set umask
    }

    my $home    = $ENV{HOME};
    my $current = getcwd;

    my $network_available = network_available();

    if ( ( !-f '~/.dotfile.nogit' ) || ( !exists( $ENV{DOTFILE_NOGIT} ) ) ) {
        if ($network_available) {
            system "git fetch origin master >/dev/null 2>/dev/null";
            my $gitrevs = `git rev-list HEAD..origin/master | wc -l`;

            if ( $gitrevs > 0 ) {
                print STDERR "Local directory is not synced with remote, please do a git pull.\n";
                print STDERR "\n";
                print STDERR "To avoid this check, set \$ENV{DOTFILE_NOGIT}\n";
                print STDERR "\n";
                print STDERR "Aborting.\n";
                exit 1;
            }
        }
    }

    my $rename_old = 1;    # We rename old files
    if ( -e "$home/.dotfiles.installed" ) {

        # We don't rename if we've already installed stuff
        $rename_old = undef;
    }

    my $environment = get_environment($home);
    my $copyright   = get_copyright( $home, $environment );
    my $fullname    = get_fullname( $home, $environment );
    my $email       = get_email( $home, $environment );

    install_git_submodules() if $network_available;
    install_files($rename_old);
    install_vim_templates($copyright);
    install_git_config( $fullname, $email );

    if ( !-d "$home/tmp" ) {
        print "Creating temporary directory...";
        mkdir "$home/tmp";
        print "\n";
    }

    if ($network_available) {
        system "$current/perl-setup.sh";
        system "$current/perl6-modules.sh";
        system "$current/python-modules.sh";
    }
}

sub get_environment {
    my ($home) = @_;

    my $environment;

    if ( -e "$home/.dotfiles.environment" ) {
        $environment = slurp("$home/.dotfiles.environment");
        chomp $environment;
    }

    while ( !defined($environment) ) {
        print "Please enter the environment (home/work/other):\n";
        local $| = 1;
        print " > ";
        $environment = <STDIN>;
        chomp($environment);

        if (   ( $environment ne 'home' )
            && ( $environment ne 'work' )
            && ( $environment ne 'other' ) )
        {
            # Let's try this again
            $environment = undef;
            next;
        }

        print "Creating $home/.dotfiles.environment ...";
        spitout( "$home/.dotfiles.environment", $environment );
        print "\n";
    }

    return $environment;

}

sub get_copyright {
    my ( $home, $environment ) = @_;

    my $copyright;

    if ( -e "$home/.dotfiles.copyright" ) {
        $copyright = slurp("$home/.dotfiles.copyright");
        if ( $copyright =~ m/Joel\W/s ) {    # We want to change this always!
            $copyright = undef;
        }
    }

    while ( !defined($copyright) ) {
        if ( $environment eq 'home' ) { $copyright = 'Joelle Maslak' }
        if ( $environment eq 'work' ) { $copyright = 'CenturyLink' }

        if ( $environment eq 'other' ) {
            print "Please enter the name to use for copyright in templates:\n";
            local $| = 1;
            print " > ";
            $copyright = <STDIN>;
            chomp($copyright);
        }

        if ($copyright =~ m/\@/) {
            print "ERROR: Do not include an at-sign in this field\n";
            $copyright = undef;
            next;
        }

        print "Creating $home/.dotfiles.copyright ...";
        spitout( "$home/.dotfiles.copyright", $copyright );
        print "\n";
    }

    return $copyright;
}

sub get_fullname {
    my ( $home, $environment ) = @_;

    my $fullname;

    if ( -e "$home/.dotfiles.fullname" ) {
        $fullname = slurp("$home/.dotfiles.fullname");
        if ( $fullname =~ m/Joel\W/s ) {    # We want to change this always!
            $fullname = undef;
        }
    }

    while ( !defined($fullname) ) {
        if ( $environment eq 'home' ) { $fullname = 'Joelle Maslak' }
        if ( $environment eq 'work' ) { $fullname = 'Joelle Maslak' }

        if ( $environment eq 'other' ) {
            print "Please enter the full name to use for git in templates:\n";
            local $| = 1;
            print " > ";
            $fullname = <STDIN>;
            chomp($fullname);
        }

        if ($fullname =~ m/\@/) {
            print "ERROR: Do not include an at-sign in this field\n";
            $fullname = undef;
            next;
        }

        print "Creating $home/.dotfiles.fullname...";
        spitout( "$home/.dotfiles.fullname", $fullname );
        print "\n";
    }

    return $fullname;
}

sub get_email {
    my ( $home, $environment ) = @_;

    my $email;

    if ( -e "$home/.dotfiles.email" ) {
        $email = slurp("$home/.dotfiles.email");
        if ( $email =~ m/joel\W/is ) {    # We want to change this always!
            $email = undef;
        }
    }

    while ( !defined($email) ) {
        if ( $environment eq 'home' ) { $email = 'jmaslak@antelope.net' }
        if ( $environment eq 'work' ) { $email = 'jmaslak@centurylink.com' }

        if ( $environment eq 'other' ) {
            print "Please enter the email address to use for git in templates:\n";
            local $| = 1;
            print " > ";
            $email = <STDIN>;
            chomp($email);
        }

        if ($email !~ m/\@/) {
            print "ERROR: Email address must include an at-sign\n";
            $email = undef;
            next;
        }

        print "Creating $home/.dotfiles.email...";
        spitout( "$home/.dotfiles.email", $email );
        print "\n";
    }

    return $email;
}

sub install_files {
    if ( scalar(@_) != 1 ) { confess 'invalid call'; }
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
    if ( scalar(@_) != 1 ) { confess 'invalid call'; }
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

        if ( !( $file =~ m/\.base$/ ) ) {
            print "ignoring\n";
            next LOOP;
        }

        my $basefile = $file;
        $basefile =~ s/\.base$//;

        print "Creating ... ";
        my $out = slurp("$current/src/.vim/templates/$file");
        $out =~ s/_COPYRIGHT_/$copyright/g;
        spitout( "$home/.vim/templates/$basefile", $out );

        # Make executable if needed
        if ( -x "$current/src/.vim/templates/$file" ) {
            chmod 0755, "$home/.vim/templates/$basefile";
        }

        print "done\n";
    }
}

sub install_git_submodules {
    system("git submodule init");
    system("git submodule update");

    return;
}

sub install_git_config {
    my ( $fullname, $email ) = @_;

    system("git config --global user.email \"$email\"");
    system("git config --global user.name \"$fullname\"");
    system("git config --global log.mailmap true");
    system("git config --global github.user jmaslak");
    system("git config --global push.recurseSubmodules check");
    system("git config --global diff.tool ccdiff");
    system("git config --global difftool.prompt false");
    system("git config --global difftool.ccdiff.cmd 'ccdiff --bg=black --old=bright_red --utf-8 -u -r \$LOCAL \$REMOTE'");

    my $ver = `git version`;
    chomp($ver);
    if ( $ver =~ m/git version 1\.[01234567]\./ ) {
        # Version <= 1.7
        # We do NOT configure the simple
    } else {
        # New enough git!
        system("git config --global push.default simple");
    }

    return;
}

sub slurp {
    if ( scalar(@_) != 1 ) { confess 'invalid call' }
    my $fn = shift;

    # Be compatible with old Perl
    my $fh = gensym();
    open( $fh, '<', $fn ) or die($!);
    my @out = <$fh>;
    close($fh);

    return join( '', @out );
}

sub spitout {
    if ( scalar(@_) != 2 ) { confess 'invalid call' }
    my ( $fn, $val ) = @_;

    my $fh = gensym();
    open( $fh, '>', $fn ) or die("Couldn't create $fn - $!\n");
    print $fh $val or die($!);
    close($fh);
}

sub network_available {
    my $ret = eval { require Net::Ping };
    if (!$ret) {
        warn "Net::Ping not installed.";
        return 1;    # We can't guarante N:P installed.
    }

    my $ping   = Net::Ping->new();
    $ping->port_number(80);
    my $result = $ping->ping( '1.1.1.1', 1 );

    if ( !$result ) {
        print("Network not available, skipping functions dependent upon network\n");
    }

    return !!$result;
}

