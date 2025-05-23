#!/bin/bash
# Modified from base Unbutu .bashrc
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
#
# Modifications Copyright (C) 2024-2025 by Joelle Maslak


# We remove anything from the PATH that begins with /mnt/c/ - this
# solves some security warnings for Perl in "taint" mode, because on
# WSL some Windows directories are "world" writeable (they aren't
# actually, but it's complicated).
PATH=$(echo "$PATH" | tr ":" "\n" | grep -Ev '^/mnt/c/' | tr "\n" ":")

# If running on Windows, we need to execute /etc/profile
if [ -n "$SYSTEMROOT" ] ; then
    . /etc/profile
fi

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# If we are on Bash for Windows, we start in the wrong directory.
if ! bash --version 2>/dev/null | head -1 | grep 'version 3' >/dev/null ; then
    # We know we're dealing with BASH 4+ (I'm assuming nobody is running
    # <= 2); But we don't want this firing off on MacOS running old BASH
    pwd="$(pwd)"
    if [ "${pwd,,}" == '/mnt/c/windows/system32' ] ; then
        cd ~ || echo >/dev/null  # Satisfy shellcheck
    fi
    if [ "${pwd,,}" == '/mnt/c/users/jmaslak' ] ; then
        cd ~ || echo >/dev/null  # Satisfy shellcheck
    fi
fi

# Defensive umask
if [ "$(umask)" == '0000' ] ; then
    umask 0002
fi

# Make sure we are in $HOME, save old dir
OLDDIR="$PWD"
cd "$HOME" || echo >/dev/null  # Satisfy shellcheck

export LC_TIME=C.UTF-8  # We want 24 hour format

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
        PS1='[$?] \[\033[01;94m\]\h:\W\[\033[00m\]\$ '
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
    SHELL="$(command -v bash)"
fi
# If shell is just "bash", set it to path
if [ "$SHELL" == "bash" ] ; then
    SHELL="$(command -v bash)"
fi
# If shell is "-bash", set it to path
if [ "$SHELL" == "-bash" ] ; then
    SHELL="$(command -v bash)"
fi

# Alias definitions.
if [ -f ~/.bash_aliases ]; then
    # shellcheck source=.bash_aliases
    . ~/.bash_aliases
fi

# enable programmable completion features
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Standard editor
if command -v vim >/dev/null ; then
    VIM=$( command -v vim )
    export VISUAL=$VIM
    export EDITOR=$VIM
elif command -v vi >/dev/null ; then
    VI=$( command -v vi )
    export VISUAL=$VI
    export EDITOR=$VI
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

# For Homebrew
if [ -f "/opt/homebrew/bin/brew" ] ; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Do we have Perl 6's rakubrew installed?
if [ -d ~/.rakubrew ] ; then
    eval "$("$HOME"/.rakubrew/rakubrew init Bash)"
    RAKUCURRENT=$(rakubrew current | awk '{print $3}')
    export PATH="$HOME/.rakubrew:$PATH"
    export PATH="$HOME/.rakubrew/$RAKUCURRENT/install/share/raku/site/bin:$PATH"
    export PATH="$HOME/.rakubrew/versions/$RAKUCURRENT/install/share/perl6/site/bin:$PATH"
fi

# Do we have a Perlbrew?  Prefer local to system perlbrew
if [ -d ~/perl5/perlbrew ] ; then
    export PERLBREW_ROOT=~/perl5/perlbrew
# elif [ -d /usr/local/perlbrew ] ; then
#     export PERLBREW_ROOT=/usr/local/perlbrew
fi

# Load the appropriate perlbrew
if [ -n "$PERLBREW_ROOT" ] ; then
    if [ ! -o hashall ] ; then
        HASHSTATUS="off"
        # Deal with NixOS which defaults to no hashing, but perlbrew
        # expects to need to clear the cache (hash -r), which gives an
        # error when hashing is off
        set -h
    fi
    # shellcheck source=/home/jmaslak/perl5/perlbrew/etc/bashrc
    . "$PERLBREW_ROOT/etc/bashrc"
    if [ "$HASHSTATUS" == "off" ] ; then
        set +h
    fi
fi

# Local bin directory?  Use it!
if [ -d ~/bin ] ; then
    export PATH="$HOME/bin:${PATH}"
fi
if [ -d ~/.local/bin ] ; then
    export PATH="$HOME/.local/bin:${PATH}"
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
    # shellcheck source=/home/jmaslak/.bash_private
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
if command -v infocmp >/dev/null ; then
    if ! infocmp -1 "$TERM" >/dev/null 2>&1 ; then
        export TERM=screen-256color
        if ! infocmp -1 "$TERM" >/dev/null 2>&1 ; then
            export TERM=xterm-256color
            infocmp -1 "$TERM" >/dev/null 2>&1
            if ! infocmp -1 "$TERM" >/dev/null 2>&1 ; then
                export TERM=xterm
                if ! infocmp -1 "$TERM" >/dev/null 2>&1 ; then
                    export TERM=vt102
                fi
            fi
        fi
    fi
fi

# dircolors installed?
if [ "$(command -v dircolors)" != "" ] ; then
    eval "$(dircolors "$HOME/.dircolors.ansi-universal")"
fi

# X running?
if [ "$(command -v xrdb 2>/dev/null)" != "" ] ; then
    if [ "$DISPLAY" != "" ] &&  [ "$WAYLAND_DISPLAY" == "" ] ; then
        if [ "$(command -v setxkbmap)" != "" ] ; then
            setxkbmap -option # altwin:swap_lalt_lwin
        fi
    fi
fi

# Do we have a Kerberos ticket?
if [ "$(command -v klist)" != "" ] ; then
    klist >/dev/null 2>&1
    if [ 0"$?" -eq 0 ] ; then
        # Renew if we can
        kinit -R >/dev/null 2>&1
    fi
fi

# Make sure we are in the proper directory
if [ -n "$OLDDIR" ] && [ -d "$OLDDIR" ] ; then
    cd "$OLDDIR" || echo >/dev/null  # to satisfy shellcheck
fi

# Use vi bindings, not emacs
set -o vi

# Go
if [ ! -d ~/go ] ; then
    mkdir ~/go
fi
PATH="$PATH:$HOME/go/bin:$HOME/.go/go/bin:/usr/local/go/bin"
if [ "$(command -v go)" != "" ] ; then
    # shellcheck disable=SC2155
    export GOROOT="$(dirname "$(dirname "$(which go)")")"
fi

export UNCRUSTIFY_CONFIG=${HOME}/.uncrustify

# Add RVM to PATH for scripting. Make sure this is the last PATH
# variable change.
if [ -d "$HOME/.rvm/bin" ] ; then
    export PATH="$PATH:$HOME/.rvm/bin";
fi

# Load RVM into shell session *as a function*
# RVM = Ruby Version Manager
# if [ -s "$HOME/.rvm/scripts/rvm" ] ; then
#     # shellcheck source=.rvm/scripts/rvm
#     source "$HOME/.rvm/scripts/rvm"
# fi

# We want to default to understanding ANSI color codes in less
export LESS="-r"

# Python
if [ -d "$HOME/.pyenv" ] ; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)" >/dev/null
fi

# Enable Python warnings
export PYTHONWARNINGS=once

# Set up texlive
if [ -d /usr/local/texlive ] ; then
    # shellcheck disable=SC2012
    DIR=$(ls -d /usr/local/texlive/20[0-9][0-9] | sort -nr | head -1)
    export MANPATH="$MANPATH:$DIR/texmf-dist/doc/man"
    export INFOPATH="$INFOPATH:$DIR/texmf-dist/doc/info"
    export PATH="$DIR/bin/x86_64-linux:$PATH"
fi

# Remind programs we have a dark background
export TERM_BACKGROUND=dark

# Add OpenSSL if it's installed locally
if [ -d "$HOME/openssl" ] ; then
    export PATH="$HOME/openssl/bin:$PATH"
    export LD_LIBRARY_PATH="$HOME/openssl/lib:$LD_LIBRARY_PATH"
    if [ "$LIBRARY_PATH" != "" ] ; then
        export LIBRARY_PATH="$HOME/openssl/lib:$LIBRARY_PATH"
    else
        export LIBRARY_PATH="$HOME/openssl/lib"
    fi
    if [ "$CPATH"z != ""z ] ; then
        export CPATH="$HOME/openssl/include:$CPATH"
    else
        export CPATH="$HOME/openssl/include"
    fi
fi

# Set audio device if for some reason the wrong device is set.
#
# This is in the pulseaudio-utils module
if command -v pactl >/dev/null ; then
    ACTIVECAM=$(
        pactl info 2>/dev/null | \
            grep -E "Default Source: alsa_input.*USB_Camera" | \
            awk '{print $2}'
    )
    ROGERDEV=$(
        pactl list short sources 2>/dev/null | \
            grep -E "alsa_input.*Roger_On" | \
            awk '{print $2}'
    )
    if [ "$ACTIVECAM" != "" ] ; then
        if [ "$ROGERDEV" != "" ] ; then
            echo "Changing audio device from camera to Roger ON"
            pactl set-default-source "$ROGERDEV"
        fi
    fi
fi

# environmental variable.
export USE_KEYRING=1

# We do not want OSX to nag us about needing to "upgrade" to zsh.
export BASH_SILENCE_DEPRECATION_WARNING=1

# Do we need to update the templates for a new year?
if [ ! -f "$HOME/.dotfiles.year" ] ; then
    echo "***"
    echo "Please re-run install-dotfiles.pl to update template years!"
    echo "***"
elif [ "$(cat "$HOME/.dotfiles.year")" -ne "$(date +%Y)" ] ; then
    echo "***"
    echo "Please re-run install-dotfiles.pl to update template years!"
    echo "***"
fi

# And now we install work stuff.
if [ -f "$HOME/.bashrc.work" ] ; then
    # shellcheck source=/home/jmaslak/.bashrc.work
    source "$HOME/.bashrc.work"
fi

# And now local overrides
if [ -f "$HOME/.bashrc.local" ] ; then
    # shellcheck source=/home/jmaslak/.bashrc.local
    source "$HOME/.bashrc.local"
fi

# Set audio mixer
if command -v amixer >/dev/null ; then
    vol_l=$(amixer -D pulse get Master 2>/dev/null | grep 'Front Left:' | sed -e 's/^[^[]*\[//' | sed -e 's/%.*$//')
    vol_r=$(amixer -D pulse get Master 2>/dev/null | grep 'Front Right:' | sed -e 's/^[^[]*\[//' | sed -e 's/%.*$//')
    if [ "$vol_l" != "$vol_r" ] ; then
        if [ "$vol_l" -gt "$vol_r" ] ; then
            amixer -D pulse set Master "$vol_l%,$vol_l%" 2>/dev/null >/dev/null
        else
            amixer -D pulse set Master "$vol_r%,$vol_r%" 2>/dev/null >/dev/null
        fi
    fi
fi

# Quiz me!
if [ -n "$PS1" ]; then
    if [ -d ~/git/antelope/joelles-notes ] ; then
        if [ -f ~/.quiz.quizzed ] ; then
            AGE=$(( $(date +%s) - $(stat --format %Y ~/.quiz.quizzed) ))
        else
            AGE=1000000
        fi
        if [ $AGE -gt 7200 ] ; then
            touch ~/.quiz.quizzed  # Allows other sessions to bypass.
            if which raku >/dev/null ; then
                until raku ~/bin/quiz.raku ; do
                    sleep 1
                done
                touch ~/.quiz.quizzed
            fi
        fi
    fi
fi

# Set cd path!
if [ "$CDPATH" != "" ] ; then
    export CDPATH="$CDPATH:~/git/antelope"
else
    export CDPATH=".:~/git/antelope"
fi

# Make sure git copyright hook is in place
for i in "$HOME"/git/*/*/.git/hooks ; do
    if [ ! -e "$i/pre-commit" ] ; then
        ln -s "$HOME/bin/pre-commit-copyright-check" "$i/pre-commit" 2>/dev/null
    fi
done

if [ ! -o hashall ] ; then
    HASHSTATUS="off"
    # Deal with NixOS which defaults to no hashing, but perlbrew
    # expects to need to clear the cache (hash -r), which gives an
    # error when hashing is off
    set -h
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [ "$HASHSTATUS" == "off" ] ; then
    set +h
fi

