#!/bin/bash

panel_volume() {
    while true; do
        volStatus=$(amixer get Master | tail -n 1 | cut -d '[' -f 4 | sed 's/].*//g')
        volLevel=$(amixer get Master | tail -n 1 | cut -d '[' -f 2 | sed 's/%.*//g')
        if [ "$volStatus" = 'on' ]; then
            # solarized green when on
            echo -e "volume\t^fg(#859900)vol:$volLevel"
        else
            # solarized red when muted
            echo -e "volume\t^fg(#dc322f)vol:$volLevel"
        fi
        sleep 1 || break
    done
}

panel_date() {
    while true; do
        printf 'date\t%(^fg(#eee8d5)%I:%M^fg(#586e75):%S %Y-%m-^fg(#eee8d5)%d)T\n'
        sleep 1 || break
    done
}

panel_gputemp() {
    while true; do
       echo -e "gpu\t^fg(#586e75)GPUtemp:^fg(#eee8d5)$(nvidia-smi | sed -n '9p' | awk '{ print $3 }')"
       sleep 1 || break
    done
}
