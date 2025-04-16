#!/bin/zsh
# Modified from base Ubuntu .bashrc, with additional modicifciations by
# Joelle.
# see /usr/share/doc/bash/examples/startup-files (in the package
# bash-doc) for examples.
#
# Modifications Copyright (C) 2024-2025 Joelle Maslak


# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Make sure we are in $HOME, save old dir
OLDDIR="$PWD"
cd "$HOME" || echo >/dev/null  # Satisfy shellcheck

export LC_TIME=C  # we want 24 hour format

# Ignore commands with a leading space, for history purposes
setopt HIST_IGNORE_SPACE

# Don't add duplicates to history
setopt HIST_IGNORE_DUPS

# Append history, don't overwrite, when exiting.
setopt APPEND_HISTORY

# History sizes
HISTSIZE=1000
SAVEHIST=20000

# use vi bindings, not emacs
set -o vi

# Keybindings for home/end/delete
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line
bindkey "^[[3~" delete-char

# Keybindings for emacs-style search in vi mode
bindkey -M viins '^R' history-incremental-pattern-search-backward
bindkey -M viins '^F' history-incremental-pattern-search-forward

# Less should be more graceful with non-text input files (see
# lesspipe(1))
if [ "$(command -v lesspipe)" != "" ] ; then
    eval "$(SHELL=/bin/sh lesspipe)"
fi
if [ "$(command -v lesspipe.sh)" != "" ] ; then
    eval "$(SHELL=/bin/sh lesspipe.sh)"
fi

# Set color prompt
# We assume we have color support and that it is compliant with ECMA-48
# (ISO/IEC-6429). Lack of such support is rare, and such a case would
# tend to support setf rather than setaf)
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null ; then
    PS1='[%?] %F{033}%m:%1~%f$ '
fi

# Aliases
if [ -f ~/.zsh_aliases ] ; then
    source ~/.zsh_aliases
fi

# Standard editor
if command -v vim >/dev/null ; then
    export EDITOR="$( command -v vim )"
    export VISUAL="$EDITOR"
elif command -v vi >/dev/null ; then
    export EDITOR="$( comand -v vi )"
    export VISUAL="$EDITOR"
fi

# Set up BC options
if [ -e ~/.bc.startup ] ; then
    BCFILE=~/.bc.startup

    # -l is load math library and set scale=20
    export BC_ENV_ARGS="-l $BCFILE"
fi

# Homebrew
if [ -f "/opt/homebrew/bin/brew" ] ; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Do we have rakubrew installed?
if [ -d ~/.rakubrew ] ; then
    eval "$("$HOME"/.rakubrew/rakubrew init Zsh)"
fi

# Do we have a Perlbrew?  Prefer local to system perlbrew
if [ -d ~/perl5/perlbrew ] ; then
    export PERLBREW_ROOT=~/perl5/perlbrew
fi

# Load the appropriate perlbrew
if [ -n "$PERLBREW_ROOT" ] ; then
    # shellcheck source=/home/jmaslak/perl5/perlbrew/etc/bashrc
    # Yes, Perlbrew uses bashrc in zsh
    source "$PERLBREW_ROOT/etc/bashrc"
fi

# Local bin directory?  Use it!
if [ -d ~/bin ] ; then
    export PATH="$HOME/bin:${PATH}"
fi
if [ -d ~/.local/bin ] ; then
    export PATH="$HOME/.local/bin:${PATH}"
fi

# Private stuff that shouldn't be in Github
if [ -e ~/.zsh_private ] ; then
    source ~/.zsh_private
fi

# Colorize LS
export CLICOLOR=1
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd

# Make sure we are in the proper directory
if [ -n "$OLDDIR" ] && [ -d "$OLDDIR" ] ; then
    cd "$OLDDIR" || echo >/dev/null  # to satisfy shellcheck
fi

# Go!
if [ ! -d ~/go ] ; then
    mkdir ~/go
fi
PATH="$PATH:$HOME/go/bin:$HOME/.go/go/bin:/usr/local/go/bin"
if [ "$(command -v go)" != "" ] ; then
    # shellcheck disable=SC2155
    export GOROOT="$(dirname "$(dirname "$(which go)")")"
fi

# We want to default to understanding ANSI color codes in less
export LESS="-r"

# Python
if [ -d "$HOME/.pyenv" ] ; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)" >/dev/null
fi

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
if [ -f "$HOME/.zshrc.work" ] ; then
    # shellcheck source=/home/jmaslak/.zshrc.work
    source "$HOME/.zshrc.work"
fi

# And now local overrides
if [ -f "$HOME/.zshrc.local" ] ; then
    # shellcheck source=/home/jmaslak/.zshrc.local
    source "$HOME/.zshrc.local"
fi

if [ "$CDPATH" != "" ] ; then
    export CDPATH="${CDPATH}:${HOME}/git/antelope"
else
    export CDPATH=".:${HOME}/git/antelope"
fi

# Make sure git copyright hook is in place
for i in "$HOME"/git/*/*/.git/hooks ; do
    if [ ! -e "$i/pre-commit" ] ; then
        ln -s "$HOME/bin/pre-commit-copyright-check" "$i/pre-commit" 2>/dev/null
    fi
done

# Set up compleation
autoload -Uz compinit
compinit 
