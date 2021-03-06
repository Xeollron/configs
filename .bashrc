#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

LOGIN="false" #change to true to enable starting X server from login in tty1 (replace session manager)

if [[ "$LOGIN" = "true" ]]; then
  temp=$(tty)
  if [[ "${temp:5}" = "tty1" ]]; then
    startx
  fi
fi

# Normal Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

NC="\e[m"               # Color Reset

ALERT=${BWhite}${On_Red} # Bold White on red background

#get local prompt or remote connection
if [ -n "$SSH_CLIENT" ]; then
  Machine='@\h '
fi

function get_home {
  if [[ "$(pwd)" == "/home/$(whoami)" ]];then
    echo "home"
	fi
}

# get current branch in git repo
function parse_git_branch() {
  if [[ `get_home` == "" ]]; then
	  BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	  if [ ! "${BRANCH}" == "" ]
	  then
		  STAT=`parse_git_dirty`
		  echo "[${BRANCH}${STAT}]"
	  else
		  echo ""
	  fi
  fi
}

# get current status of git repo
function parse_git_dirty {
	status=`git status 2>&1 | tee`
	dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
	untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
	ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
	newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
	renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
	deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
	bits=''
	if [ "${renamed}" == "0" ]; then
		bits=">${bits}"
	fi
	if [ "${ahead}" == "0" ]; then
		bits="*${bits}"
	fi
	if [ "${newfile}" == "0" ]; then
		bits="+${bits}"
	fi
	if [ "${untracked}" == "0" ]; then
		bits="?${bits}"
	fi
	if [ "${deleted}" == "0" ]; then
		bits="x${bits}"
	fi
	if [ "${dirty}" == "0" ]; then
		bits="!${bits}"
	fi
	if [ ! "${bits}" == "" ]; then
		echo " ${bits}"
	else
		echo ""
	fi
}

NCPU=$(grep -c 'processor' /proc/cpuinfo)    # Number of CPUs
SLOAD=$(( 100*${NCPU} ))        # Small load
MLOAD=$(( 200*${NCPU} ))        # Medium load
XLOAD=$(( 400*${NCPU} ))        # Xlarge load

# Returns system load as percentage, i.e., '40' rather than '0.40)'.
function load()
{
    local SYSLOAD=$(cut -d " " -f1 /proc/loadavg | tr -d '.')
    # System load of the current host.
    echo $((10#$SYSLOAD))       # Convert to decimal.
}

# Returns a color indicating system load.
function load_color() {
    local SYSLOAD=$(load)
    if [ ${SYSLOAD} -gt ${XLOAD} ]; then
        echo -en ${ALERT}
    elif [ ${SYSLOAD} -gt ${MLOAD} ]; then
        echo -en ${Yellow}
    elif [ ${SYSLOAD} -gt ${SLOAD} ]; then
        echo -en ${Red}
    else
        echo -en ${Green}
    fi
}


export TERM=xterm-256color

export PS1="[\u\[$Blue\]$Machine \[$Purple\]\`parse_git_branch\`\[$NC\]\[\$(load_color)\]\W\[$NC\]] "


#setup infinite actively updateing bash history file
export HISTSIZE=-1
export HISTFILESIZE=-1
export HISTCONTROL=ignoredups
export HISTTIMEFORMAT=
export PROMPT_COMMAND='history -a'
shopt -s cmdhist
shopt -s histappend

#set bash things
set -o notify     #Notifies user immediately when a background job completes
set -o physical   #Expand all symbolic links in output of pwd and when using cd so that you see the real directory names and paths
set -o interactive-comments   #Allow “#” to comment out any following text when typed interactively


#basic commands aliases
alias ls="ls --color=auto"
alias la="ls -a"
alias ll="ls -la"
alias lt="ls|toilet -f term -F border --gay"
alias grep='grep --color=auto'
alias cp='cp -p'
alias mkdir='mkdir -p'



#sense of humour ease of use aliases
alias fuck="shutdown -h now"
alias booty="tail"
alias shit="tmpcmd=$(tail -n 1 .bash_history) && sudo $tmpcmd"

function xtitle() {
    case "$TERM" in
    *term* | rxvt)
        echo -en  "\e]0;$*\a" ;;
    *)  ;;
    esac
}


# Aliases that use xtitle
HOST=$(hostname)
alias htop='xtitle Processes on $HOST && htop'
alias make='xtitle Making $(basename $PWD) ; make'

function man() {
    for i ; do
        xtitle The $(basename $1|tr -d .[:digit:]) manual
        command man -a "$i"
    done
}

#-------------------------------------------------------------
# Process/system related functions:
#-------------------------------------------------------------

# Handy Extract Program
function extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xvjf $1     ;;
            *.tar.gz)    tar xvzf $1     ;;
            *.bz2)       bunzip2 $1      ;;
            *.rar)       unrar x $1      ;;
            *.gz)        gunzip $1       ;;
            *.tar)       tar xvf $1      ;;
            *.tbz2)      tar xvjf $1     ;;
            *.tgz)       tar xvzf $1     ;;
            *.zip)       unzip $1        ;;
            *.Z)         uncompress $1   ;;
            *.7z)        7z x $1         ;;
            *)           echo "'$1' cannot be extracted via >extract<" ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

# Get current host related info.
function ii() {
    echo -e "\nYou are logged on ${BRed}$HOST"
    echo -e "\n${BRed}Additionnal information:$NC " ; uname -a
    echo -e "\n${BRed}Users logged on:$NC " ; who |
             cut -d " " -f1 | sort | uniq
    echo -e "\n${BRed}Current date :$NC " ; date
    echo -e "\n${BRed}Machine stats :$NC " ; uptime
    echo -e "\n${BRed}Memory stats :$NC " ; free
    echo -e "\n${BRed}Open connections :$NC "; netstat -pan --inet;
    echo
}

#compatibility check for pokemon terminolody theme
if [[ "$TERMINOLOGY" -eq "1" ]]; then
    pokemon random
fi

#Check for bash-insulter https://github.com/hkbakke/bash-insulter
if [ -f /etc/bash.command-not-found ]; then
    . /etc/bash.command-not-found
fi

#extended bashrc for specific comtputers (specific distros bashrc)
[[ -f ~/.extend.bashrc ]] && . ~/.extend.bashrc
#bash completion files completion
[ -r /usr/share/bash-completion/bash_completion   ] && . /usr/share/bash-completion/bash_completion
