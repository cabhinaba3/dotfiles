# Modern Terminal & Workflow Cheatsheet

A concise reference for the keybindings, aliases, and tools configured across the environment.

---

## 1. Tmux (Terminal Multiplexer)

**Prefix Key:** `Ctrl-a` *(Press and release before command)*

| Category | Shortcut / Command | Action |
| :--- | :--- | :--- |
| **Session** | `Ctrl-a d` | Detach from active session |
| | `Ctrl-a r` | Reload `~/.tmux.conf` |
| | `tmux new -s <name>` | Create new named session |
| | `tmux a -t <name>` | Attach to existing session |
| | `tmux ls` | List active sessions |
| **Windows** | `Ctrl-a c` | New window (retains current directory) |
| | `Ctrl-a ,` | Rename current window |
| | `Ctrl-a n` / `Ctrl-a p` | Next / previous window |
| | `Ctrl-a &` | Close window |
| **Panes** | `Ctrl-a \|` | Split horizontally (retains current directory) |
| | `Ctrl-a -` | Split vertically (retains current directory) |
| | `Ctrl-a z` | Toggle pane zoom (fullscreen) |
| | `Ctrl-a x` | Close active pane |
| | `Alt + h/j/k/l` | Navigate panes left/down/up/right (no prefix required) |
| **Copy Mode** | `Ctrl-a [` | Enter copy mode (Vi navigation) |
| | `v` (in copy mode) | Begin text selection |
| | `y` (in copy mode) | Yank selection to system clipboard and exit |

---

## 2. Modern CLI Utilities

| Classic | Modern Utility | Features | Examples |
| :--- | :--- | :--- | :--- |
| `ls` | **`eza`** | Colors, git status indicators, directory hierarchy | `ls`, `ll` (long view), `lt` (tree view) |
| `cat` | **`bat`** | Syntax highlighting, line numbers, git modifications | `cat file.py` |
| `grep` | **`rg`** *(ripgrep)* | High-speed multi-threaded search, respects `.gitignore` | `grep "pattern" .` |
| `find` | **`fd`** | Intuitive syntax, fast regex, respects `.gitignore` | `find "test.*\.rs$"` |
| `diff` | **`delta`** | Side-by-side syntax-highlighted diffs | `git diff` |
| `top` | **`htop`** | Interactive process manager and resource monitor | `top` |
| `sysinfo` | **`fastfetch`** | Instant, lightweight system specification display | `sysinfo` |

---

## 3. Shell Navigation & Functions

| Command | Action | Example |
| :--- | :--- | :--- |
| `mkcd` | Creates directory structure and immediately enters it | `mkcd src/components` |
| `..`, `...`, `....` | Quickly navigate up 1, 2, or 3 parent directories | `...` |
| `extract` | Universal extractor for archives (`.tar.gz`, `.zip`, `.7z`, etc.) | `extract archive.tar.gz` |
| `Ctrl+r` | Reverse history search powered by **`fzf`** (fuzzy matching) | Press `Ctrl+r`, type command fragment |

---

## 4. Git Shortcuts

| Alias | Target Command |
| :--- | :--- |
| `gs` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `gl` | `git log --oneline --graph --decorate -20` |
| `gd` | `git diff` |
| `gco` | `git checkout` |
| `gb` | `git branch` |

---

## 5. Neovim Shortcuts

**Leader Key:** `<Space>`

| Category | Shortcut | Action |
| :--- | :--- | :--- |
| **Navigation** | `<leader>e` | Toggle file explorer tree |
| | `<Esc>` | Clear search highlights |
| **Telescope** | `<leader>sf` | Search files by name |
| | `<leader>sg` | Live grep project contents |
| | `<leader><leader>` | Switch between active buffers |
| | `<leader>sd` | Search diagnostic messages |
| **LSP** | `gd` | Go to definition |
| | `gr` | Go to references |
| | `K` | Hover documentation |
| | `<leader>rn` | Rename symbol |
| | `<leader>ca` | Code actions |
| | `[d` / `]d` | Previous / next diagnostic |
| **Completion** | `<C-Space>` | Trigger autocompletion |
| | `<C-y>` | Confirm selection |
