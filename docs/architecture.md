# Architecture

## How the audit was performed

This repo was built by inspecting a running Arch Linux machine end-to-end:
`/etc/os-release`, kernel/arch/virtualization signals, the active package
manager and its explicitly-installed package list, the full shell
startup chain (`.profile` → `.bash_profile` → `.bashrc` → `.bashrc_hacker`),
every dotfile under `~/.config` that had non-default content, `~/.gitconfig`
and `~/.ssh/config`, the Claude Code install directory and `settings.json`,
systemd `--user` units, and the active desktop session (i3 on X11, GDM).
See `docs/machine-specific.md` for what that audit found but excluded.

## Layout

```
install.sh              main entrypoint (detect -> packages -> config -> validate)
uninstall.sh             removes symlinks + managed rc blocks, nothing else
scripts/
  lib.sh                 logging, dry-run-aware `run`, backup, `link`, `install_block`
  detect-os.sh            distro family / package manager / arch / wsl / container / vm
  detect-shell.sh          login shell + what's installed
  detect-desktop.sh        DE/WM + X11 vs Wayland
  install-packages.sh      manifest -> distro package names -> install
  install-claude.sh        thin wrapper around claude/install.sh
  install-rust.sh          rustup (the one active version manager found)
  install-node.sh          no-sudo npm global prefix
  configure-git.sh         `git config --global` (never touches ~/.gitconfig wholesale)
  link-configs.sh          symlinks + managed-block installs for everything else
  backup-existing.sh       pre-flight backup of anything install.sh would replace
  validate.sh              PASS/WARN/FAIL/SKIP checks, run standalone any time
packages/
  manifest.sh              categories: core, shell, modern-cli, development,
                            networking, desktop, optional -- common package names
  <family>.sh               per-distro name overrides + pkg_install/pkg_is_installed
claude/                    Claude Code install + non-secret settings template
bash/, git/, ssh/, tmux/, nvim/, starship/, alacritty/, i3/, x11/, broot/, systemd/
                            the actual portable config, one directory per tool
docs/                      this file, portability.md, secrets.md, machine-specific.md,
                            plus the pre-existing cheat sheets (Broot/Hacker Terminal/tmux+nvim)
```

## Design choices

- **rc files are edited, not replaced.** `~/.bashrc` on a fresh machine
  usually ships distro-provided content (aliases, a PS1). `install.sh`
  never symlinks or overwrites it — `install_block` (in `lib.sh`) injects
  an idempotent, clearly-marked region (`# >>> dotfiles:bashrc >>>` ...
  `# <<< dotfiles:bashrc <<<`) that it can safely re-run and update,
  leaving everything else in the file untouched.
- **Standalone config files ARE symlinked** (`~/.tmux.conf`,
  `~/.config/starship.toml`, etc.) because there's nothing else in those
  files to preserve — replacing them with a symlink into this repo is
  both simpler and means edits here take effect immediately everywhere.
- **Every symlink target is backed up first** if it exists and isn't
  already the correct symlink (`scripts/backup-existing.sh` +
  `lib.sh:backup_if_needed`), into `~/.dotfiles-backup/<timestamp>/`.
- **Git identity is never hardcoded.** `git/gitconfig.template` exists
  for reference, but `configure-git.sh` actually applies identity via
  `git config --global`, which only touches the `user.name`/`user.email`
  keys and leaves any pre-existing `~/.gitconfig` content (credential
  helpers, includes, signing config) alone.
- **Package installation degrades gracefully.** No mapping for your
  distro family, or no root/no `sudo`? `install-packages.sh` warns and
  skips rather than failing the whole run.
