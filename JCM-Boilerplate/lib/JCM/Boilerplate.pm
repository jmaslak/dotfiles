#!/usr/bin/perl

#
# Copyright (C) 2015 Joel C. Maslak
# All Rights Reserved - See License
#

package JCM::Boilerplate v0.01.02;
# ABSTRACT: Default Boilerplate for Joel's Code

=head1 SYNOPSIS

  use JCM::Boilerplate 'script';

=head1 DESCRIPTION

This module serves two purposes.  First, it sets some default imports,
and turns on the strictures I've come to rely upon.  Secondly, it depends
on a number of other modules to aid in setting up new environments (I can
just do a "cpan JCM-Boilerplate" to install everything I need).

This module optionally takes one of two parameters, 'script' or 'class'. If
'script' is specified, the module assumes that you do not need Moose or
MooseX modules.

=head1 WARNINGS
This module makes significant changes in the calling package!

In addition, this module should be incorporated into any project by
copying it into the project's library tree. This protects the project from
outside dependencies that may be undesired.
=cut

use v5.22;

use feature 'signatures';
no warnings 'experimental::signatures';

use Import::Into;
use Smart::Comments;

sub import($self, $type='script') {
    ### assert: (($type eq 'class') || ($type eq 'script'))
    
    my $target = caller;

    strict->import::into($target);
    warnings->import::into($target);
    autodie->import::into($target);

    feature->import::into($target, ':5.22');

    if ($type eq 'class') {
        Moose->import::into($target);
        Moose::Util::TypeConstraints->import::into($target);
        MooseX::StrictConstructor->import::into($target);
        namespace::autoclean->import::into($target);
    }

    Carp->import::into($target);
    Smart::Comments->import::into($target);

    feature->import::into($target, 'postderef');
    feature->import::into($target, 'refaliasing');
    feature->import::into($target, 'signatures');
    feature->import::into($target, 'switch');
    warnings->unimport::out_of($target, 'experimental::postderef');
    warnings->unimport::out_of($target, 'experimental::refaliasing');
    warnings->unimport::out_of($target, 'experimental::signatures');

    # For "switch" feature
    warnings->unimport::out_of($target, 'experimental::smartmatch');
}

1;
