#!/usr/bin/env bash
# Fedora/RHEL/CentOS/Rocky/Alma package name overrides + install function.
# shellcheck disable=SC2034
PKG_MAP=(
    "git-delta:git-delta"
    "base-devel:@development-tools"
    "ripgrep:ripgrep"
    "fd:fd-find"
    "gnupg:gnupg2"
    "pkg-config:pkgconf-pkg-config"
    "i3-wm:i3"
    "openssh:openssh-clients"
)

pkg_install() {
    local pkgs=("$@")
    [ ${#pkgs[@]} -eq 0 ] && return 0
    local bin=dnf
    has dnf || bin=yum
    run "$bin install ${pkgs[*]}" -- $SUDO "$bin" install -y "${pkgs[@]}"
}

pkg_is_installed() { rpm -q "$1" >/dev/null 2>&1; }

pkg_refresh() { :; } # dnf/yum refresh inline on install, nothing to pre-sync
