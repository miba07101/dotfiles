#!/bin/bash

poweroff_text="   Power Off"
reboot_text="   Restart"
logout_text="   Log Out"

chosen=$(echo -e "$poweroff_text\n$reboot_text\n$logout_text" | rofi -dmenu -i -p "Power Menu:")

if [[ $chosen = $poweroff_text ]]; then
	systemctl poweroff
elif [[ $chosen = $reboot_text ]]; then
	systemctl reboot
elif [[ $chosen = $logout_text ]]; then
	pkill -KILL -u $USER
fi
