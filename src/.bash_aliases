#!/bin/bash
# Alias Definitions

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    if [ -r ~/.dircolors ] ; then
        eval "$(dircolors -b ~/.dircolors)"
    else 
        eval "$(dircolors -b)"
    fi

    alias ls='ls --color=auto'

    # Don't do this on Solaris
    if [ "$( uname -a | cut -d' ' -f1 )" != 'SunOS' ] ; then
        alias grep='grep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias egrep='egrep --color=auto'
    fi
fi

# Create my alias for my task manager
if [ -f ~/tasks/task.pl6 ] ; then
    export TASKDIR=~/.task
    alias task="~/tasks/task.pl6"
    alias localtask="TASKDIR=data ~/tasks/task.pl6"
elif [ -f ~/git/antelope/perl/tasks/task.pl6 ] ; then
    export TASKDIR=~/.task
    alias task="~/git/antelope/perl/tasks/task.pl6"
    alias localtask="TASKDIR=data ~/git/antelope/perl/tasks/task.pl6"
else
    alias task=task.pl6
    alias localtask="TASKDIR=data task.pl6"
fi

# Create busy indicator alias
if command -v busy.raku >/dev/null ; then
    alias busy=busy.raku
fi

# Make sqlplus usable
alias sqlplus="rlwrap -i -f ~/.sqlplus_history -H ~/.sqlplus_history -s 30000 sqlplus"

# Raku alias
alias perl6=raku

# REPL for Raku
if [ ! -f ~/.rakurepl_history ] ; then
    touch ~/.rakurepl_history
fi
alias rakurepl="rlwrap -i -f ~/.rakurepl_history -H ~/.rakurepl_history -s 30000 raku"

# Docker ps
alias ps-docker='docker ps --format="ID\t{{.ID}}\nNAME\t{{.Names}}\nCOMMAND\t{{.Command}}\nSTATUS\t{{.Status}}\nCREATED\t{{.CreatedAt}}\nPORTS\t{{.Ports}}\n"'

# REPL for Perl5 Debugger
if [ ! -f ~/.perl5d_repl_history ] ; then
    touch ~/.perl5d_repl_history
fi
alias perl5d="rlwrap -i -f ~/.perl5d_repl_history -H ~/.perl5d_repl_history -s 30000 perl -d"

# Vim printing
alias codeprint="vim -c 'colorscheme default' -c hardcopy -c quit"
alias 4codeprint="vim -c 'colorscheme default' -c 'hardcopy | lpr -o number-up=4' -c quit"

# We use vim
if command -v vim >/dev/null ; then
    # shellcheck disable=SC2139
    alias vi="$( command -v vim )"
fi

# Json Pretty Printer with my options
if command -v json_pp >/dev/null ; then
    alias jsonpp="json_pp -json_opt canonical,indent"
fi

# ksudo (uses ksu to execute arbitrary commands as root)
ENVLOC=$(command -v env)
# shellcheck disable=SC2139
alias ksudo="ksu -q -e $ENVLOC --"

# kinit should use renewable option
KINIT=$(command -v kinit)
if [ "$KINIT" != "" ] ; then

    # This works on Heimdal, fails on MIT
    if kinit --version 2>/dev/null ; then
        # Heimdal Kerberos
        alias kinit="kinit --renewable --lifetime=30h"
    else
        # MIT Kerberos
        alias kinit="kinit -r 30h"
    fi
fi

# If we have a homebrew version of ipmitool, use it
if [ -f /usr/local/Cellar/ipmitool/1.8.15/bin/ipmitool ] ; then
    alias ipmitool=/usr/local/Cellar/ipmitool/1.8.15/bin/ipmitool
fi

# Make "home" go to home directory (use Windows home directory on
# Cygwin); Note OS X doesn't have the -o switch...
if [ "$(uname -o 2>/dev/null )" == "Cygwin" ] ; then
    cpath=$(cygpath "$HOMEDRIVE$HOMEPATH")
    # shellcheck disable=SC2139
    alias home="cd $cpath ; pwd"
else
    alias home="cd ~ ; pwd"
fi

alias lgrep="grep --line-buffered"

if command -v vim >/dev/null ; then
    # Do Nothing
    true
else
    function seq {
        if [[ "$1" =~ ^-?[0-9]+$ ]] ; then
            # OK!
            true
        else
            echo "Provide a start and end integer" >&2
            return 1
        fi

        if [[ "$2" =~ ^-?[0-9]+$ ]] ; then
            # OK!
            true
        else
            echo "Provide a start and end integer" >&2
            return 1
        fi
        
        DIR=1
        if [ "$1" -gt "$2" ] ; then
            DIR=-1
        fi

        NUM=$(( $1 + 0 ))
        END=$2
        if [ "$END" == "" ] ; then
            echo "Provide a start and end integer" >&2
            return 1
        fi
        while true ; do
            echo "$NUM"

            if [ "$NUM" -eq "$END" ] ; then
                return 0
            fi
            
            NUM=$(( NUM + DIR ))
        done
    }
fi

# Set background globally (for VIM) dark
function dark {
    echo 'set background=dark' >~/.vim/vimrc.local
}

# Set background globally (for VIM) light
function light {
    echo 'set background=light' >~/.vim/vimrc.local
}

# SOL Helper
function sol {
    if [ "$1" == "" ] ; then
        echo "Must supply hostname" >&2
        return 1
    fi
    
    if [ ! -f ~/.ipmi.pw ] ; then
        echo "Must include the IPMI password in ~/.ipmi.pw" >&2
        return 2
    fi

    ipmitool -I lanplus -H "$1" -U ADMIN -P "$(cat ~/.ipmi.pw)" sol activate
}

# IPMI Helper
function ipmi {
    if [ "$1" == "" ] ; then
        echo "Must supply hostname" >&2
        return 1
    fi

    if [ ! -f ~/.ipmi.pw ] ; then
        echo "Must include the IPMI password in ~/.ipmi.pw" >&2
        return 2
    fi

    HOST="$1"
    shift

    ipmitool -I lanplus -H "$HOST" -U ADMIN -P "$(cat ~/.ipmi_pw)" "$@"
}

# Also want 6prove, an alias to test Raku code
alias 6prove="RAKULIB=lib prove -e raku --ext .t --ext .t6"
alias venv="source venv/bin/activate"

# Swap escape
alias swap-escape="setxkbmap -option caps:swapescape"
alias unswap-escape="setxkbmap -option"

# Docker bash shell
function dockerbash {
    if [ "$1" == "" ] ; then
        IMAGE="$(basename "$(pwd)"):latest"
        if [ "$(docker ps | grep -c "$IMAGE")" -ne 1 ] ; then
            echo "Couldn't locate image $IMAGE" >&2
            return;
        fi
    else
        IMAGE="$1"
    fi
    
    docker exec -it "$(docker ps | grep "$IMAGE" | awk '{print $1}')" /bin/bash
}

# Tmux shell
function tmuxsh {
    ssh -t "$1" tmux attach \|\| tmux
}

# SSH w/ color
ssh() {
    if echo | router-colorizer.pl 2>/dev/null >/dev/null ; then
        SSHR_WORKS=yes
    else
        SSHR_WORKS=no
    fi

    # shellcheck disable=SC2230
    SSH=$(which ssh)

    ROUTER=no
    VT102=no
    RE=" [ace]s[0-9][0-9].[a-z][a-z][a-z][0-9][0-9][0-9] "
    if [[ " $* " =~ $RE ]] ; then
        ROUTER=yes
    fi
    RE=" ar[0-9]"
    if [[ " $* " =~ $RE ]] ; then
        ROUTER=yes
    fi
    RE=" dcr[0-9][0-9].[a-z][a-z][a-z][0-9][0-9][0-9] "
    if [[ " $* " =~ $RE ]] ; then
        ROUTER=yes
    fi
    RE=" ert[0-9][0-9].[a-z][a-z][a-z][0-9][0-9][0-9] "
    if [[ " $* " =~ $RE ]] ; then
        ROUTER=yes
    fi
    RE=" o[hst][0-9][0-9].[a-z][a-z][a-z][0-9][0-9][0-9] "
    if [[ " $* " =~ $RE ]] ; then
        VT102=yes
        ROUTER=yes
    fi
    RE=" pe[0-9][0-9].[a-z][a-z][a-z][0-9][0-9][0-9] "
    if [[ " $* " =~ $RE ]] ; then
        ROUTER=yes
    fi
    RE=" wdm[0-9][0-9].[a-z][a-z][a-z][0-9][0-9][0-9] "
    if [[ " $* " =~ $RE ]] ; then
        ROUTER=yes
    fi
    RE=" fw[0-9]"
    if [[ " $* " =~ $RE ]] ; then
        ROUTER=yes
    fi
    RE=" sw[0-9]"
    if [[ " $* " =~ $RE ]] ; then
        ROUTER=yes
    fi

    if [ "$*" == "sw02" ] ; then
        VT102=yes
    fi

    if [ "$SSHR_WORKS $ROUTER" == "yes yes" ] ; then
        # SSHR works good
        if [ "$VT102" == "yes" ] ; then
            TERM=vt102 $SSH "$@" | router-colorizer.pl
        else
            $SSH "$@" | router-colorizer.pl
        fi
    else
        # No SSHR
        if [ "$VT102" == "yes" ] ; then
            TERM=vt102 $SSH "$@"
        else
            $SSH "$@"
        fi
    fi
}

alias school="cd /data/jmaslak/doc/school"
alias work="cd /data/jmaslak/doc/work"
alias research="cd /data/jmaslak/research"

# Toggle your bluetooth device (e.g., Bose Headphones) between A2DP mode (high-fidelity playback with NO microphone) and HSP/HFP, codec mSBC (lower playback quality, microphone ENABLED)
function tbt {
    current_mode_is_a2dp=$(pactl list | grep Active | grep a2dp)
    card=$(pactl list | grep "Name: bluez_card." | cut -d ' ' -f 2)

    if [ -n "$current_mode_is_a2dp" ]; then
        echo "Switching $card to mSBC (headset, for making calls)..."
        pactl set-card-profile "$card" headset_head_unit
    else
        echo "Switching $card to A2DP (high-fidelity playback)..."
        pactl set-card-profile "$card" a2dp_sink
    fi
}

alias d4="raku -e 'say (1..4).roll'"
alias d6="raku -e 'say (1..6).roll'"
alias d8="raku -e 'say (1..8).roll'"
alias d10="raku -e 'say (1..10).roll'"
alias d12="raku -e 'say (1..12).roll'"
alias d20="raku -e 'say (1..20).roll'"
alias d00="raku -e 'say (1..100).roll'"

