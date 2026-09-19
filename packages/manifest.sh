#!/usr/bin/env bash
# Package manifest, organized by category. This is the single source of
# truth for *what* gets installed; packages/<family>.sh maps these
# logical/common names to the actual package name on that distro.
#
# Categories:
#   core       - baseline CLI a shell environment needs
#   shell      - prompt/multiplexer/editor
#   modern-cli - the "modern replacements" used by bashrc_hacker's aliases
#   development- compilers, build tools, langs
#   networking - ssh and friends
#   desktop    - i3/X11 stack (only installed when DOTFILES_HAS_DESKTOP=1)
#   optional   - nice-to-have, never installed without --full
#
# Each variable is a space-separated list of *common* package names.
# packages/<family>.sh translates common name -> distro-specific name;
# if no mapping exists the common name is tried as-is.

PKGS_CORE="git curl wget rsync unzip tar gzip which ca-certificates gnupg"
PKGS_SHELL="bash tmux neovim starship"
PKGS_MODERN_CLI="ripgrep fd bat eza fzf git-delta jq tree htop"
PKGS_DEVELOPMENT="base-devel nodejs npm python3 make cmake pkg-config"
PKGS_NETWORKING="openssh"
PKGS_DESKTOP="alacritty picom i3-wm i3status i3lock dunst feh xsetroot"
PKGS_OPTIONAL="fastfetch"
