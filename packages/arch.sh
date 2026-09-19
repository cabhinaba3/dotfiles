#!/usr/bin/env bash
# Arch/Manjaro/EndeavourOS package name overrides + install function.
# shellcheck disable=SC2034
PKG_MAP=(
    "git-delta:git-delta"
    "base-devel:base-devel"
    "python3:python"
    "pkg-config:pkgconf"
    "xsetroot:xorg-xsetroot"
)

pkg_install() {
    local pkgs=("$@")
    [ ${#pkgs[@]} -eq 0 ] && return 0
    run "pacman -S ${pkgs[*]}" -- $SUDO pacman -S --needed --noconfirm "${pkgs[@]}"
}

pkg_is_installed() { pacman -Qi "$1" >/dev/null 2>&1; }

pkg_refresh() { run "pacman -Sy" -- $SUDO pacman -Sy --noconfirm; }
