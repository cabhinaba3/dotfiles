#!/usr/bin/env bash
# Thin wrapper: the real logic lives in claude/install.sh so it can also
# be run standalone. Expects lib.sh already sourced and DOTFILES_ROOT set.
# shellcheck source=/dev/null
. "$DOTFILES_ROOT/claude/install.sh"
