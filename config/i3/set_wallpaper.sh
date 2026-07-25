#!/bin/bash
# Kills any existing wallpaper mpv process and starts a new one
# Uses mpv --wid=0 to render directly on the X11 root window

killall -q mpv 2>/dev/null
sleep 0.5

WALLPAPER="$HOME/Pictures/nfs_wallpaper.mp4"

if ! command -v mpv &>/dev/null; then
    echo "mpv is not installed. Skipping video wallpaper."
    # Fallback: set a solid dark background
    xsetroot -solid "#2E3440" 2>/dev/null
    exit 0
fi

if [ ! -f "$WALLPAPER" ]; then
    echo "Wallpaper video not found at $WALLPAPER"
    xsetroot -solid "#2E3440" 2>/dev/null
    exit 0
fi

# --wid=0 renders on the root window (X11)
# --no-osc disables the on-screen controller
# --no-input-default-bindings prevents mpv from capturing keyboard
mpv \
    --wid=0 \
    --loop=inf \
    --no-audio \
    --no-osc \
    --no-input-default-bindings \
    --really-quiet \
    --panscan=1.0 \
    "$WALLPAPER" &

disown
