#!/bin/sh

# load Xresources - solarized colors is default
COLORS="/dev/null"
export ANSI_COLORS='none'
/usr/bin/xrdb -merge ~/.Xresources; xrdb -merge "$COLORS"
[ $COLORS = '/dev/null' ] && export ANSI_COLORS='solarized'

# Nvidia display user settings
[ -r ~/.nvidia-settings-rc ] && nvidia-settings --load-config-only

# Enable DPMS (Energy Star) features
/usr/bin/xset +dpms

# Decrease keyboard repeat delay (ms)
# Set mouse accel/threshold and turn off keyboard beep
/usr/bin/xset mouse 45/10 70 r rate 180 40 b off

# Map CapsLock to Control
/usr/bin/xmodmap -e 'remove lock = Caps_Lock' \
                 -e 'add control = Caps_Lock' \
                 -e 'keysym Caps_Lock = Control_L'

# start start specific xsession
#exec dbus-launch --sh-syntax --exit-with-session bspwm &> /run/user/1000/xsession.log
bspwm &> /run/user/1000/xsession.log
