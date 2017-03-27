#!/bin/bash

if [ $(pgrep -cx panel.sh) -gt 1 ]; then
    echo "The panel is already running." >&2
    exit 1
fi

# Some variables
panel_height=18
panel_font='-*-tamzen-medium-*-*-*-12-*-*-*-*-*-*-*'
icon_font='-*-siji-*-*-*-*-10-*-*-*-*-*-*-*'
panel_BG='#073642'
panel_FG='#eee8d5'

green='#859900'
red='#dc322f'
yellow='#b58900'
blue='#268bd2'
violet='#6c71c4'
magenta='#d33682'
orange='#cb4b16'

uniq_linebuffered() {
    awk '$0 != l { print; l=$0; fflush(); }' "$@"
}

panel_volume() {
    while true; do
        local vol_status=$(amixer get Master | tail -n 1 | cut -d '[' -f 4 | sed 's/].*//g')
        local vol_level=$(amixer get Master | tail -n 1 | cut -d '[' -f 2 | sed 's/%.*//g')
        if [ "$vol_status" = 'on' ]; then
            local prefix='V'
        else
            local prefix='v'
        fi
        echo $prefix$vol_level
        sleep 1 || break
    done
}

panel_date() {
    while true; do
        printf "%(d%I:%M%{F#073642}:%S%{F-} %{F#073642}%Y-%m-%{F-}%d)T\n"
        sleep 1 || break
    done
}

panel_gputemp() {
    while true; do
       echo "g$(nvidia-smi | sed -n '9p' | awk '{ print $3 }')"
       sleep 1 || break
    done
}

panel_brightness() {
    # Maybe write an ACPI rule instead, but I need to learn how first....
    # OK so this is a bad idea, because this uses a ton of CPU cycles :<
    local bright=''
    while true; do
        read bright < /sys/class/backlight/acpi_video0/brightness
        echo "b$bright"
    done
}

bspc config top_padding $(($panel_height - $(bspc config window_gap) + 6))

# Lets do the Desktop status info first
(
    childpids=()

    bspc subscribe report &
    childpids+=( $! )

    panel_date &
    childpids+=( $! )

     panel_volume &
     childpids+=( $! )

     panel_gputemp &
     childpids+=( $! )

#    panel_brightness &
#    childpids+=( $! )

    trap "kill ${childpids[@]}; exit" INT TERM QUIT
    wait

) 2>>/run/user/1000/xsession.log 1> >(uniq_linebuffered) | (

while read -r line; do
    case ${line:0:1} in
        '>')
            IFS=':'
            set -- ${line#?}
            desktop_status=''

            for part in "$@"; do
                desktop_info=''
                value=${part#?}
                case ${part:0:1} in
                    'M')
                        # focused monitor
                        ;;
                    'm')
                        # unfocused monitor
                        ;;
                    'O')
                        # occupied and focused desktop
                        desktop_info="%{B$yellow}%{F$panel_BG} %{+u}${value}%{-u} %{F-}%{B-}"
                        ;;
                    'o')
                        # occupied and UNfocused desktop
                        desktop_info=" %{+u}${value}%{-u} "
                        ;;
                    'F')
                        # free and focused desktop
                        desktop_info="%{B$yellow}%{F$panel_BG} ${value} %{F-}%{B-}"
                        ;;
                    'f')
                        # free and UNfocused desktop
                        desktop_info=" ${value} "
                        ;;
                    'U')
                        # urgent and focused desktop
                        desktop_info="%{B$yellow}%{F$panel_BG} ${value} %{F-}%{B-}"
                        ;;
                    'u')
                        # urgent and UNfocused desktop
                        desktop_info=" ${value} "
                        ;;
                    'L')
                        # Layout type
                        if [ "$value" == 'M' ]; then
                            layout_info="%{T1}\uE001%{T-}"
                        else
                            layout_info="%{T1}\uE005%{T-}"
                        fi
                        ;;
                esac

                # Make desktops clickable
                desktop_status+=${desktop_info:+"%{A:bspc desktop -f $value:}$desktop_info%{A}"}
            done

            # Make layout area clickable
            layout_info="%{A:bspc desktop -l next:}$layout_info%{A}"
            ;;
        'd')
            line=${line#?}
            # Time
            date_info="%{B$violet} %{T2}\uE1B9%{T-} ${line%%$' *'} %{B-}"
            # Date
            date_info+="%{B$blue} %{T2}\uE265%{T-} ${line#$'* '} %{B-}"
            ;;
        'V' | 'v')
            if [ "${line:0:1}" = 'v' ]; then
                vol_icon="%{F$red}%{T2}\uE202%{T-}"
            elif [ "${line#?}" = '0' ]; then
                vol_icon="%{T2}\uE204%{T-}"
            else
                vol_icon="%{T2}\uE203%{T-}"
            fi

            vol_info="%{B$green} $vol_icon ${line#?}%%%{F-} %{B-}"
            ;;
        'g')
            gputemp_info="%{B$magenta} GPU:%{T2}\uE01D%{T-}${line#?} %{B-}"
            ;;
        'b')
            brightness="%{B$orange} %{T2}\uE1C3%{T-} ${line#?} %{B-}"
            ;;
    esac

    # Flush data
    echo -e "%{l} $layout_info $desktop_status %{r}$gputemp_info$vol_info$brightness$date_info"
done

) 2>>/run/user/1000/xsession.log | lemonbar -g x$panel_height -f $panel_font -f $icon_font \
                                            -B $panel_BG -F $panel_FG -u 2 \
                                            2>>/run/user/1000/xsession.log | bash -s
