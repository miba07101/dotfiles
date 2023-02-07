#!/bin/bash
# monitor setup
INT="eDP-1"
EXT="HDMI-1"

# zapne externy monitor a vypne interny monitor
function connect(){
  xrandr --output $EXT --auto --output $INT --off
}

# zapne interny monitor a vypne externy
function disconnect(){
  xrandr --output $INT --auto --output $EXT --off
}

# prepinanie monitorov
function toggle_monitor(){
  if xrandr --listactivemonitors | grep "${EXT}"; then
    disconnect
  else
    connect
fi
}

# zisti ci je pripojeny externy monitor
function ext_monitor(){
  if xrandr | grep "${EXT} connected"; then
    connect
  else
    disconnect
fi
}

# aby spustilo funkciu
"$@"
