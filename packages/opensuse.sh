#!/usr/bin/env bash
# openSUSE (Leap/Tumbleweed) package name overrides + install function.
# shellcheck disable=SC2034
PKG_MAP=(
    "base-devel:patterns-devel-base-devel_basis"
)

pkg_install() {
    local pkgs=("$@")
    [ ${#pkgs[@]} -eq 0 ] && return 0
    run "zypper install ${pkgs[*]}" -- $SUDO zypper --non-interactive install "${pkgs[@]}"
}

pkg_is_installed() { rpm -q "$1" >/dev/null 2>&1; }

pkg_refresh() { run "zypper refresh" -- $SUDO zypper --non-interactive refresh; }
