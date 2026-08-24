#!/usr/bin/env bash
# Configures Git non-destructively: sets individual keys with
# `git config --global` (never overwrites ~/.gitconfig wholesale, so any
# existing credential helper / signing config / includes survive), and
# links the global excludes file.
#
# Identity is never hardcoded into the repo. Resolution order:
#   1. already set in ~/.gitconfig -> leave untouched
#   2. $DOTFILES_GIT_NAME / $DOTFILES_GIT_EMAIL env vars
#   3. interactive prompt (skipped in --dry-run / --assume-yes / non-tty)

configure_git() {
    if ! has git; then
        warn "git not installed, skipping git configuration"
        return 0
    fi

    step "Configuring Git"

    local cur_name cur_email
    cur_name="$(git config --global user.name 2>/dev/null || true)"
    cur_email="$(git config --global user.email 2>/dev/null || true)"

    if [ -z "$cur_name" ] || [ -z "$cur_email" ]; then
        local name="${DOTFILES_GIT_NAME:-}" email="${DOTFILES_GIT_EMAIL:-}"
        if [ -z "$name" ] && [ -t 0 ] && [ "${DOTFILES_DRY_RUN:-0}" != 1 ] && [ "${DOTFILES_ASSUME_YES:-0}" != 1 ]; then
            printf "Git user.name not set. Enter it now (blank to skip): "
            read -r name
        fi
        if [ -z "$email" ] && [ -t 0 ] && [ "${DOTFILES_DRY_RUN:-0}" != 1 ] && [ "${DOTFILES_ASSUME_YES:-0}" != 1 ]; then
            printf "Git user.email not set. Enter it now (blank to skip): "
            read -r email
        fi
        if [ -n "$name" ]; then
            run "git config --global user.name" -- git config --global user.name "$name"
        fi
        if [ -n "$email" ]; then
            run "git config --global user.email" -- git config --global user.email "$email"
        fi
        [ -z "$name" ] && [ -z "$cur_name" ] && warn "git user.name still unset -- run: git config --global user.name \"Your Name\""
        [ -z "$email" ] && [ -z "$cur_email" ] && warn "git user.email still unset -- run: git config --global user.email you@example.com"
    else
        verbose "git identity already set ($cur_name <$cur_email>)"
    fi

    [ -n "$(git config --global init.defaultBranch 2>/dev/null || true)" ] || \
        run "git config init.defaultBranch main" -- git config --global init.defaultBranch main

    mkdir -p "$HOME/.config/git"
    link "$DOTFILES_ROOT/git/ignore" "$HOME/.config/git/ignore"
    run "git config core.excludesfile" -- git config --global core.excludesfile "$HOME/.config/git/ignore"

    log "git configured"
}
