#-------------------------------------------------------------------------------
# FILE FOR BASH ALIASES
# ~/.bash_aliases
# SOURCED BY ~/.bashrc
#-------------------------------------------------------------------------------


# ENABLE COLOR SUPPORT OF LS AND ALSO ADD HANDY ALIASES
if [ -x /usr/bin/dircolors ]; then
    if [ "$ANSI_COLORS" = 'solarized' ]; then
        # ~/.dircolors contains colors optimized for solarized
        [ -r ~/.dircolors ] && eval $(dircolors -b ~/.dircolors)
    else
        eval $(dircolors -b)
    fi
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi


# SOME COMMONLY USED COMMAND ALIASES
alias vi='vim'
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias lR='ls -R'	# RECURSIVE
alias l1='ls -1'	# SINGLE COLUMN
alias lx='ll -BX'	# SORT BY EXTENSION
alias lz='ll -rS'	# SORT BY SIZE
alias lt='ll -rt'	# SORT BY TIME
alias lless='ll | less'
alias diff='colordiff'
alias mkdir='mkdir -p -v'
alias update-grub='grub-mkconfig -o /boot/grub/grub.cfg'
alias free='free -ht'
alias vpager='vimpager'
alias vless='/usr/share/vim/vim/macros/less.sh'
alias lock='slimlock'
alias iotop='iotop -Poa'
alias vread='vim -RM'   # vim readonly+nonmodifiable


# SAFETY FEATURES
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias ln='ln -i'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# PRIVILEGED ACCESS
if [ $UID -ne 0 ]; then
    alias sudo='sudo '
    alias svim='sudoedit'
    alias rootsh='sudo -s'
fi

# ADD AN "ALERT" ALIAS FOR LONG RUNNING COMMANDS.  USE LIKE SO:
# > sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# PACMAN ALIASES
alias pacsync='sudo pacman -Sy'		# Sync packages from repo
alias pacupdate='sudo pacman -Syu'	# Sync and update packages from repo
alias pacinstall='sudo pacman -S'	# Install specific package(s) from repo
alias pacremove='sudo pacman -Rns'	# Remove specified package(s) w/configs
alias pacrepinfo='pacman -Si'		# Package info from repo
alias pacrepsearch='pacman -Ss'		# Search repo
alias pacdbinfo='pacman -Qi'		# Package info from local database
alias pacdbsearch='pacman -Qs'		# Search local database
alias pacorphans='pacman -Qdt'		# List orphaned packages
alias pactoplvl='pacman -Qt'		# List top-level packages
alias paclf='pacman -Ql'		# List files installed by given package
alias pacowns='pacman -Qo'		# List packages that own the given file
alias pacclean='paccache -r && paccache -ruk0'	# clean cache of packages not installed

# PACAUR
alias aur='pacaur'
_completion_loader pacaur
complete -F _pacaur -o default aur

# SYSTEMCTL
alias sysd='systemctl'
complete -F _systemctl sysd

# XRDB
alias redb='xrdb -merge ~/.Xresources'

# HERBSTCLIENT
alias hc='herbstclient'
complete -F _herbstclient_complete -o nospace hc
