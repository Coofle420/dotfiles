#!/bin/bash

# Set maximum refresh rates for both monitors
xrandr --output DisplayPort-0 --mode 1920x1080 --rate 164.96 \
       --output HDMI-A-0 --mode 1920x1080 --rate 144 --right-of DisplayPort-0
