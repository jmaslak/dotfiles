#!/bin/bash

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

doit() {
    # Do we have Perl 6's rakubrew installed?
    if [ -d ~/.rakubrew ] ; then
        eval "$(~/.rakubrew/rakubrew init Bash)"
        export PATH="$HOME/.rakubrew:$PATH"
        export PATH="$HOME/.rakubrew/$(rakubrew current | awk '{print $3}')/install/share/raku/site/bin:$PATH"
        export PATH="$HOME/.rakubrew/versions/$(rakubrew current | awk '{print $3}')/install/share/perl6/site/bin:$PATH"
    fi

    task.pl6 trello-sync
}

doit "$@"


