#!/bin/bash

# Load some scripts from default xinitrc.d directory
XINIT_DIR='/etc/X11/xinit/xinitrc.d'
[ -x ${XINIT_DIR}/xdg-user-dirs ] && source ${XINIT_DIR}/xdg-user-dirs
[ -x ${XINIT_DIR}/infinality-settings ] && source ${XINIT_DIR}/infinality-settings

# load Xresources - solarized colors is default
COLORS='/dev/null'
export ANSI_COLORS='none'
/usr/bin/xrdb -merge ~/.Xresources; xrdb -merge "$COLORS"
[ $COLORS = '/dev/null' ] && export ANSI_COLORS='solarized'

# turn on numlock
/usr/bin/setleds -D +num

# Enable DPMS (Energy Star) features
/usr/bin/xset +dpms

# Decrease keyboard repeat delay (ms)
# Set mouse accel/threshold and turn off keyboard beep
/usr/bin/xset mouse 45/10 70 r rate 180 40 b off

[ $1 == 'bspwm' ] && sxhkd &

# start start specific xsession
eval "dbus-launch --sh-syntax --exit-with-session $1 &> /run/user/1000/xsession.log"
logout
