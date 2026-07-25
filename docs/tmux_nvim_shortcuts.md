# Terminal Multiplexer & Neovim Shortcuts

This document outlines all the configured shortcuts for your Tmux and Neovim environments.

## Tmux Shortcuts

**Prefix Key:** `Ctrl-a`
*(Press and release this before executing standard Tmux commands)*

### Global & Session
- **`Ctrl-a` + `r`** : Reload Tmux configuration
- **`Ctrl-a` + `d`** : Detach from the current session
- **`tmux new -s <name>`** : Start a new session (from terminal)
- **`tmux a -t <name>`** : Attach to a session (from terminal)
- **`tmux ls`** : List sessions (from terminal)

### Window Management
- **`Ctrl-a` + `c`** : Create a new window
- **`Ctrl-a` + `,`** : Rename current window
- **`Ctrl-a` + `n`** : Switch to the next window
- **`Ctrl-a` + `p`** : Switch to the previous window
- **`Ctrl-a` + `&`** : Close the current window

### Pane Management
- **`Ctrl-a` + `|`** : Split pane horizontally (left/right)
- **`Ctrl-a` + `-`** : Split pane vertically (top/bottom)
- **`Ctrl-a` + `z`** : Toggle pane zoom (fullscreen)
- **`Ctrl-a` + `x`** : Close pane
- **`Alt` + `h` / `j` / `k` / `l`** : Navigate panes (Left/Down/Up/Right) - *No prefix needed!*

---

## Neovim Shortcuts

**Leader Key:** `<Space>`

### General
- **`<Esc>`** (Normal Mode) : Clear search highlights
- **`<leader>e`** : Toggle File Explorer sidebar (Nvim-tree)

### Search (Telescope)
- **`<leader>sf`** : Search Files
- **`<leader>sg`** : Search by Grep (live grep)
- **`<leader><leader>`** : Find existing buffers
- **`<leader>sd`** : Search Diagnostics
- **`<leader>sh`** : Search Help tags
- **`<leader>sk`** : Search Keymaps

### Language Server Protocol (LSP)
- **`gd`** : Goto Definition
- **`gr`** : Goto References
- **`gI`** : Goto Implementation
- **`<leader>D`** : Type Definition
- **`<leader>rn`** : Rename symbol under cursor
- **`<leader>ca`** : Code Action (e.g., auto-imports, fixes)
- **`K`** : Hover Documentation
- **`[d`** : Go to previous Diagnostic message
- **`]d`** : Go to next Diagnostic message
- **`<leader>q`** : Open diagnostic Quickfix list

### Autocompletion (Insert Mode)
- **`<C-n>`** : Select next completion item
- **`<C-p>`** : Select previous completion item
- **`<C-y>`** : Confirm completion
- **`<C-Space>`** : Manually trigger completion
