#!/usr/bin/env bash
# Alpine Linux package name overrides + install function.
# Note: Alpine ships musl libc -- some tools (rustup-installed binaries,
# certain prebuilt releases) may not run; documented as best-effort.
# shellcheck disable=SC2034
PKG_MAP=(
    "base-devel:build-base"
    "git-delta:delta"
    "pkg-config:pkgconf"
    "i3-wm:i3wm"
    "openssh:openssh-client"
)

pkg_install() {
    local pkgs=("$@")
    [ ${#pkgs[@]} -eq 0 ] && return 0
    run "apk add ${pkgs[*]}" -- $SUDO apk add "${pkgs[@]}"
}

pkg_is_installed() { apk info -e "$1" >/dev/null 2>&1; }

pkg_refresh() { run "apk update" -- $SUDO apk update; }
