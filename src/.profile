# ~/.profile: executed by the command interpreter for login shells.

# Are we running ksh?
# If we are, try running ksh
if [ "x $0" == 'x -ksh' ] ; then
    if [ \( -e /usr/bin/bash \) -o \( -e /bin/bash \) ] ; then
        # In case someone links ksh to bash...
        # Yes, it happens
        if [ "$KSH_ORIGINAL"z == ""z ] ; then
            export KSH_ORIGINAL=1
            if [ -e /usr/bin/bash ] ; then
                exec /usr/bin/bash -login
            else
                exec /bin/bash -login
            fi
        else
            # Lets not try to do anything we shouldn't
            exit
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

