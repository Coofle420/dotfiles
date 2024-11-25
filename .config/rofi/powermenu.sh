#!/bin/bash

# Options for powermenu
lock="   Lock"
logout="   Logout"
shutdown="   Shutdown"
reboot="   Restart"
suspend="   Sleep"

# Get answer from user
selected_option=$(echo "$lock
$logout
$shutdown
$reboot
$suspend" | rofi -dmenu \
                -i \
                -p "Power Menu" \
                -theme-str 'window {width: 400px;} listview {lines: 5;}')

# Do something based on selected option
case "$selected_option" in
    "$lock")
        i3lock -c 000000
        ;;
    "$logout")
        qtile cmd-obj -o cmd -f shutdown
        ;;
    "$shutdown")
        systemctl poweroff
        ;;
    "$reboot")
        systemctl reboot
        ;;
    "$suspend")
        systemctl suspend
        ;;
esac
