#!/bin/bash
{
   childpids=()

   compton -cCGb &
   childpids+=( $! )

   volumeicon &
   childpids+=( $! )

   redshift -l 37.39:-121.86 -t 6500:2350 -g 0.8:0.9:0.9 &
   childpids+=( $! )

   herbstclient -w 'reload'
   kill ${childpids[@]}
   exit
} &> /dev/null
