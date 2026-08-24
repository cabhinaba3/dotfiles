# Node.js setup. The source machine ran a plain distro-packaged Node
# (no nvm-managed version actually active, despite nvm being installed --
# see docs/machine-specific.md), so the default here is: install Node via
# the system package manager (already covered by packages/manifest.sh's
# `development` category) and just make sure global npm installs don't
# need sudo.

configure_npm_no_sudo() {
    has npm || return 0
    step "Configuring npm (no-sudo global installs)"
    local npm_global="$HOME/.npm-global"
    if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
        printf "%b[dry-run]%b would set npm prefix to %s\n" "$C_YELLOW" "$C_RESET" "$npm_global"
        return 0
    fi
    mkdir -p "$npm_global"
    npm config set prefix "$npm_global" >/dev/null 2>&1 || true
    local block_file; block_file="$(mktemp)"
    printf 'case ":$PATH:" in *":%s/bin:"*) ;; *) export PATH="%s/bin:$PATH" ;; esac\n' "$npm_global" "$npm_global" > "$block_file"
    install_block "$HOME/.profile" "npm-global" "$block_file"
    rm -f "$block_file"
    log "npm global prefix set to $npm_global (no sudo needed for -g installs)"
}
