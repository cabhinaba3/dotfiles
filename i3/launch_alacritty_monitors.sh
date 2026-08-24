#!/bin/bash
# launch_alacritty_monitors.sh
# Detects connected monitors and launches an Alacritty instance on each.

# Give i3 and xrandr a moment to initialize
sleep 2

# Get a list of connected monitors
monitors=$(xrandr --query | grep " connected" | cut -d" " -f1)

for m in $monitors; do
    # Tell i3 to focus the monitor
    i3-msg focus output $m
    # Launch Alacritty in the background
    alacritty &
    # Small sleep to ensure the window manager registers it before moving on
    sleep 0.5
done
