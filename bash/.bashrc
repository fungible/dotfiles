#-------------------------------------------------------------------------------
# LOCAL USER BASHRC FILE
# ~/.bashrc
# FOR INTERACTIVE SHELLS
#-------------------------------------------------------------------------------

# < ENVIRONMENT VARIABLES >
export SUDO_EDITOR='/usr/bin/rvim --noplugin'
export VISUAL='/usr/bin/vim'
export EDITOR='/usr/bin/vim'
export BROWSER=firefox
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoredups:ereasedups
HISTSIZE=2500
HISTFILESIZE=10000
export PROMPT_COMMAND="history -a;history -n;"

# IF NOT RUNNING INTERACTIVELY, THEN RETURN, EVERYTHING BELOW APPLIES TO
# AN INTERACTIVE SHELL
[[ $- != *i* ]] && return
[ ! "$UID" = "0" ] && archbey2


# < SHELL OPTIONS >
# SHELL OPTIONS MAY TAKE ARGUMENTS
# FOR REFERENCE SEE LINK BELOW
# [http://www.gnu.org/software/bash/manual/bashref.html#The-Set-Builtin]
#set -o vi		# vi command line editing mode / readline mode
set -o ignoreeof	# prevent CTRL-D from closing shell
set -m			# turn on job control


# < SHELL OPTIONAL BEHAVIOR >
# SHELL OPTIONALS ARE BOOLEAN VALS EITHER ON OR OFF
# FOR REFERENCE SEE LINK BELOW
# [http://www.gnu.org/software/bash/manual/bashref.html#The-Shopt-Builtin]
shopt -s histappend	# append to history instead of overwriting
shopt -s checkwinsize	# check window size and update LINES & COLUMNS
shopt -s globstar	# '**' matches everything
shopt -s checkhash	# check hash cache of command good for lots of $PATHS
shopt -s extglob	# extended globs allows for regex globbing
shopt -s shift_verbose	# may be helpful when using shift builtin
shopt -s checkjobs	# warn about running jobs when attempting to exit


# < PROMPT SETUP >
# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    *color*) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# < PROMPT PS1 >
if [ "$color_prompt" = yes ]; then
    # let's not use raw escapes
    reset=$(tput sgr0)
    bold=$(tput bold)
    # Init the ANSI-16 colors
    for i in {0..15}; do
       colorfg[$i]=$(tput setaf $i)
       colorbg[$i]=$(tput setab $i)
    done

    am_i_root() {
       char='»'
       if [ "$UID" = "0" ]; then
          echo -ne "\[${colorfg[1]}\]$char\[$reset\]"
       else
          echo -ne "$char"
       fi
    }

    #╔═╚═┌─┐└─ line drawing stuff
    PS1="┌─![\[${colorfg[6]}$bold\]\w\[$reset\]]%\n└╼━ $(am_i_root) "
    PS2='\[${colorfg[3]}\]•••\[$reset\] » '
else
    PS1='<\d|\@> \u [\w]\$ '
    PS2='[...:>'
fi
unset color_prompt force_color_prompt

# < ALIAS DEFINITIONS >
# SOURCE MAH ~/.bash_aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# < FUNCTION DEFINITIONS >
# SOURCE MAH ~/.bash_func
if [ -f ~/.bash_func ]; then
    . ~/.bash_func
fi

# PKGFILE COMMAND NOT FOUND HOOK
if [ -r /usr/share/doc/pkgfile/command-not-found.bash ]; then
   source /usr/share/doc/pkgfile/command-not-found.bash
fi
