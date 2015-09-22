#!/bin/bash

#- INIT SOME STUFF
hc() { "${herbstclient_command[@]:-herbstclient}" "$@" ;}
monitor=${1:-0}
geometry=( $(herbstclient monitor_rect "$monitor") )

if [ -z "$geometry" ] ;then
    echo "Invalid monitor $monitor"
    exit 1
fi

# geometry has the format W H X Y
x=${geometry[0]}
y=${geometry[1]}
panel_width=${geometry[2]}
panel_height=18
font='-*-tamzen-medium-*-*-*-12-*-*-*-*-*-*-*'
bgcolor='#073642' #$(hc get frame_border_normal_color)
selbg='#b58900'  #$(hc get window_border_active_color)
selfg='#073642'
frame_gap=$(hc get frame_gap)

#-! Try to find textwidth binary.
# In e.g. Ubuntu, this is named dzen2-textwidth.
if which textwidth &> /dev/null ; then
    textwidth="textwidth";
elif which dzen2-textwidth &> /dev/null ; then
    textwidth="dzen2-textwidth";
else
    echo "This script requires the textwidth tool of the dzen2 project."
    exit 1
fi

#-! true if we are using the svn version of dzen2
# depending on version/distribution, this seems to have version strings like
# "dzen-" or "dzen-x.x.x-svn"
if dzen2 -v 2>&1 | head -n 1 | grep -q '^dzen-\([^,]*-svn\|\),'; then
    dzen2_svn="true"
else
    dzen2_svn=""
fi

#-! Filter out duplicates of events
if awk -Wv 2>/dev/null | head -1 | grep -q '^mawk'; then
    # mawk needs "-W interactive" to line-buffer stdout correctly
    # http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=593504
    uniq_linebuffered() {
    awk -W interactive '$0 != l { print ; l=$0 ; fflush(); }' "$@"
    }
else
    # other awk versions (e.g. gawk) issue a warning with "-W interactive", so
    # we don't want to use it there.
    uniq_linebuffered() {
    awk '$0 != l { print ; l=$0 ; fflush(); }' "$@"
    }
fi

[ -r $HOME/.config/herbstluftwm/panel_widgets.sh ] \
    && source $HOME/.config/herbstluftwm/panel_widgets.sh
hc pad $monitor $((panel_height-frame_gap+3))

(
   #-- Event generator --#
   # based on different input data (mpc, date, hlwm hooks, ...)
   # this generates events, formed like this:
   #   <eventname>\t<data> [...]

   # "date" output is checked once a second, but an event is only
   # generated if the output changed compared to the previous run.
   childpids=()

   panel_date &
   childpids+=( $! )

   panel_volume &
   childpids+=( $! )

   panel_gputemp &
   childpids+=( $! )

   herbstclient --idle &
   childpids+=( $! )

   herbstclient --wait '(reload|quit_panel)'
   kill "${childpids[@]}"
   exit

) 2>>/run/user/1000/xsession.log > >(uniq_linebuffered) | (

    # Intialize
    visible=true
    date=""
    windowtitle=""
    gputemp=""
    volume=""

    ### Data handling ###
    # This part handles the events generated in the event loop, and sets
    # internal variables based on them. The event and its arguments are
    # read into the array event, then action is taken depending on the event
    # name.
    # "Special" events (quit_panel/togglehidepanel/reload) are also handled
    # here.
    IFS=$'\t'
    read -ra tags <<< "$(hc tag_status $monitor)"
    while read -ra event; do

        # Parse event
        case "${event[0]}" in
            tag*)
                #echo "resetting tags" >&2
                read -ra tags <<< "$(hc tag_status $monitor)"
                ;;
            focus_changed|window_title_changed)
                windowtitle="${event[@]:2}"
                ;;
            date)
                #echo "resetting date" >&2
                date="${event[@]:1}"
                ;;
            volume)
                volume="${event[@]:1}"
                ;;
            gpu)
                gputemp="${event[@]:1}"
                ;;
            togglehidepanel)
                currentmonidx=$(hc list_monitors | sed -n '/\[FOCUS\]$/s/:.*//p')
                if [ "${event[1]}" -ne "$monitor" ] ; then
                    continue
                fi
                if [ "${event[1]}" = "current" ] && [ "$currentmonidx" -ne "$monitor" ] ; then
                    continue
                fi
                echo "^togglehide()"
                if $visible ; then
                    visible=false
                    hc pad $monitor 0
                else
                    visible=true
                    hc pad $monitor $((panel_height-frame_gap+3))
                fi
                ;;
            reload) exit ;;
            quit_panel) exit ;;
        esac

        # This part handles the tags on the left side
        # tags are separated by tabs
        for i in "${tags[@]}"; do
            # Tag status in first character
            case ${i:0:1} in
                '#')
                    echo -n "^bg($selbg)^fg($selfg)"
                    ;;
                '+')
                    echo -n "^bg(#9CA668)^fg(#141414)"
                    ;;
                ':')
                    echo -n "^bg()^fg(#eee8d5)"
                    ;;
                '!')
                    echo -n "^bg(#FF0675)^fg(#141414)"
                    ;;
                *)
                    echo -n "^bg()^fg(#586e75)"
                    ;;
            esac

            if [ ! -z "$dzen2_svn" ] ; then
                # clickable tags if using SVN dzen
                echo -n "^ca(1,\"${herbstclient_command[@]:-herbstclient}\" "
                echo -n "focus_monitor \"$monitor\" && "
                echo -n "\"${herbstclient_command[@]:-herbstclient}\" "
                echo -n "use \"${i:1}\") ${i:1} ^ca()"
            else
                # non-clickable tags if using older dzen
                echo -n " ${i:1} "
            fi
        done

        separator="^bg()^fg(#2aa198)|"
        bordercolor="#2aa198"

        # Window Title after Tags
        echo -n "$separator"
        echo -n "^bg()^fg(#eee8d5) ${windowtitle//^/^^}"

        # Right hand side status information
        right="$separator^bg() $gputemp $separator $volume $separator $date $separator"
        right_text_only=$(echo -n "$right" | sed 's.\^[^(]*([^)]*)..g')
        width=$($textwidth "$font" "$right_text_only")

        echo "^pa($(($panel_width - $width)))$right"
    done

    ### dzen2 ###
    # After the data is gathered and processed, the output of the previous block
    # gets piped to dzen2.
) 2>>/run/user/1000/xsession.log | dzen2 -w $panel_width -x $x -y $y -fn "$font" -h $panel_height \
    -e 'button3=;button4=exec:herbstclient use_index -1;button5=exec:herbstclient use_index +1' \
    -ta l -bg "$bgcolor" -fg '#efefef'
