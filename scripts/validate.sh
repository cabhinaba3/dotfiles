#!/usr/bin/env bash
# Validates the installed state: symlinks resolve into this repo, required
# commands are on PATH, Claude Code works, git/systemd config is sane.
# Prints PASS/WARN/FAIL/SKIP per check and exits non-zero if any FAIL.
#
# usage: ./scripts/validate.sh [--verbose]

set -Eeuo pipefail
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib.sh
. "$DOTFILES_ROOT/scripts/lib.sh"
# shellcheck source=detect-os.sh
. "$DOTFILES_ROOT/scripts/detect-os.sh"
# shellcheck source=detect-shell.sh
. "$DOTFILES_ROOT/scripts/detect-shell.sh"
# shellcheck source=detect-desktop.sh
. "$DOTFILES_ROOT/scripts/detect-desktop.sh"

[ "${1:-}" = "--verbose" ] && DOTFILES_VERBOSE=1

PASS=0; WARN=0; FAIL=0; SKIP=0

result() {
    local status="$1" name="$2" detail="${3:-}"
    case "$status" in
        PASS) PASS=$((PASS+1)); printf "%b PASS%b  %-38s %s\n" "$C_GREEN" "$C_RESET" "$name" "$detail" ;;
        WARN) WARN=$((WARN+1)); printf "%b WARN%b  %-38s %s\n" "$C_YELLOW" "$C_RESET" "$name" "$detail" ;;
        FAIL) FAIL=$((FAIL+1)); printf "%b FAIL%b  %-38s %s\n" "$C_RED" "$C_RESET" "$name" "$detail" ;;
        SKIP) SKIP=$((SKIP+1)); printf "%b SKIP%b  %-38s %s\n" "$C_DIM" "$C_RESET" "$name" "$detail" ;;
    esac
}

check_symlink() {
    local name="$1" target="$2"
    if [ ! -e "$target" ] && [ ! -L "$target" ]; then
        result WARN "$name" "not installed ($target missing)"
    elif [ -L "$target" ] && [[ "$(readlink -f "$target")" == "$DOTFILES_ROOT"/* ]]; then
        result PASS "$name" "-> $(readlink -f "$target")"
    elif [ -L "$target" ]; then
        result WARN "$name" "symlinked but not into this repo: $(readlink -f "$target")"
    else
        result WARN "$name" "exists but is a real file, not managed by this repo: $target"
    fi
}

echo "== System =="
result PASS "distro family" "$DOTFILES_DISTRO_FAMILY ($DOTFILES_DISTRO_ID)"
result PASS "package manager" "$DOTFILES_PKG_MANAGER"
result PASS "init system" "$DOTFILES_INIT"
result PASS "environment class" "$DOTFILES_ENV_CLASS"

echo; echo "== Required commands =="
for cmd in git bash curl; do
    has "$cmd" && result PASS "command: $cmd" "$(command -v "$cmd")" || result FAIL "command: $cmd" "not found"
done
for cmd in tmux nvim starship rg fd bat eza fzf delta; do
    has "$cmd" && result PASS "command: $cmd" "$(command -v "$cmd")" || result WARN "command: $cmd" "not installed (optional)"
done

if [ -L "$HOME/.bashrc.interactive" ] || [ -L "$HOME/.bashrc_hacker" ]; then
    result PASS "bash interactive config" "symlink present"
else
    result WARN "bash interactive config" "symlink missing (~/.bashrc.interactive)"
fi
if grep -qF "dotfiles:bashrc" "$HOME/.bashrc" 2>/dev/null; then
    result PASS "~/.bashrc managed block" "present"
else
    result WARN "~/.bashrc managed block" "not found -- run install.sh"
fi
if [ -f "$HOME/.bashrc.local" ]; then
    result PASS "~/.bashrc.local" "present (machine-local overrides)"
else
    result SKIP "~/.bashrc.local" "not present (optional)"
fi
case ":$PATH:" in
    *":$HOME/.local/bin:"*) result PASS "PATH contains ~/.local/bin" "" ;;
    *) result FAIL "PATH contains ~/.local/bin" "missing -- open a new shell or source ~/.bashrc" ;;
esac

echo; echo "== Terminal / editor config =="
check_symlink "tmux.conf" "$HOME/.tmux.conf"
check_symlink "starship.toml" "$HOME/.config/starship.toml"
check_symlink "nvim/init.lua" "$HOME/.config/nvim/init.lua"

echo; echo "== Git =="
if has git; then
    name="$(git config --global user.name 2>/dev/null || true)"
    email="$(git config --global user.email 2>/dev/null || true)"
    [ -n "$name" ] && [ -n "$email" ] && result PASS "git identity" "$name <$email>" || result WARN "git identity" "not set -- run: git config --global user.name/user.email"
    excludes="$(git config --global core.excludesfile 2>/dev/null || true)"
    [ -n "$excludes" ] && [ -f "$excludes" ] && result PASS "git global excludes" "$excludes" || result WARN "git global excludes" "not configured"
else
    result SKIP "git" "not installed"
fi

echo; echo "== SSH =="
if [ -d "$HOME/.ssh" ]; then
    perm="$(stat -c '%a' "$HOME/.ssh" 2>/dev/null || stat -f '%OLp' "$HOME/.ssh" 2>/dev/null)" || true
    [ "$perm" = "700" ] && result PASS "~/.ssh permissions" "700" || result WARN "~/.ssh permissions" "$perm (expected 700)"
else
    result SKIP "~/.ssh" "not created (SSH config is opt-in, see ssh/README.md)"
fi

echo; echo "== Claude Code =="
if has claude; then
    ver="$(claude --version 2>/dev/null || true)"
    [ -n "$ver" ] && result PASS "claude CLI" "$ver" || result FAIL "claude CLI" "on PATH but --version failed"
    if [ -f "$HOME/.claude/.credentials.json" ]; then
        result PASS "claude auth" "credentials present (run 'claude' to verify they still work)"
    else
        result WARN "claude auth" "not logged in yet -- run: claude"
    fi
    if [ -f "$HOME/.claude/settings.json" ]; then
        json_ok=1
        if has python3; then
            python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$HOME/.claude/settings.json" 2>/dev/null || json_ok=0
        elif has jq; then
            jq empty "$HOME/.claude/settings.json" >/dev/null 2>&1 || json_ok=0
        else
            json_ok=0
            NO_VALIDATOR=1
        fi
        if [ "$json_ok" = 1 ]; then
            result PASS "~/.claude/settings.json" "valid JSON"
        elif [ "${NO_VALIDATOR:-0}" = 1 ]; then
            result WARN "~/.claude/settings.json" "present but couldn't validate JSON (no python3/jq)"
        else
            result FAIL "~/.claude/settings.json" "present but not valid JSON"
        fi
    else
        result WARN "~/.claude/settings.json" "missing"
    fi
else
    result WARN "claude CLI" "not installed (optional) -- run ./claude/install.sh"
fi

echo; echo "== systemd --user (if applicable) =="
if [ "$DOTFILES_INIT" = "systemd" ]; then
    if has distant; then
        if systemctl --user is-enabled distant-manager.service >/dev/null 2>&1; then
            result PASS "distant-manager.service" "enabled"
        else
            result WARN "distant-manager.service" "distant installed but service not enabled"
        fi
    else
        result SKIP "distant-manager.service" "'distant' not installed"
    fi
else
    result SKIP "systemd --user units" "no systemd on this system"
fi

echo
echo "-------------------------------------------"
printf "PASS: %b%d%b  WARN: %b%d%b  FAIL: %b%d%b  SKIP: %b%d%b\n" \
    "$C_GREEN" "$PASS" "$C_RESET" "$C_YELLOW" "$WARN" "$C_RESET" \
    "$C_RED" "$FAIL" "$C_RESET" "$C_DIM" "$SKIP" "$C_RESET"

[ "$FAIL" -eq 0 ]
