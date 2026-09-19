#!/bin/bash
# Kills any existing wallpaper mpv process and starts a new one
# Uses mpv --wid=0 to render directly on the X11 root window

# Kill any existing wallpaper mpv process if running
pkill -f "mpv.*--wid=0" 2>/dev/null || true

STATIC_WALLPAPER="$HOME/Pictures/wallpaper.jpg"

if [ -f "$STATIC_WALLPAPER" ] && command -v feh &>/dev/null; then
    feh --bg-fill "$STATIC_WALLPAPER"
elif [ -f "$HOME/Pictures/wallpaper.png" ] && command -v feh &>/dev/null; then
    feh --bg-fill "$HOME/Pictures/wallpaper.png"
elif command -v xsetroot &>/dev/null; then
    xsetroot -solid "#2E3440"
fi

