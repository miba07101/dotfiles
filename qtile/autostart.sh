#!/bin/bash

udiskie -t -n &
nm-applet &
blueman-applet &
setxkbmap -layout 'us,sk' &
# feh --randomize --bg-fill ~/.config/qtile/wallpapers/ &
# monitor setup
bash ~/.config/qtile/scripts/monitor.sh ext_monitor &

