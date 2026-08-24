#!/usr/bin/env bash
# Main bootstrap entrypoint.
#
#   cd ~/Desktop/dotfiles && ./install.sh
#
# Detects the distro/package manager/init system/shell/desktop, installs
# packages, links configuration, installs Claude Code, configures git,
# and validates the result. Safe to re-run (idempotent) and supports
# --dry-run to preview every action without changing anything.

set -Eeuo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_ROOT

# --- flags -----------------------------------------------------------------
DOTFILES_DRY_RUN=0
DOTFILES_VERBOSE=0
DOTFILES_ASSUME_YES=0
MODE="default"       # default | minimal | full
SKIP_PACKAGES=0
SKIP_CLAUDE=0
SKIP_DESKTOP=0

usage() {
    cat <<'EOF'
Usage: ./install.sh [options]

  --dry-run         Show what would happen; make no changes.
  --minimal         Only core+shell packages, shell config, git, Claude Code.
  --full            Everything, including optional packages and rustup.
  --skip-packages   Don't install any system packages.
  --skip-claude     Don't install/configure Claude Code.
  --skip-desktop    Don't install i3/X11 desktop config, even if detected.
  --yes, -y         Assume "yes" to prompts (git identity, confirmations).
  --verbose         Print every command as it runs.
  --help, -h        Show this help.

Examples:
  ./install.sh --dry-run
  ./install.sh --minimal
  ./install.sh --skip-desktop --skip-claude
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run) DOTFILES_DRY_RUN=1 ;;
        --minimal) MODE="minimal" ;;
        --full) MODE="full" ;;
        --skip-packages) SKIP_PACKAGES=1 ;;
        --skip-claude) SKIP_CLAUDE=1 ;;
        --skip-desktop) SKIP_DESKTOP=1 ;;
        --yes|-y) DOTFILES_ASSUME_YES=1 ;;
        --verbose) DOTFILES_VERBOSE=1 ;;
        --help|-h) usage; exit 0 ;;
        *) echo "unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
    shift
done
export DOTFILES_DRY_RUN DOTFILES_VERBOSE DOTFILES_ASSUME_YES

# --- load libraries ----------------------------------------------------------
# shellcheck source=scripts/lib.sh
. "$DOTFILES_ROOT/scripts/lib.sh"
# shellcheck source=scripts/detect-os.sh
. "$DOTFILES_ROOT/scripts/detect-os.sh"
# shellcheck source=scripts/detect-shell.sh
. "$DOTFILES_ROOT/scripts/detect-shell.sh"
# shellcheck source=scripts/detect-desktop.sh
. "$DOTFILES_ROOT/scripts/detect-desktop.sh"
# shellcheck source=scripts/install-packages.sh
. "$DOTFILES_ROOT/scripts/install-packages.sh"
# shellcheck source=scripts/backup-existing.sh
. "$DOTFILES_ROOT/scripts/backup-existing.sh"
# shellcheck source=scripts/link-configs.sh
. "$DOTFILES_ROOT/scripts/link-configs.sh"
# shellcheck source=scripts/configure-git.sh
. "$DOTFILES_ROOT/scripts/configure-git.sh"
# shellcheck source=scripts/install-node.sh
. "$DOTFILES_ROOT/scripts/install-node.sh"
# shellcheck source=scripts/install-rust.sh
. "$DOTFILES_ROOT/scripts/install-rust.sh"
# shellcheck source=claude/install.sh
. "$DOTFILES_ROOT/claude/install.sh"

[ "$SKIP_DESKTOP" = 1 ] && DOTFILES_HAS_DESKTOP=0

echo -e "${C_CYAN}"
cat <<'EOF'
   dotfiles bootstrap
EOF
echo -e "${C_RESET}"
[ "$DOTFILES_DRY_RUN" = 1 ] && warn "DRY RUN -- no changes will be made"

# --- 1. report detection ----------------------------------------------------
step "Detected environment"
info "distro:        $DOTFILES_DISTRO_ID ($DOTFILES_DISTRO_FAMILY family)"
info "arch:          $DOTFILES_ARCH"
info "package mgr:   $DOTFILES_PKG_MANAGER${DOTFILES_AUR_HELPER:+ (+ $DOTFILES_AUR_HELPER)}"
info "init system:   $DOTFILES_INIT"
info "login shell:   $DOTFILES_LOGIN_SHELL (found: ${DOTFILES_SHELLS_FOUND:-none})"
info "desktop:       ${DOTFILES_DE:-none} / ${DOTFILES_DISPLAY_SERVER}"
info "env class:     $DOTFILES_ENV_CLASS  (wsl=$DOTFILES_IS_WSL container=$DOTFILES_IS_CONTAINER vm=$DOTFILES_IS_VM)"
info "mode:          $MODE"

if [ "$DOTFILES_LOGIN_SHELL" != "bash" ]; then
    warn "login shell is '$DOTFILES_LOGIN_SHELL', not bash -- this repo's shell config targets bash only (see docs/portability.md)"
fi

# --- 2. packages -------------------------------------------------------------
if [ "$SKIP_PACKAGES" = 1 ]; then
    info "skipping package installation (--skip-packages)"
else
    CATEGORIES=(core shell)
    if [ "$MODE" != "minimal" ]; then
        CATEGORIES+=(modern-cli development networking)
        [ "$DOTFILES_HAS_DESKTOP" = 1 ] && CATEGORIES+=(desktop)
    fi
    [ "$MODE" = "full" ] && CATEGORIES+=(optional)
    step "Installing packages: ${CATEGORIES[*]}"
    install_packages "${CATEGORIES[@]}"
fi

# --- 3. Claude Code ------------------------------------------------------------
if [ "$SKIP_CLAUDE" = 1 ]; then
    info "skipping Claude Code (--skip-claude)"
else
    install_claude_code
fi

# --- 4. shell / terminal / desktop config -------------------------------------
link_shell_configs
link_terminal_configs
if [ "$SKIP_DESKTOP" != 1 ]; then
    link_i3_desktop
    link_x11_cursor_theme
fi
[ "$SKIP_CLAUDE" != 1 ] && link_claude_config
link_systemd_user_units

# --- 5. git --------------------------------------------------------------------
configure_git

# --- 6. dev tooling --------------------------------------------------------------
configure_npm_no_sudo
if [ "$MODE" != "minimal" ]; then
    install_rust
fi

# --- 7. validate -----------------------------------------------------------------
if [ "$DOTFILES_DRY_RUN" != 1 ]; then
    step "Validating installation"
    if bash "$DOTFILES_ROOT/scripts/validate.sh"; then
        :
    else
        warn "validation reported failures -- see above"
    fi
fi

# --- final report ------------------------------------------------------------------
step "Done"
cat <<EOF
Backup of anything replaced: $DOTFILES_BACKUP_ROOT (only created if something was backed up)

Manual steps still required:
  1. Authenticate Claude Code:      claude          (interactive OAuth login)
  2. Set git identity if unset:     git config --global user.name/user.email
  3. SSH config is opt-in:          see ssh/README.md
  4. Machine-local secrets/env:     cp bash/local.env.example ~/.bashrc.local
  5. Open a new shell (or: source ~/.bashrc) to pick up PATH/alias changes.

Re-run any time -- this script is idempotent. See README.md for details,
docs/portability.md for what's portable vs machine-specific, and
docs/secrets.md for what was deliberately excluded from this repo.
EOF
