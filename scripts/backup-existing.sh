#!/usr/bin/env bash
# Enumerates every $HOME path this repo might touch and backs up whatever
# already exists there (and isn't already one of our symlinks) before
# link-configs.sh runs. Backups land in $DOTFILES_BACKUP_ROOT
# (default: ~/.dotfiles-backup/<timestamp>/), mirroring the path relative
# to $HOME. Safe to run standalone -- it never installs anything.

DOTFILES_MANAGED_PATHS=(
    "$HOME/.bashrc_hacker"
    "$HOME/.tmux.conf"
    "$HOME/.config/starship.toml"
    "$HOME/.config/alacritty/alacritty.toml"
    "$HOME/.config/nvim/init.lua"
    "$HOME/.config/broot/conf.toml"
    "$HOME/.config/broot/broot_wrapper.sh"
    "$HOME/.config/git/ignore"
    "$HOME/.config/i3/config"
    "$HOME/.config/i3/set_wallpaper.sh"
    "$HOME/.config/i3/launch_alacritty_monitors.sh"
    "$HOME/.config/i3status/config"
    "$HOME/.config/picom/picom.conf"
    "$HOME/.config/gtk-3.0/settings.ini"
    "$HOME/.icons/default/index.theme"
    "$HOME/.config/systemd/user/distant-manager.service"
)

backup_all_existing() {
    step "Backing up existing config that would be replaced"
    local touched=0
    for path in "${DOTFILES_MANAGED_PATHS[@]}"; do
        if [ -e "$path" ] && [ ! -L "$path" ]; then
            backup_if_needed "$path"
            touched=1
        fi
    done
    if [ "$touched" = 0 ]; then
        log "nothing to back up (no conflicting real files found)"
    else
        log "backups saved under $DOTFILES_BACKUP_ROOT"
    fi
}
