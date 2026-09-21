#!/usr/bin/env bash
# Shared helpers sourced by every script in this repo.
# Not meant to be executed directly.

# --- output -----------------------------------------------------------
DOTFILES_COLOR=1
[ -t 1 ] || DOTFILES_COLOR=0
[ -n "${NO_COLOR:-}" ] && DOTFILES_COLOR=0

if [ "$DOTFILES_COLOR" = 1 ]; then
    C_RED='\033[0;31m'; C_GREEN='\033[0;32m'; C_YELLOW='\033[1;33m'
    C_CYAN='\033[0;36m'; C_DIM='\033[2m'; C_RESET='\033[0m'
else
    C_RED=''; C_GREEN=''; C_YELLOW=''; C_CYAN=''; C_DIM=''; C_RESET=''
fi

# SUDO is empty when already root, so package scripts can write
# "$SUDO pacman -S ..." and it works unprivileged-or-root either way.
SUDO=""
[ "$(id -u)" = 0 ] || SUDO="sudo"

log()   { printf "%b[+]%b %s\n" "$C_GREEN" "$C_RESET" "$1"; }
warn()  { printf "%b[!]%b %s\n" "$C_YELLOW" "$C_RESET" "$1" >&2; }
err()   { printf "%b[x]%b %s\n" "$C_RED" "$C_RESET" "$1" >&2; }
info()  { printf "%b[.]%b %s\n" "$C_CYAN" "$C_RESET" "$1"; }
step()  { printf "\n%b==>%b %s\n" "$C_CYAN" "$C_RESET" "$1"; }
verbose(){ [ "${DOTFILES_VERBOSE:-0}" = 1 ] && printf "%b[v]%b %s\n" "$C_DIM" "$C_RESET" "$1" >&2 || true; }

# --- dry-run aware command runner -------------------------------------
# usage: run <description> -- <command...>
run() {
    local desc="$1"; shift
    if [ "$1" = "--" ]; then shift; fi
    if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
        printf "%b[dry-run]%b would %s: %s\n" "$C_YELLOW" "$C_RESET" "$desc" "$*"
        return 0
    fi
    verbose "$desc: $*"
    "$@"
}

# --- backup -------------------------------------------------------------
DOTFILES_BACKUP_ROOT="${DOTFILES_BACKUP_ROOT:-$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S 2>/dev/null || echo run)}"

# backup_if_needed <path>
# Moves an existing real file/dir that is NOT already a symlink into ours
# into the backup dir, preserving its relative-to-$HOME path. No-op if the
# path doesn't exist or is already the correct symlink.
backup_if_needed() {
    local target="$1"
    [ -e "$target" ] || [ -L "$target" ] || return 0

    if [ -L "$target" ]; then
        # already a symlink -- if it points into this repo, nothing to do
        local resolved
        resolved="$(readlink -f "$target" 2>/dev/null || true)"
        case "$resolved" in
            "$DOTFILES_ROOT"/*) verbose "already linked: $target"; return 0 ;;
        esac
    fi

    local rel="${target#"$HOME"/}"
    local dest="$DOTFILES_BACKUP_ROOT/$rel"
    if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
        printf "%b[dry-run]%b would back up %s -> %s\n" "$C_YELLOW" "$C_RESET" "$target" "$dest"
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    mv "$target" "$dest"
    warn "backed up existing $target -> $dest"
}

# link <source-in-repo> <target-in-home>
# Idempotent, backs up conflicting real files, replaces stale symlinks.
link() {
    local src="$1" target="$2"
    if [ ! -e "$src" ]; then
        err "link source missing: $src"
        return 1
    fi
    if [ -L "$target" ] && [ "$(readlink -f "$target" 2>/dev/null)" = "$(readlink -f "$src" 2>/dev/null)" ]; then
        verbose "up to date: $target"
        return 0
    fi
    backup_if_needed "$target"
    if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
        printf "%b[dry-run]%b would link %s -> %s\n" "$C_YELLOW" "$C_RESET" "$target" "$src"
        return 0
    fi
    mkdir -p "$(dirname "$target")"
    ln -sfn "$src" "$target"
    log "linked $target -> $src"
}

# --- misc ---------------------------------------------------------------
has() { command -v "$1" >/dev/null 2>&1; }

confirm() {
    local prompt="$1"
    [ "${DOTFILES_ASSUME_YES:-0}" = 1 ] && return 0
    [ "${DOTFILES_DRY_RUN:-0}" = 1 ] && return 0
    printf "%s [y/N] " "$prompt"
    read -r reply
    case "$reply" in y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}

# --- managed rc-file blocks ----------------------------------------------
# install_block <target-file> <marker-name> <content-file> [comment-prefix]
#
# Idempotently maintains a marked region inside an rc file the user also
# hand-edits (e.g. ~/.bashrc). Re-running with updated content replaces
# only the region between the markers; content outside it is left alone.
# Creates the target file (and parent dir) if it doesn't exist yet.
# comment-prefix defaults to "#"; pass "!" for files like .Xresources whose
# comment syntax differs (xrdb pipes the file through cpp, which chokes on
# a bare "#" line that isn't a real preprocessor directive).
install_block() {
    local target="$1" marker="$2" content_file="$3" comment="${4:-#}"
    local begin="${comment} >>> dotfiles:${marker} >>> (managed by ${DOTFILES_ROOT}/install.sh, do not edit between markers)"
    local end="${comment} <<< dotfiles:${marker} <<<"

    if [ ! -f "$content_file" ]; then
        err "install_block: missing content file $content_file"
        return 1
    fi

    if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
        if [ -f "$target" ] && grep -qF "$begin" "$target" 2>/dev/null; then
            printf "%b[dry-run]%b would refresh managed block '%s' in %s\n" "$C_YELLOW" "$C_RESET" "$marker" "$target"
        else
            printf "%b[dry-run]%b would add managed block '%s' to %s\n" "$C_YELLOW" "$C_RESET" "$marker" "$target"
        fi
        return 0
    fi

    mkdir -p "$(dirname "$target")"
    touch "$target"

    local tmp
    tmp="$(mktemp)"
    if grep -qF "$begin" "$target" 2>/dev/null; then
        awk -v b="$begin" -v e="$end" '
            $0==b {skip=1; next}
            $0==e {skip=0; next}
            !skip {print}
        ' "$target" > "$tmp"
    else
        cp "$target" "$tmp"
    fi

    {
        cat "$tmp"
        printf '\n%s\n' "$begin"
        cat "$content_file"
        printf '%s\n' "$end"
    } > "${tmp}.new"
    mv "${tmp}.new" "$target"
    rm -f "$tmp"
    log "updated managed block '$marker' in $target"
}
