#!/usr/bin/env bash
# Installs/verifies the Claude Code CLI. Self-contained: can be run
# standalone (`./claude/install.sh`) or sourced by the main installer
# (which does `. claude/install.sh` then calls install_claude_code).
#
# Never touches authentication -- OAuth login is inherently interactive
# and out of scope for an unattended script. See README.md in this
# directory for the headless/CI story (long-lived tokens via
# `claude setup-token`).

set -Eeuo pipefail

if [ -z "${DOTFILES_ROOT:-}" ]; then
    # running standalone
    DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    # shellcheck source=/dev/null
    . "$DOTFILES_ROOT/scripts/lib.sh"
fi

install_claude_code() {
    step "Claude Code CLI"

    if has claude; then
        local ver
        if ver="$(claude --version 2>/dev/null)"; then
            log "Claude Code already installed and working: $ver"
            if [ "${DOTFILES_SKIP_CLAUDE_UPDATE:-0}" != 1 ] && [ "${DOTFILES_DRY_RUN:-0}" != 1 ]; then
                verbose "leaving update policy to Claude Code's own self-updater (see 'claude doctor')"
            fi
            return 0
        else
            warn "found a 'claude' on PATH but it doesn't run ('claude --version' failed) -- reinstalling"
        fi
    fi

    if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
        printf "%b[dry-run]%b would install Claude Code via the official installer (curl -fsSL https://claude.ai/install.sh | bash)\n" "$C_YELLOW" "$C_RESET"
        return 0
    fi

    if has curl; then
        info "installing Claude Code via the official native installer"
        if curl -fsSL https://claude.ai/install.sh | bash; then
            :
        else
            warn "native installer failed"
        fi
    fi

    # re-check PATH (installer places the binary under ~/.local/bin)
    case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac

    if ! has claude && has npm; then
        info "native installer unavailable/failed -- falling back to npm (requires Node.js)"
        run "npm install -g @anthropic-ai/claude-code" -- npm install -g @anthropic-ai/claude-code
    fi

    if has claude; then
        log "Claude Code installed: $(claude --version 2>/dev/null || echo 'version check failed')"
    else
        err "Claude Code installation failed -- install manually: https://claude.ai/install.sh"
        return 1
    fi
}

# allow standalone execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    install_claude_code
fi
