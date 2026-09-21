#!/usr/bin/env bash
# Links/generates every piece of config this repo manages. Idempotent:
# safe to re-run any number of times. Expects lib.sh, detect-os.sh,
# detect-desktop.sh already sourced and DOTFILES_ROOT set.

link_shell_configs() {
    step "Linking shell configuration"
    link "$DOTFILES_ROOT/bash/interactive.bash" "$HOME/.bashrc.interactive"
    link "$DOTFILES_ROOT/bash/interactive.bash" "$HOME/.bashrc_hacker"
    install_block "$HOME/.bashrc" "bashrc" "$DOTFILES_ROOT/bash/bashrc.block"
    install_block "$HOME/.bash_profile" "bash_profile" "$DOTFILES_ROOT/bash/bash_profile.block"
    install_block "$HOME/.profile" "profile" "$DOTFILES_ROOT/bash/profile.block"

    if [ ! -f "$HOME/.bashrc.local" ] && [ "${DOTFILES_DRY_RUN:-0}" != 1 ]; then
        info "no ~/.bashrc.local yet -- copy bash/local.env.example there for machine-local secrets/env"
    fi
}

link_terminal_configs() {
    step "Linking terminal / editor configuration"
    link "$DOTFILES_ROOT/tmux/tmux.conf" "$HOME/.tmux.conf"
    link "$DOTFILES_ROOT/starship/starship.toml" "$HOME/.config/starship.toml"
    link "$DOTFILES_ROOT/nvim/init.lua" "$HOME/.config/nvim/init.lua"
    if has alacritty || [ "$DOTFILES_HAS_DESKTOP" = 1 ]; then
        link "$DOTFILES_ROOT/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
    fi

    # Set Alacritty as default terminal across XDG and x-terminal-emulator
    local alacritty_bin
    alacritty_bin="$(command -v alacritty 2>/dev/null || true)"
    if [ -n "$alacritty_bin" ]; then
        if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
            printf "%b[dry-run]%b would configure Alacritty as default terminal in ~/.local/bin/x-terminal-emulator and ~/.config/xdg-terminals.list\n" "$C_YELLOW" "$C_RESET"
        else
            mkdir -p "$HOME/.local/bin" "$HOME/.config"
            ln -sf "$alacritty_bin" "$HOME/.local/bin/x-terminal-emulator"
            echo "Alacritty.desktop" > "$HOME/.config/xdg-terminals.list"
            log "configured Alacritty as default terminal (x-terminal-emulator, xdg-terminals.list)"
        fi
    fi
}

link_i3_desktop() {
    if [ "${MODE:-default}" != "full" ] && { [ "$DOTFILES_HAS_DESKTOP" != 1 ] || [ "$DOTFILES_DISPLAY_SERVER" != "x11" ]; }; then
        info "no X11 desktop session detected -- skipping i3/picom/alacritty desktop config (use --full to force)"
        return 0
    fi
    step "Linking i3 desktop stack"
    link "$DOTFILES_ROOT/i3/config" "$HOME/.config/i3/config"
    link "$DOTFILES_ROOT/i3/i3status.config" "$HOME/.config/i3status/config"
    link "$DOTFILES_ROOT/i3/picom.conf" "$HOME/.config/picom/picom.conf"
    link "$DOTFILES_ROOT/i3/set_wallpaper.sh" "$HOME/.config/i3/set_wallpaper.sh"
    link "$DOTFILES_ROOT/i3/launch_alacritty_monitors.sh" "$HOME/.config/i3/launch_alacritty_monitors.sh"
    chmod +x "$HOME/.config/i3/set_wallpaper.sh" "$HOME/.config/i3/launch_alacritty_monitors.sh" 2>/dev/null || true
}

link_x11_cursor_theme() {
    if [ "$DOTFILES_DISPLAY_SERVER" != "x11" ]; then
        return 0
    fi
    step "Configuring cursor theme (X11)"
    link "$DOTFILES_ROOT/x11/gtk-3.0-settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
    link "$DOTFILES_ROOT/x11/default-cursor-index.theme" "$HOME/.icons/default/index.theme"
    install_block "$HOME/.Xresources" "xresources-cursor" "$DOTFILES_ROOT/x11/Xresources.cursor" "!"
}

link_claude_config() {
    step "Linking Claude Code user settings"
    mkdir -p "$HOME/.claude"
    if [ -f "$HOME/.claude/settings.json" ]; then
        verbose "~/.claude/settings.json already exists -- leaving it as-is (not overwriting user preferences)"
        info "reference template available at claude/config/settings.json.template if you want to diff/merge manually"
    else
        if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
            printf "%b[dry-run]%b would create ~/.claude/settings.json from template\n" "$C_YELLOW" "$C_RESET"
        else
            mkdir -p "$HOME/.claude"
            cp "$DOTFILES_ROOT/claude/config/settings.json.template" "$HOME/.claude/settings.json"
            log "created ~/.claude/settings.json from template"
        fi
    fi
}

link_systemd_user_units() {
    if [ "$DOTFILES_INIT" != "systemd" ]; then
        info "no systemd -- skipping user service units"
        return 0
    fi
    if ! has distant; then
        verbose "'distant' not installed -- skipping distant-manager.service (install distant first if you want this)"
        return 0
    fi
    step "Installing systemd --user units"
    mkdir -p "$HOME/.config/systemd/user"
    local tmp_service
    tmp_service="$(mktemp)"
    sed "s#{{HOME}}#$HOME#g" "$DOTFILES_ROOT/systemd/user/distant-manager.service.template" > "$tmp_service"
    if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
        printf "%b[dry-run]%b would install ~/.config/systemd/user/distant-manager.service and enable it\n" "$C_YELLOW" "$C_RESET"
        rm -f "$tmp_service"
        return 0
    fi
    mv "$tmp_service" "$HOME/.config/systemd/user/distant-manager.service"
    run "systemctl --user daemon-reload" -- systemctl --user daemon-reload
    run "systemctl --user enable distant-manager" -- systemctl --user enable distant-manager.service
    log "distant-manager.service installed and enabled"
}

link_all_configs() {
    backup_all_existing
    link_shell_configs
    link_terminal_configs
    link_i3_desktop
    link_x11_cursor_theme
    link_claude_config
    link_systemd_user_units
}
