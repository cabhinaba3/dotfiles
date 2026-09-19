#!/usr/bin/env bash
# Debian/Ubuntu/Mint/Pop!_OS package name overrides + install function.
# shellcheck disable=SC2034
PKG_MAP=(
    "git-delta:git-delta"
    "base-devel:build-essential"
    "eza:eza"          # falls back to exa on old releases, see pkg_install
    "picom:picom"
    "openssh:openssh-client"
    "fd:fd-find"
    "which:debianutils"
    "xsetroot:x11-xserver-utils"
)

pkg_install() {
    local pkgs=("$@")
    [ ${#pkgs[@]} -eq 0 ] && return 0
    run "apt-get install ${pkgs[*]}" -- $SUDO apt-get install -y "${pkgs[@]}"
}

pkg_is_installed() { dpkg -s "$1" >/dev/null 2>&1; }

pkg_refresh() { run "apt-get update" -- $SUDO apt-get update; }
