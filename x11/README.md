# X11 cursor theme (Dracula)

Optional, X11-only, installed as part of `--full` (or explicitly via
`scripts/install-desktop-extras.sh`) when `DOTFILES_DISPLAY_SERVER=x11`.

- `gtk-3.0-settings.ini` -> `~/.config/gtk-3.0/settings.ini`
- `default-cursor-index.theme` -> `~/.icons/default/index.theme`
- `Xresources.cursor` -> appended to `~/.Xresources` (only the cursor
  lines; this repo does not vendor a full `.Xresources` theme file — the
  one found on the source machine was a generic, third-party xterm color
  bundle unrelated to the user's actual daily terminal, Alacritty)
- Sets `XCURSOR_THEME=Dracula-cursors` / `XCURSOR_SIZE=24` in the shell
  profile block (see `bash/profile.block`)

The actual cursor theme files (`~/.icons/Dracula-cursors/`) are
downloaded from the [dracula/gtk](https://github.com/dracula/gtk) GitHub
releases by `scripts/install-desktop-extras.sh` — they're a third-party
asset, not something to vendor into this repo.
