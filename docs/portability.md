# Portability

## Tested against

Directly: **Arch Linux** (the source machine — pacman, systemd, i3/X11,
bash). Everything else below is supported by construction (the detection
and package-mapping logic explicitly handles it) but **not verified on
real hardware/VMs of those distros** — treat as best-effort until you've
run it there once.

| Distro family | Package manager | Mapping file | Status |
|---|---|---|---|
| Arch / Manjaro / EndeavourOS | pacman (+ optional yay/paru) | `packages/arch.sh` | tested (source machine) |
| Debian / Ubuntu / Mint / Pop!_OS | apt | `packages/debian.sh` | best-effort |
| Fedora / RHEL / CentOS / Rocky / Alma | dnf/yum | `packages/fedora.sh` | best-effort |
| openSUSE (Leap/Tumbleweed) | zypper | `packages/opensuse.sh` | best-effort |
| Alpine | apk | `packages/alpine.sh` | best-effort; musl libc may break prebuilt-glibc binaries (rustup toolchains, some releases) |
| Gentoo, Void, NixOS, others | emerge / xbps / nix | none yet | `install.sh` detects these (`DOTFILES_DISTRO_FAMILY`) but has no package-name mapping -- it warns and skips package installation rather than guessing; config linking/git/Claude Code still work since they don't depend on a package manager |

Not attempted: macOS, BSDs, non-Linux systems generally. This repo is
Linux-only by design (see the master brief).

## What should work anywhere (Linux)

- Shell config (`bash/`) -- pure POSIX-ish bash, no distro assumptions,
  every tool-specific alias is `command -v` guarded.
- tmux, Neovim, Starship, Alacritty configs -- portable file formats, no
  hardcoded paths.
- Git configuration -- uses `git config --global`, not file replacement.
- Claude Code installation -- the official installer is distro-agnostic
  (installs under `$HOME`, no root).
- `scripts/detect-os.sh` / `detect-shell.sh` / `detect-desktop.sh` --
  written to degrade to sane defaults rather than assume a specific tool
  exists (e.g. doesn't assume `systemd-detect-virt` exists just because
  `systemd` does).

## What requires distro-specific handling

- Package name translation (`packages/<family>.sh`) — package names
  genuinely differ (`ripgrep` vs `rg`... no wait, but e.g. Debian's
  `eza` isn't in older releases and may need `exa`, Fedora's dev tools
  group is `@development-tools` not a single package, etc). Extend the
  relevant `packages/<family>.sh` file if you hit a gap.
- AUR (Arch-only), the exact desktop package set (GNOME vs KDE vs XFCE
  ship completely different package names for "the desktop").

## What cannot be ported automatically

- **The i3/X11 desktop stack** (`i3/`, `x11/`) assumes i3 on X11. It will
  not do anything useful under Wayland (Sway/Hyprland/GNOME-Wayland/KDE-
  Wayland) or under a different X11 WM — `scripts/detect-desktop.sh`
  detects this and `install.sh` skips desktop linking when it doesn't
  see an X11 session (override with `--full`, but the config just won't
  apply to your WM).
- **GNOME's own settings** (the source machine had GNOME installed
  alongside i3, selectable at the GDM login screen). GNOME preferences
  live in `dconf`, a binary database, not text config — genuinely not
  meaningful to "dotfile." See `docs/machine-specific.md`.
- **SSH host config** — inherently personal (which remote hosts exist,
  which usernames/keys). Provided only as opt-in templates in `ssh/`,
  never auto-installed.
- **Claude Code authentication** — OAuth login is interactive by nature.
  See `claude/README.md`.
- **Hardware-specific tuning** (zram size, specific kernel choice,
  autorandr monitor profiles) — machine-specific, not captured.

## Environment classes

`scripts/detect-os.sh` classifies the target as `desktop`, `server`,
`vm`, `container`, or `wsl` (`DOTFILES_ENV_CLASS`). `install.sh` uses
this to decide whether to attempt desktop-stack linking at all (skipped
outside a desktop-class X11 session, or with `--skip-desktop`). Container
and WSL environments get full shell/git/dev-tooling setup but never
desktop config, since there's normally no compositor to configure.
