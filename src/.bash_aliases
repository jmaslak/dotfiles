# Alias Definitions

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
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

