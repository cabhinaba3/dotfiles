# Terminal & Desktop Environment Installer

Self-contained installer for the full terminal/desktop setup on Arch Linux.

## Quick Start

```bash
cd ~/Desktop/installs/terminal
chmod +x install.sh
./install.sh
```

Then reload i3: `i3-msg restart` (or log out / log back in).

## What's Included

| File | Installs To | Purpose |
|------|-------------|---------|
| `alacritty.toml` | `~/.config/alacritty/alacritty.toml` | Terminal emulator (Nord, font 7.0) |
| `starship.toml` | `~/.config/starship.toml` | Prompt (Nord, k8s disabled) |
| `bashrc_hacker` | `~/.bashrc_hacker` | Shell aliases, FZF, neofetch |
| `tmux.conf` | `~/.tmux.conf` | Tmux (Nord, Ctrl-a prefix) |
| `i3.config` | `~/.config/i3/config` | Window manager (Nord, font 7) |
| `set_wallpaper.sh` | `~/.config/i3/set_wallpaper.sh` | Video wallpaper via mpv |
| `launch_alacritty_monitors.sh` | `~/.config/i3/launch_alacritty_monitors.sh` | Auto-launch terminals |
| `picom.conf` | `~/.config/picom/picom.conf` | Compositor (transparency, fading) |
| `i3status.conf` | `~/.config/i3status/config` | Status bar (Nord) |
| `gtk-3.0-settings.ini` | `~/.config/gtk-3.0/settings.ini` | GTK cursor theme |
| `default-cursor-index.theme` | `~/.icons/default/index.theme` | X11 default cursor |

## Packages Installed

The script auto-installs (via `pacman`) any missing packages:

`alacritty` `starship` `tmux` `picom` `mpv` `i3-wm` `i3status` `fzf` `eza` `bat` `ripgrep` `fd` `git-delta` `dust` `duf` `bottom` `procs` `fastfetch` `xorg-xsetroot` `i3lock` `dunst` `j4-dmenu-desktop` `ttf-jetbrains-mono-nerd`

## Extras

- **Dracula cursor theme** — downloaded from GitHub and installed to `~/.icons/`
- **Video wallpaper** — requires `~/Pictures/nfs_wallpaper.mp4`
- **Backups** — existing configs are saved to `~/.config-backups/terminal-<timestamp>/`
