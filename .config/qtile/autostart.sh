#!/bin/bash

# Set wallpaper
nitrogen --restore &

# Kill existing instances
killall -q picom

# Start picom with animations
picom --animations --animation-window-mass 0.5 --animation-for-open-window zoom --animation-stiffness 350 --corner-radius 12 --fade-in-step 0.05 --fade-out-step 0.05 --fade-delta 4 --inactive-dim 0.1 -b &

# Start notification daemon with custom theme
dunst -config ~/.config/dunst/dunstrc &

# Start network manager applet
nm-applet &

# Start volume control
volumeicon &

# Start battery icon (if laptop)
cbatticon -u 5 &

# Start clipboard manager
clipit &

# Start polkit authentication agent
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Set keyboard repeat rate
xset r rate 200 30 &

# Start music player daemon
mpd &
