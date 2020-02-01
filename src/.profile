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

    # We try to set ulimit <open files> to a more useful value
    ulimit -n 32000 >/dev/null 2>&1 || ulimit -n 4096 >/dev/null 2>&1

    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

eval "$(/home/jmaslak/.rakudobrew/bin/rakudobrew init -)"
eval "$(/home/jmaslak/.rakudobrew/bin/rakudobrew init -)"
eval "$(/home/jmaslak/.rakudobrew/bin/rakudobrew init -)"
