# dotfiles

Portable bootstrap for my development environment: shell, terminal,
editor, i3/X11 desktop, Git, SSH (opt-in), and Claude Code — auto-detects
the distro, package manager, init system, shell, and desktop session
instead of assuming any of them.

```bash
cd ~/dotfiles
./install.sh
```

Re-running is safe — every step is idempotent, and anything that would
be overwritten gets backed up first to `~/.dotfiles-backup/<timestamp>/`.

## What's in here

| Directory | Installs to | Notes |
|---|---|---|
| `bash/` | `~/.bashrc`, `~/.bash_profile`, `~/.profile`, `~/.bashrc.interactive` | managed blocks in the rc files (not full replacement), modular aliases/functions/env |
| `git/` | `~/.config/git/ignore` + `git config --global` keys | never overwrites your whole `~/.gitconfig` |
| `ssh/` | nothing automatically | opt-in templates only, see `ssh/README.md` |
| `tmux/`, `starship/`, `nvim/`, `alacritty/` | the obvious `~/.config/...` path each tool expects | plain symlinks |
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

## Keyboard Shortcuts & Keybindings (Custom & Overridden)

Detailed reference of all keyboard shortcuts configured across the environment, highlighting customized and overridden defaults.

### 1. i3 Window Manager

* **Modifier Keys:** `$mod` = `Super` (Windows Key), `$alt` = `Alt`

| Shortcut | Action | Notes / Overrides |
|---|---|---|
| **Applications & System** | | |
| `$mod + Enter` | Launch Terminal (**Alacritty**) | **Overridden:** Launches Alacritty directly instead of xterm |
| `$mod + Space` | Application Launcher | **Overridden:** Uses `j4-dmenu-desktop` / `dmenu` |
| `$mod + q` | Close / Kill focused window | Standard i3 kill |
| `$mod + Shift + r` | **Restart i3 in-place** | Reloads config, restarts `picom` & wallpaper without closing apps |
| `$mod + Shift + c` | Reload i3 configuration | Reloads config file without restarting processes |
| `$mod + Shift + e` | Exit i3 session | Prompts to log out of X11 |
| `$mod + Pause` | Lock Screen | Invokes `i3lock` |
| **Window Navigation & Layout** | | |
| `$mod + h / j / k / l` | Focus Left / Down / Up / Right | **Custom:** Vim-style directional focus (arrow keys also supported) |
| `$mod + Shift + h / j / k / l` | Move window Left / Down / Up / Right | Vim-style directional window movement |
| `$mod + b` | Split next window **Horizontally** | Side-by-side tile |
| `$mod + v` | Split next window **Vertically** | Top/bottom tile |
| `$mod + f` | Toggle Fullscreen | Maximizes focused container |
| `$mod + s` | Stacking Layout | All windows stacked vertically with title tabs |
| `$mod + w` | Tabbed Layout | Windows organized as tabs |
| `$mod + e` | Toggle Split Layout | Cycles between horizontal and vertical tiling |
| `$mod + Shift + Space` | Toggle Floating Mode | Detaches window from tiling grid |
| `$mod + a` | Focus Parent Container | Ascends container tree |
| **Workspaces** | | |
| `$mod + 1 .. 0` | Switch to Workspace 1–10 | Instant workspace jump |
| `$mod + Shift + 1 .. 0` | Move focused window to Workspace 1–10 | Moves active window to target workspace |
| **Media & Hardware Controls** | | |
| `XF86AudioRaiseVolume` | Volume +5% | Controlled via `pamixer -i 5` |
| `XF86AudioLowerVolume` | Volume -5% | Controlled via `pamixer -d 5` |
| `XF86AudioMute` | Toggle Audio Mute | Controlled via `pamixer -t` |
| `XF86MonBrightnessUp` | Brightness +5% | Controlled via `brightnessctl set +5%` |
| `XF86MonBrightnessDown` | Brightness -5% | Controlled via `brightnessctl set 5%-` |

---

### 2. Tmux (Terminal Multiplexer)

* **Prefix Key Overridden:** **`Ctrl-a`** *(Default `Ctrl-b` is unbinded and replaced)*

| Shortcut | Action | Notes / Overrides |
|---|---|---|
| **Pane Navigation (Prefix-free)** | | |
| **`Alt + h`** | Focus pane Left | **Custom Override:** No prefix needed! Instant Vim pane jump |
| **`Alt + j`** | Focus pane Down | **Custom Override:** No prefix needed! Instant Vim pane jump |
| **`Alt + k`** | Focus pane Up | **Custom Override:** No prefix needed! Instant Vim pane jump |
| **`Alt + l`** | Focus pane Right | **Custom Override:** No prefix needed! Instant Vim pane jump |
| **Pane & Window Management** | | |
| `Ctrl-a |` | Split pane **Horizontally** | **Overridden:** Replaces `"`, preserves current working directory |
| `Ctrl-a -` | Split pane **Vertically** | **Overridden:** Replaces `%`, preserves current working directory |
| `Ctrl-a c` | Create new window | **Overridden:** Preserves current working directory |
| `Ctrl-a z` | Toggle pane zoom | Maximizes focused pane to fullscreen |
| `Ctrl-a x` | Close active pane | Prompts to kill pane |
| `Ctrl-a ,` | Rename current window | Prompts for new name |
| `Ctrl-a n` / `Ctrl-a p` | Next / previous window | Cycle through windows |
| `Ctrl-a &` | Close current window | Kills current window and its panes |
| `Ctrl-a r` | Reload Tmux config | Displays confirmation message on status bar |
| `Ctrl-a d` | Detach session | Leaves tmux session running in background |
| **Vi Copy Mode** | | |
| `Ctrl-a [` | Enter Vi Copy Mode | Scroll history using `h/j/k/l`, `Ctrl-u`, `Ctrl-d` |
| `v` *(in copy mode)* | Begin text selection | Standard Vi visual selection |
| `y` *(in copy mode)* | Yank selection to system clipboard | **Custom:** Pipes selection to `xclip` / `wl-copy` and exits |

---

### 3. Neovim (`nvim`)

* **Leader Key:** **`<Space>`**

| Category | Shortcut | Action |
|---|---|---|
| **General** | `<leader>e` | Toggle file explorer tree (Nvim-tree) |
| | `<Esc>` *(Normal mode)* | Clear search highlights |
| **Search (Telescope)** | `<leader>sf` | Search files by name |
| | `<leader>sg` | Live project-wide grep |
| | `<leader><leader>` | Fuzzy find active open buffers |
| | `<leader>sd` | Search diagnostics / lint warnings |
| | `<leader>sh` | Search Vim help tags |
| | `<leader>sk` | Search configured keymaps |
| **LSP (Code Navigation)** | `gd` | Go to definition |
| | `gr` | Go to references |
| | `gI` | Go to implementation |
| | `<leader>D` | Go to type definition |
| | `K` | Hover symbol documentation |
| | `<leader>rn` | Rename symbol across project |
| | `<leader>ca` | Code actions / auto-fixes |
| | `[d` / `]d` | Previous / next diagnostic message |
| | `<leader>q` | Populate diagnostic quickfix list |
| **Completion (Insert mode)**| `<C-Space>` | Manually trigger autocompletion popup |
| | `<C-y>` | Confirm autocompletion suggestion |
| | `<C-n>` / `<C-p>` | Select next / previous completion candidate |

---

### 4. Alacritty Terminal Emulator

| Shortcut | Action | Notes |
|---|---|---|
| `Ctrl + Shift + V` / `Shift + Insert` | Paste from clipboard | Safe terminal paste |
| `Ctrl + Shift + C` | Copy selected text | Copies selection to system clipboard |
| `Ctrl + Shift + F` | Search forward in scrollback | Interactive regex / text search |
| `Ctrl + Shift + B` | Search backward in scrollback | Backward buffer search |
| `Ctrl + Shift + T` | Spawn new terminal instance | Opens duplicate Alacritty window |
| `Ctrl + Plus` / `Ctrl + =` | Increase font size | Zooms in text |
| `Ctrl + Minus` | Decrease font size | Zooms out text |
| `Ctrl + 0` | Reset font size | Restores default 7.0 pt font |

---

### 5. Shell Aliases & Shortcuts (Bash)

| Category | Command / Alias | Action |
|---|---|---|
| **Modern CLI Replacements** | `ls`, `ll`, `lt` | `eza` (colored list, detailed list, recursive tree) |
| | `cat <file>` | `bat` (syntax highlighting, line numbers) |
| | `grep <pattern>` | `rg` (ripgrep - fast multi-threaded search) |
| | `find <pattern>` | `fd` (intuitive regex find, ignores `.git`) |
| | `diff <f1> <f2>` | `delta` (side-by-side syntax-highlighted diff) |
| | `top` | `htop` (interactive process viewer) |
| | `sysinfo` | `fastfetch` (on-demand hardware/OS specifications) |
| **Git Shortcuts** | `gs` | `git status` |
| | `ga` | `git add` |
| | `gc` | `git commit` |
| | `gp` | `git push` |
| | `gl` | `git log --oneline --graph --decorate -20` |
| | `gd` | `git diff` |
| | `gco` | `git checkout` |
| | `gb` | `git branch` |
| **Navigation & Helpers** | `mkcd <dir>` | Creates directory path and immediately enters it |
| | `..`, `...`, `....` | Quick navigation up 1, 2, or 3 directories |
| | `extract <file>` | Universally extracts `.tar.gz`, `.zip`, `.7z`, `.tar.bz2`, etc. |
| | `Ctrl + r` | Interactive reverse history fuzzy search with **FZF** |

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
