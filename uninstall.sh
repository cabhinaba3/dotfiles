#!/usr/bin/env bash
# Reverses what install.sh's link-configs step did: removes symlinks that
# point into this repo and strips the managed blocks out of ~/.bashrc,
# ~/.bash_profile, ~/.profile, ~/.Xresources. Does NOT uninstall packages,
# Claude Code, rustup, or any other software -- only unlinks configuration.
#
# Your most recent backup (if install.sh ever made one) is left in place
# under ~/.dotfiles-backup/ -- restore from there by hand if you want the
# pre-dotfiles config back.

set -Eeuo pipefail
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_ROOT
# shellcheck source=scripts/lib.sh
. "$DOTFILES_ROOT/scripts/lib.sh"

DOTFILES_DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DOTFILES_DRY_RUN=1
export DOTFILES_DRY_RUN

LINKED_PATHS=(
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
)

BLOCK_FILES=(
    "$HOME/.bashrc"
    "$HOME/.bash_profile"
    "$HOME/.profile"
    "$HOME/.Xresources"
)

step "Removing symlinks into $DOTFILES_ROOT"
for path in "${LINKED_PATHS[@]}"; do
    if [ -L "$path" ] && [[ "$(readlink -f "$path")" == "$DOTFILES_ROOT"/* ]]; then
        if [ "$DOTFILES_DRY_RUN" = 1 ]; then
            printf "%b[dry-run]%b would remove symlink %s\n" "$C_YELLOW" "$C_RESET" "$path"
        else
            rm -f "$path"
            log "removed $path"
        fi
    fi
done

step "Removing managed blocks from rc files"
for f in "${BLOCK_FILES[@]}"; do
    [ -f "$f" ] || continue
    if ! grep -q "dotfiles:" "$f" 2>/dev/null; then continue; fi
    if [ "$DOTFILES_DRY_RUN" = 1 ]; then
        printf "%b[dry-run]%b would strip managed blocks from %s\n" "$C_YELLOW" "$C_RESET" "$f"
        continue
    fi
    tmp="$(mktemp)"
    awk '
        /^# >>> dotfiles:/ {skip=1; next}
        /^# <<< dotfiles:/ {skip=0; next}
        !skip {print}
    ' "$f" > "$tmp"
    mv "$tmp" "$f"
    log "stripped managed blocks from $f"
done

if has systemctl && systemctl --user is-enabled distant-manager.service >/dev/null 2>&1; then
    if [ "$DOTFILES_DRY_RUN" = 1 ]; then
        printf "%b[dry-run]%b would disable distant-manager.service\n" "$C_YELLOW" "$C_RESET"
    else
        run "systemctl --user disable distant-manager" -- systemctl --user disable distant-manager.service || true
        log "disabled distant-manager.service (unit file left in place)"
    fi
fi

step "Done"
cat <<'EOF'
Config symlinks and managed rc-file blocks have been removed.

NOT removed (uninstall this by hand if you want to):
  - Claude Code itself           (see: https://claude.ai/install.sh for how it was installed)
  - Packages installed via your package manager
  - rustup / cargo toolchains
  - ~/.dotfiles-backup/ snapshots (your pre-install config, if anything was backed up)
EOF
