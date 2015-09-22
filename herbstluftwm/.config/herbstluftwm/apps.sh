#!/bin/bash
{
   childpids=()

   compton -cCGb &
   childpids+=( $! )

   volumeicon &
   childpids+=( $! )

   redshift -l 37.39:-121.86 -t 6500:3100 &
   childpids+=( $! )

   herbstclient -w 'reload'
   kill ${childpids[@]}
   exit
} &>> /run/user/1000/xsession.log
