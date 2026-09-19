#!/usr/bin/env bash
# Detects desktop environment / window manager and display server.
# Sets:
#   DOTFILES_DE            - i3|gnome|kde|xfce|sway|hyprland|... or "" if headless
#   DOTFILES_DISPLAY_SERVER- x11|wayland|none
#   DOTFILES_HAS_DESKTOP   - 1|0
# Safe to source multiple times.

detect_desktop() {
    DOTFILES_DE="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-}}"
    DOTFILES_DISPLAY_SERVER="none"

    if [ -n "${WAYLAND_DISPLAY:-}" ] || [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
        DOTFILES_DISPLAY_SERVER="wayland"
    elif [ -n "${DISPLAY:-}" ] || [ "${XDG_SESSION_TYPE:-}" = "x11" ]; then
        DOTFILES_DISPLAY_SERVER="x11"
    fi

    if [ -z "$DOTFILES_DE" ]; then
        # Fall back to probing running processes for a WM we know about.
        for wm in i3 sway Hyprland bspwm awesome gnome-shell kwin_x11 kwin_wayland xfwm4 mutter; do
            if pgrep -x "$wm" >/dev/null 2>&1; then
                DOTFILES_DE="$wm"
                break
            fi
        done
    fi

    DOTFILES_HAS_DESKTOP=0
    if [ -n "$DOTFILES_DE" ] || [ "$DOTFILES_DISPLAY_SERVER" != "none" ]; then
        DOTFILES_HAS_DESKTOP=1
    fi

    export DOTFILES_DE DOTFILES_DISPLAY_SERVER DOTFILES_HAS_DESKTOP
}

detect_desktop
