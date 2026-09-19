# Machine-specific state (deliberately not ported)

Everything below was found on the source machine during the audit and
excluded from this repo on purpose — either because it's inherently tied
to that one install, or because reproducing it would do more harm than
good on a different machine.

## Hardware / OS identity

- Hostname (`cohitherewer`), machine-id, boot-id
- Disk layout: single NVMe, 1G vfat ESP + ext4 root, specific PARTUUID
- RAM size (15Gi), exact CPU model (i7-1365U) — `scripts/detect-os.sh`
  only records the architecture (`x86_64`), never the exact chip
- zram swap configuration (4G zram0) — a tuning choice, not "config" in
  the dotfiles sense
- Kernel choice: `linux` (mainline) with `linux-lts` kept as a fallback
  boot option. That's a user preference, not something `install.sh`
  reproduces (it doesn't touch the bootloader at all)

## Installed software footprint, not "config"

- `/opt/{Citrix,containerd,docker-desktop,visual-studio-code,zotero}` —
  these are just where those specific packages happened to install
  themselves; installing the same packages via `install.sh`'s package
  step (or manually) recreates the software, this directory isn't
  something to copy
- `~/.local/bin/{agy,antigravity,antigravity-ide,distant,uv,uvx,pip*}` —
  either large standalone binaries or auto-generated shims. None of it
  is hand-written config; each tool's own installer (or the package
  manager) is the right way to get it onto a new machine. The one
  exception, `distant`, gets a templated systemd unit (see `systemd/`)
  *if* you've separately installed it.
- Flatpak and Snap binaries were present but **zero apps registered**
  through either — nothing to capture.
- The vendored `~/.config/alacritty/alacritty-theme/` directory (a full
  clone of the upstream `alacritty-theme` repo, ~140 theme files) isn't
  used by the active `alacritty.toml` (colors are inlined, not
  `import`ed) — not copied here; clone it yourself if you want
  theme-switching later.

## Desktop environment

- GNOME was installed side-by-side with i3 (GDM offers both sessions).
  This repo only ports the i3/picom/alacritty stack, which is plain-text
  and genuinely portable. GNOME's own preferences live in `dconf`
  (`~/.config/dconf/user`, a binary database) plus scattered
  `~/.config/{gnome-session,nautilus,evolution,epiphany,...}` state —
  none of that is meaningfully "dotfiles," and `dconf dump`/`load` is a
  GNOME-specific, fairly fragile mechanism this repo doesn't attempt to
  wrap.
- `~/.config/autorandr/` (monitor profiles) — tied to this laptop's
  specific external-monitor setup, not reproduced.
- The generic `.Xresources` file found (a large, mostly-commented-out
  bundle of stock xterm color themes, not custom-authored) — only the
  Dracula-cursor-theme lines at its end were actually this user's doing;
  see `x11/Xresources.cursor`.

## Remote infrastructure

- The SSH config pointing at a personal imec iLab.t testbed (hostnames,
  usernames `abchakra`/`fffabchakra`) — real but personal; kept only as
  an opt-in template in `ssh/config.d/ilabt-testbed.example`, see
  `ssh/README.md`.

## Not part of "dotfiles" scope at all

- Per-project `.claude/` directories under project folders — per-project state, not user-level config.
