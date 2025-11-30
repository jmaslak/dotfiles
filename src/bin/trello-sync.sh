#!/bin/bash

#
# Copyright (C) 2023-2025 Joelle Maslak
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

    rm $HOME/.task/.taskview.lock 2>/dev/null
    task.pl6 trello-sync
}

doit "$@"


