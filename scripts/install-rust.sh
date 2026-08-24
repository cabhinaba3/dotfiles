#!/usr/bin/env bash
# rustup is the one actively-used toolchain/version manager found on the
# source machine (nvm and pyenv were installed but not actually driving
# the active node/python -- see docs/machine-specific.md). Installs
# rustup + the stable toolchain if not already present. Optional: only
# runs as part of `--full`, or when explicitly requested.

install_rust() {
    step "Rust toolchain (rustup)"
    if has rustup; then
        log "rustup already installed: $(rustup --version 2>/dev/null | head -1)"
        return 0
    fi
    if ! has curl; then
        warn "curl not available, cannot install rustup -- skipping"
        return 0
    fi
    if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
        printf "%b[dry-run]%b would install rustup (stable toolchain) via https://sh.rustup.rs\n" "$C_YELLOW" "$C_RESET"
        return 0
    fi
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
    # shellcheck disable=SC1090
    [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
    log "rustup installed: $(rustup --version 2>/dev/null | head -1)"
}
