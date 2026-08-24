#!/usr/bin/env bash
# Detects the user's active/login shell and what else is installed.
# Sets:
#   DOTFILES_LOGIN_SHELL    - basename of the shell in /etc/passwd (or $SHELL)
#   DOTFILES_SHELLS_FOUND   - space-separated list: bash zsh fish
# Safe to source multiple times.

detect_shell() {
    local passwd_shell=""
    if has getent; then
        passwd_shell="$(getent passwd "$(id -un)" 2>/dev/null | cut -d: -f7)" || true
    fi
    [ -z "$passwd_shell" ] && passwd_shell="${SHELL:-/bin/bash}"
    DOTFILES_LOGIN_SHELL="$(basename "$passwd_shell")"

    DOTFILES_SHELLS_FOUND=""
    has bash && DOTFILES_SHELLS_FOUND="$DOTFILES_SHELLS_FOUND bash"
    has zsh  && DOTFILES_SHELLS_FOUND="$DOTFILES_SHELLS_FOUND zsh"
    has fish && DOTFILES_SHELLS_FOUND="$DOTFILES_SHELLS_FOUND fish"
    DOTFILES_SHELLS_FOUND="${DOTFILES_SHELLS_FOUND# }"

    export DOTFILES_LOGIN_SHELL DOTFILES_SHELLS_FOUND
}

detect_shell
