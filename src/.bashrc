# Modified from base Unbutu .bashrc

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If running on Windows, we need to execute /etc/profile
if [ ! -z "$SYSTEMROOT" ] ; then
    . /etc/profile
fi

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Make sure we are in $HOME, save old dir
OLDDIR=$PWD
cd $HOME

# Run this in the background, to create .cpanreporter comment.txt lines
if [ -x ".bash.sysinfo" ] ; then
    nohup ./.bash.sysinfo </dev/null >/dev/null 2>/dev/null &
    disown %%
fi

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Set xterms to 256 color
if [ "$TERM" == "xterm" ] ; then
    TERM=xterm-256color
fi

# Set color prompt
force_color_prompt=yes
if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        # PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
        PS1='[$?] \[\033[01;34m\]\h:\W\[\033[00m\]\$ '
    else
        PS1='[$?] ${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    fi
fi

unset color_prompt force_color_prompt

# Set the title to user@host:dir in screen, xterm, or rxvt.
case "$TERM" in
screen*|xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
esac

# Make sure shell is exported
export SHELL="$0"
# If shell is set to "-su", reset it to bash
if [ "$SHELL" == "-su" ] ; then
    SHELL="-bash"
fi
# If shell is just "bash", set it to path
if [ "$SHELL" == "bash" ] ; then
    SHELL="$(which bash)"
fi

# Alias definitions.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Standard editor
if which vim >/dev/null 2>/dev/null ; then
    export VISUAL=$( which vim )
    export EDITOR=$( which vim )
fi

# Quagga likes to run everything through a pager. Annoying.
export VTYSH_PAGER=cat

# Set up bc options
if [ -e ~/.bc.startup ] ; then
    BCFILE=~/.bc.startup

    # -l - load math library and set scale=20
    export BC_ENV_ARGS="-l $BCFILE"
fi

# Put CUDA into path
if [ -d /usr/local/cuda-7.0 ] ; then
    export CUDA_HOME=/usr/local/cuda-7.0
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${CUDA_HOME}/lib64"
    export PATH="${PATH}:${CUDA_HOME}/bin"
fi

# For MacPorts
if [ -d /opt/local/bin ] ; then
    export PATH="$PATH:/opt/local/bin"
fi
if [ -d /opt/local/sbin ] ; then
    export PATH="$PATH:/opt/local/sbin"
fi

# Do we have Perl 6's rakudobrew installed?
if [ -d ~/.rakudobrew ] ; then
    export "PATH=$HOME/.rakudobrew/bin:$PATH"
fi

# Do we have a Perlbrew?  Prefer local to system perlbrew
if [ -d ~/perl5/perlbrew ] ; then
    export PERLBREW_ROOT=~/perl5/perlbrew
# elif [ -d /usr/local/perlbrew ] ; then
#     export PERLBREW_ROOT=/usr/local/perlbrew
fi

# Load the appropriate perlbrew
if [ ! -z "$PERLBREW_ROOT" ] ; then
    . $PERLBREW_ROOT/etc/bashrc
fi

# Local bin directory?  Use it!
if [ -d ~/bin ] ; then
    export PATH="~/bin:${PATH}"
fi

# Data Analyisis scripts
if [ -d ~/analyze ] ; then
    export PATH="$PATH:~/analyze"
elif [ -d ~/git/antelope/perl/App-DataExplorer ] ; then
    export PATH="$PATH:~/git/antelope/perl/App-DataExplorer"
fi

# Oracle libraries here?
if [ -d /usr/lib/oracle/11.2/client64/lib ] ; then
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/lib/oracle/11.2/client64/lib
    export PATH="$PATH:/usr/lib/oracle/11.2/client64/lib"
fi

# Private stuff that shouldn't be in Github
if [ -e ~/.bash_private ] ; then
    . ~/.bash_private
fi

# Can't not have fortune...
if [ -x /usr/games/fortune ] ; then
    echo
    if [ -d ~/.fortune ] ; then
        /usr/games/fortune ~/.fortune
    else
        /usr/games/fortune
    fi
    echo
fi

# Solaris workarounds
if [ "$( uname -a | cut -d' ' -f1 )" == 'SunOS' ] ; then
    if [ "$TERM" == "screen-256color" ] ; then
        export TERM=xterm
    elif [ "$TERM" == "xterm-256color" ] ; then
        export TERM=xterm
    fi
fi

# More Solaris
if [ -d /usr/ccs/bin ] ; then
    export PATH="$PATH:/usr/ccs/bin"
fi
if [ -d /usr/sbin ] ; then
    export PATH="$PATH:/usr/sbin"
fi
if [ -d /usr/ccs/bin ] ; then
    export PATH="$PATH:/usr/ccs/bin"
fi
if [ -d /opt/solarisstudio12.4/bin ] ; then
    export PATH="$PATH:/opt/solarisstudio12.4/bin"
fi

# Local terminfo?
if [ -d ~/local/lib/terminfo ] ; then
    export TERMINFO=~/local/lib/terminfo
fi

# UCB in path?
if [ -d /usr/ucb ] ; then
    export PATH="$PATH:/usr/ucb"
fi

# Perltest installed?
if [ -d ~/git/antelope/perltest ] ; then
    export PATH="$PATH:~/git/antelope/perltest/bin"
elif [ -d ~/perltest ] ; then
    export PATH="$PATH:~/perltest/bin"
fi

# Check for proper terminal functionality
which infocmp 2>&1 >/dev/null
if [ $? -eq 0 ] ; then
    infocmp -1 "$TERM" >/dev/null 2>&1
    if [ $? -ne 0 ] ; then
        export TERM=screen-256color
        infocmp -1 "$TERM" >/dev/null 2>&1
        if [ $? -ne 0 ] ; then
            export TERM=xterm-256color
            infocmp -1 "$TERM" >/dev/null 2>&1
            if [ $? -ne 0 ] ; then
                export TERM=xterm
                infocmp -1 "$TERM" >/dev/null 2>&1
                if [ $? -ne 0 ] ; then
                    export TERM=vt102
                fi
            fi
        fi
    fi
fi

# dircolors installed?
if [ "$(which dircolors 2>/dev/null)" != "" ] ; then
    eval $(dircolors "$HOME/.dircolors.ansi-universal")
fi

# X running?
# if [ "$(which xrdb 2>/dev/null)" != "" ] ; then
#     if [ "$DISPLAY" != "" ] ; then
#         if [ -f ~/.Xresources ] ; then
#             xrdb -merge -I$HOME ~/.Xresources &
#         fi
#     fi
# fi

# Do we have a Kerberos ticket?
if [ "$(which klist 2>/dev/null)" != "" ] ; then
    klist >/dev/null 2>&1
    if [ 0"$?" -eq 0 ] ; then
        # Renew if we can
        kinit -R >/dev/null 2>&1
    fi
fi

# Make sure we are in the proper directory
if [ \! -z $OLDDIR ] ; then
    if [ -d $OLDDIR ] ; then
        cd $OLDDIR
    fi
fi

# Use vi bindings, not emacs
set -o vi
