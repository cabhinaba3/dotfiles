# dotfiles

Portable bootstrap for my development environment: shell, terminal,
editor, i3/X11 desktop, Git, SSH (opt-in), and Claude Code — auto-detects
the distro, package manager, init system, shell, and desktop session
instead of assuming any of them.

```bash
cd ~/Desktop/dotfiles
./install.sh
```

Re-running is safe — every step is idempotent, and anything that would
be overwritten gets backed up first to `~/.dotfiles-backup/<timestamp>/`.

## What's in here

| Directory | Installs to | Notes |
|---|---|---|
| `bash/` | `~/.bashrc`, `~/.bash_profile`, `~/.profile`, `~/.bashrc_hacker` | managed blocks in the rc files (not full replacement), Nord-themed aliases/functions |
| `git/` | `~/.config/git/ignore` + `git config --global` keys | never overwrites your whole `~/.gitconfig` |
| `ssh/` | nothing automatically | opt-in templates only, see `ssh/README.md` |
| `tmux/`, `starship/`, `nvim/`, `alacritty/`, `broot/` | the obvious `~/.config/...` path each tool expects | plain symlinks |
| `i3/`, `x11/` | `~/.config/i3*`, `~/.config/picom`, cursor theme | only when an X11 desktop session is detected |
| `claude/` | Claude Code binary + `~/.claude/settings.json` (if absent) | see `claude/README.md` for auth |
| `systemd/` | `~/.config/systemd/user/` | only the one genuinely user-authored unit found (`distant-manager`), templated, only if `distant` is installed |
| `packages/`, `scripts/` | n/a — the installer's own logic | see `docs/architecture.md` |
| `docs/` | n/a | portability/secrets/machine-specific notes + pre-existing cheat sheets |

## Usage

```bash
./install.sh --dry-run          # preview every action, change nothing
./install.sh                     # full install for the detected environment
./install.sh --minimal           # shell + git + Claude Code only, no desktop/dev packages
./install.sh --skip-desktop      # skip i3/X11 config even if detected
./install.sh --skip-claude       # skip Claude Code entirely
./install.sh --skip-packages     # link/configure only, install nothing via the package manager
./install.sh --full              # + optional packages + rustup, force everything on
./install.sh --help

./scripts/validate.sh            # PASS/WARN/FAIL/SKIP report of current state
./uninstall.sh [--dry-run]       # remove symlinks + managed rc blocks (not packages/Claude Code)
```

## How distribution detection works

`scripts/detect-os.sh` reads `/etc/os-release` (`ID`/`ID_LIKE`) and maps
it to one of `arch`/`debian`/`fedora`/`suse`/`alpine`/`gentoo`/`void`/
`nixos`; if that's inconclusive it falls back to probing for a known
package-manager binary. It also detects WSL (`/proc/version`,
`WSL_*` env vars), containers (`/.dockerenv`, `/run/.containerenv`,
cgroup contents), and VMs (`systemd-detect-virt`, when available —
never assumed present just because systemd is). `scripts/detect-shell.sh`
and `detect-desktop.sh` do the equivalent for the login shell and
desktop/display-server. See `docs/portability.md` for exactly what's
tested vs best-effort per distro.

## Secrets

A live `GEMINI_API_KEY` and this user's real SSH private key were found
during the audit that produced this repo — **neither is in here.**
Full accounting of what was found and excluded: `docs/secrets.md`.
Machine-local values (API keys, one-off aliases) belong in
`~/.bashrc.local`, which `bash/bashrc.block` sources if present and which
`.gitignore` refuses to ever track — copy `bash/local.env.example` there
to get started.

## Claude Code

Installed via the official native installer (matches how it was already
installed on the source machine — not npm, not a distro package).
Authentication is never scripted (OAuth is inherently interactive) — run
`claude` once on each new machine to log in. Full detail, including the
headless/CI token flow: `claude/README.md`.

## Portability

Directly verified on **Arch Linux** (the source machine). Debian/Ubuntu,
Fedora/RHEL, openSUSE, and Alpine have package-name mappings
(`packages/<family>.sh`) but are best-effort/untested. Gentoo, Void, and
NixOS are detected but have no package mapping yet — `install.sh` will
still configure shell/git/Claude Code, just skip package installation.
Full breakdown of what's portable vs distro-specific vs not portable at
all: `docs/portability.md`. What was deliberately excluded as
machine-specific: `docs/machine-specific.md`.

## Adding support for another distribution

1. Add a `packages/<family>.sh` with `pkg_install`, `pkg_is_installed`,
   `pkg_refresh`, and a `PKG_MAP` array for any package names that differ
   from `packages/manifest.sh`'s common names.
2. Add the family to the `case` in `scripts/detect-os.sh:detect_os`.
3. Run `./install.sh --dry-run` on that distro and check the package list
   it resolves looks right before running for real.

## Uninstalling

`./uninstall.sh` removes symlinks that point into this repo and strips
the managed blocks back out of your rc files. It does **not** uninstall
any installed software (packages, Claude Code, rustup) — see the
script's own output for exactly what it touched.
