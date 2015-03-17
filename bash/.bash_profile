#-------------------------------------------------------------------------------
# LOCAL USER BASH PROFILE SOURCED BY LOGIN SHELL
# ~/.bash_profile
#-------------------------------------------------------------------------------

# Set my own umask to be more restrictive than default
umask 066

# SOURCE LOCAL BASH CONFIG
if test "$PS1" && test "$BASH" && test -r ~/.bashrc; then
    source ~/.bashrc
fi

