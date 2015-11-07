# Alias Definitions

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    # Don't do this on Solaris
    if [ "$( uname -a | cut -d' ' -f1 )" != 'SunOS' ] ; then
        alias grep='grep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias egrep='egrep --color=auto'
    fi
fi

# Create my alias for my task manager
if [ -d ~/tasks ] ; then
    alias task=~/tasks/task.pl
elif [ -d ~/git/antelope/perl/tasks ] ; then
    alias task=~/git/antelope/perl/tasks/task.pl
fi

# Make sqlplus usable
alias sqlplus="rlwrap -i -f ~/.sqlplus_history -H ~/.sqlplus_history -s 30000 sqlplus"

# Xterm - put in background, and use reverse video (white on black)
alias xterm="xterm -rv &"

# We use vim
if which vim >/dev/null 2>/dev/null ; then
    alias vi="$( which vim )"
fi

# Json Pretty Printer with my options
if which json_pp >/dev/null 2>&1 ; then
    alias jsonpp="json_pp -json_opt canonical,indent"
fi

# ksudo (uses ksu to execute arbitrary commands as root)
ENVLOC=$(which env)
alias ksudo="ksu -q -e $ENVLOC --"

# kinit should use renewable option
alias kinit="kinit --renewable"

# If we have a perlbrew version of ipmitool, use it
if [ -f /usr/local/Cellar/ipmitool/1.8.15/bin/ipmitool ] ; then
    alias ipmitool=/usr/local/Cellar/ipmitool/1.8.15/bin/ipmitool
fi

# TMUX Stuff
# Start 8 terminals and layout in 3x3 (one terminal should have already
# been running)
function tmux-build9 {
    for i in $(seq 2 9) ; do
        tmux splitw
        tmux select-layout 'dc8f,272x78,0,0[272x26,0,0{91x26,0,0,235,90x26,92,0,295,89x26,183,0,296},272x25,0,27{91x25,0,27,297,90x25,92,27,298,89x25,183,27,299},272x25,0,53{91x25,0,53,300,90x25,92,53,301,89x25,183,53,302}]'
    done
}

# Just layout in 3x3
function tmux-layout9 {
    tmux select-layout 'dc8f,272x78,0,0[272x26,0,0{91x26,0,0,235,90x26,92,0,295,89x26,183,0,296},272x25,0,27{91x25,0,27,297,90x25,92,27,298,89x25,183,27,299},272x25,0,53{91x25,0,53,300,90x25,92,53,301,89x25,183,53,302}]'
}

# Start 11 terminals and layout in 4x3 (one termianl should have already
# been running)
function tmux-build12 {
    for i in $(seq 2 12) ; do
        tmux splitw
        tmux select-layout 'e078,272x78,0,0[272x25,0,0{68x25,0,0,200,67x25,69,0,215,67x25,137,0,213,67x25,205,0,214},272x25,0,26{68x25,0,26,210,67x25,69,26,219,67x25,137,26,216,67x25,205,26,217},272x26,0,52{68x26,0,52,211,67x26,69,52,220,67x26,137,52,218,67x26,205,52,221}]'
    done
}

# Just layout in 4x3
function tmux-layout12 {
    tmux select-layout 'e078,272x78,0,0[272x25,0,0{68x25,0,0,200,67x25,69,0,215,67x25,137,0,213,67x25,205,0,214},272x25,0,26{68x25,0,26,210,67x25,69,26,219,67x25,137,26,216,67x25,205,26,217},272x26,0,52{68x26,0,52,211,67x26,69,52,220,67x26,137,52,218,67x26,205,52,221}]'
}

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
    
    if [ \! -f ~/.ipmi.pw ] ; then
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

    if [ \! -f ~/.ipmi.pw ] ; then
        echo "Must include the IPMI password in ~/.ipmi.pw" >&2
        return 2
    fi

    HOST="$1"
    shift

    ipmitool -I lanplus -H "$HOST" -U ADMIN -P "$(cat ~/.ipmi_pw)" "$@"
}
