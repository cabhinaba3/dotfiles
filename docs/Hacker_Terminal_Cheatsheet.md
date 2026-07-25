# Hacker Terminal Master Cheat Sheet

This guide covers all the custom shortcuts, modern CLI replacements, and tools configured in your new terminal environment.

## Tmux (Terminal Multiplexer)
Your prefix key has been changed from the default `Ctrl-b` to **`Ctrl-a`** for better ergonomics.

| Action | Shortcut |
| :--- | :--- |
| **Global Commands** | |
| Start new session | `tmux new -s <name>` |
| Attach to session | `tmux a -t <name>` |
| List sessions | `tmux ls` |
| Detach from session | `Ctrl-a d` |
| Reload config | `Ctrl-a r` |
| **Window Management** | |
| Create new window | `Ctrl-a c` |
| Rename current window | `Ctrl-a ,` |
| Switch to next window | `Ctrl-a n` |
| Switch to previous window | `Ctrl-a p` |
| Close window | `Ctrl-a &` |
| **Pane Management** | |
| Split horizontally (left/right) | `Ctrl-a |` |
| Split vertically (top/bottom) | `Ctrl-a -` |
| Navigate panes (Vim style) | `Alt + h/j/k/l` (No prefix needed!) |
| Toggle pane zoom (fullscreen) | `Ctrl-a z` |
| Close pane | `Ctrl-a x` |

## Modern CLI Replacements
We replaced legacy Unix commands with modern, Rust-based alternatives for speed and better defaults.

| Classic | Modern Alias | What it does better | Examples |
| :--- | :--- | :--- | :--- |
| `ls` | **`eza`** | Colors, git status, icons, tree views. | `ls` (standard view)<br>`ll` (detailed list)<br>`lt` (tree view) |
| `cat` | **`bat`** | Syntax highlighting, git integration, paging. | `cat file.json` |
| `grep` | **`rg`** (ripgrep) | Insanely fast, ignores `.gitignore` files by default. | `grep "TODO" .` |
| `find` | **`fd`** | Intuitive syntax, regex support, respects `.gitignore`. | `find .py$` (find python files) |
| `diff` | **`delta`** | Side-by-side syntax-highlighted diffs in git. | `diff file1 file2` |
| `du` | **`dust`** | Visual tree of disk space usage. | `du` (view space in current dir) |
| `df` | **`duf`** | Beautiful, readable disk usage overview. | `df` |
| `top` | **`btm`** (bottom) | Graphical, customizable system monitor. | `top` |
| `ps` | **`procs`** | Colorized process list with Docker/TCP details. | `ps nginx` |

## Custom Bash Functions & Shortcuts

| Command | Action | Example |
| :--- | :--- | :--- |
| `mkcd` | Creates a directory and instantly `cd`s into it. | `mkcd new_project` |
| `..`, `...`, `....` | Quickly move up 1, 2, or 3 directories. | `...` (moves up 2 dirs) |
| `extract` | Universally extracts *any* archive format (`.tar.gz`, `.zip`, `.rar`, etc.). | `extract archive.tar.gz` |
| `Ctrl+r` | Reverse history search powered by **`fzf`** (fuzzy finder). Type to fuzzy match past commands. | Press `Ctrl+r`, type `docker` |

## Git Aliases
Quick two-letter abbreviations for common Git operations.

| Alias | Full Command |
| :--- | :--- |
| `gs` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `gl` | `git log --oneline --graph --decorate -20` |
| `gd` | `git diff` |
| `gco` | `git checkout` |
| `gb` | `git branch` |

## Starship Prompt & Neofetch
*   **Prompt context:** The prompt will automatically show your current Python environment, Git branch/status, Docker presence, and Kubernetes context *only* when relevant.
*   **Execution Time:** If a command takes longer than 2 seconds, its duration will be shown on the right side of the prompt in cyan.
*   **Neofetch:** When you open a fresh terminal, `neofetch` runs automatically to display a stylish overview of your system specs.
