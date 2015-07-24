# ~/.profile: executed by the command interpreter for login shells.

# Are we running ksh?
# If we are, try running ksh
if [ $0 == '-ksh' ] ; then
    if [ -e /usr/bin/bash ] ; then
        # In case someone links ksh to bash...
        # Yes, it happens
        if [ "$KSH_ORIGINAL"z == ""z ] ; then
            export KSH_ORIGINAL=1
            exec /usr/bin/bash -login
        else
            # Lets not try to do anything we shouldn't
            exit;
        fi
    fi
fi

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

