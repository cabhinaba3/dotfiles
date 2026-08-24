# i3 / X11 desktop stack

Only installed when the target machine is running (or the user opts into)
an i3-on-X11 session — see `--skip-desktop` in the main `install.sh` and
`DOTFILES_HAS_DESKTOP` in `scripts/detect-desktop.sh`.

| File | Installs to |
|---|---|
| `config` | `~/.config/i3/config` |
| `i3status.config` | `~/.config/i3status/config` |
| `picom.conf` | `~/.config/picom/picom.conf` |
| `set_wallpaper.sh` | `~/.config/i3/set_wallpaper.sh` |
| `launch_alacritty_monitors.sh` | `~/.config/i3/launch_alacritty_monitors.sh` |

`set_wallpaper.sh` expects a video at `~/Pictures/nfs_wallpaper.mp4`; if it's
missing it falls back to a solid Nord-dark background automatically, so
this is optional — bring your own wallpaper video if you want it.

This machine also had GNOME installed side-by-side (GDM offers both an i3
and a GNOME session) — GNOME's own settings live in `dconf`, a binary
database, and are intentionally **not** captured here; see
`docs/machine-specific.md`.
