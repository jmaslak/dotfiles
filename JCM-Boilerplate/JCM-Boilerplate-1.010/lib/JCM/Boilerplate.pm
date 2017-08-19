#
# Copyright (C) 2015,2016 J. Maslak
# All Rights Reserved - See License
#

package JCM::Boilerplate v0.01.08;
# ABSTRACT: Default Boilerplate for Joel's Code
$JCM::Boilerplate::VERSION = '1.010';

use v5.22;

use feature 'signatures';
no warnings 'experimental::signatures';

use Import::Into;
use Smart::Comments;

sub import($self, $type='script') {
    ### assert: ($type =~ m/^(?:class|role|script)$/ms)
    
    my $target = caller;

    strict->import::into($target);
    warnings->import::into($target);
    autodie->import::into($target);

    feature->import::into($target, ':5.22');

    utf8->import::into($target); # Allow UTF-8 Source

    if ($type eq 'class') {
        Moose->import::into($target);
        Moose::Util::TypeConstraints->import::into($target);
        MooseX::StrictConstructor->import::into($target);
        namespace::autoclean->import::into($target);
    } elsif ($type eq 'role') {
        Moose::Role->import::into($target);
        Moose::Util::TypeConstraints->import::into($target);
        MooseX::StrictConstructor->import::into($target);
        namespace::autoclean->import::into($target);
    }

    Carp->import::into($target);
    English->import::into($target);
    Smart::Comments->import::into($target, '-ENV', '###');

    feature->import::into($target, 'postderef');    # Not needed if >= 5.23.1
    feature->import::into($target, 'refaliasing');
    feature->import::into($target, 'signatures');
    feature->import::into($target, 'switch');
    feature->import::into($target, 'unicode_strings');
    warnings->unimport::out_of($target, 'experimental::postderef'); # Not needed if >= 5.23.1
    warnings->unimport::out_of($target, 'experimental::refaliasing');
    warnings->unimport::out_of($target, 'experimental::signatures');

    # For "switch" feature
    warnings->unimport::out_of($target, 'experimental::smartmatch');
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

JCM::Boilerplate - Default Boilerplate for Joel's Code

=head1 VERSION

version 1.010

=head1 SYNOPSIS

  use JCM::Boilerplate 'script';

=head1 DESCRIPTION

This module serves two purposes.  First, it sets some default imports,
and turns on the strictures I've come to rely upon.  Secondly, it depends
on a number of other modules to aid in setting up new environments (I can
just do a "cpan JCM-Boilerplate" to install everything I need).

This module optionally takes one of two parameters, 'script', 'class',
or 'role'. If 'script' is specified, the module assumes that you do not
need Moose or MooseX modules.

=head1 WARNINGS
This module makes significant changes in the calling package!

In addition, this module should be incorporated into any project by
copying it into the project's library tree. This protects the project from
outside dependencies that may be undesired.

=head1 AUTHOR

J. Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015,2016 by J. Maslak.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
