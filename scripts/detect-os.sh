#!/usr/bin/env bash
# Detects distro family, package manager, architecture, and environment class.
# Sets (and exports) variables consumed by the rest of the installer:
#   DOTFILES_DISTRO_ID       - /etc/os-release ID (arch, ubuntu, fedora, ...)
#   DOTFILES_DISTRO_LIKE     - ID_LIKE, best-effort family hint
#   DOTFILES_DISTRO_FAMILY   - our own bucket: arch|debian|fedora|suse|alpine|gentoo|void|nixos|unknown
#   DOTFILES_PKG_MANAGER     - pacman|apt|dnf|yum|zypper|apk|xbps|emerge|nix|brew|unknown
#   DOTFILES_AUR_HELPER      - yay|paru|"" (arch only, optional)
#   DOTFILES_ARCH            - uname -m
#   DOTFILES_IS_WSL          - 1|0
#   DOTFILES_IS_CONTAINER    - 1|0
#   DOTFILES_IS_VM           - 1|0
#   DOTFILES_ENV_CLASS       - desktop|server|vm|container|wsl
# Safe to source multiple times.

detect_os() {
    DOTFILES_ARCH="$(uname -m)"
    DOTFILES_DISTRO_ID="unknown"
    DOTFILES_DISTRO_LIKE=""
    DOTFILES_DISTRO_FAMILY="unknown"

    if [ -r /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        DOTFILES_DISTRO_ID="${ID:-unknown}"
        DOTFILES_DISTRO_LIKE="${ID_LIKE:-}"
    fi

    case " ${DOTFILES_DISTRO_ID} ${DOTFILES_DISTRO_LIKE} " in
        *" arch "*|*" manjaro "*|*" endeavouros "*)          DOTFILES_DISTRO_FAMILY="arch" ;;
        *" debian "*|*" ubuntu "*|*" linuxmint "*|*" pop "*)  DOTFILES_DISTRO_FAMILY="debian" ;;
        *" fedora "*|*" rhel "*|*" centos "*|*" rocky "*|*" almalinux "*) DOTFILES_DISTRO_FAMILY="fedora" ;;
        *" opensuse"*|*" suse "*|*" sles "*)                  DOTFILES_DISTRO_FAMILY="suse" ;;
        *" alpine "*)                                         DOTFILES_DISTRO_FAMILY="alpine" ;;
        *" gentoo "*)                                         DOTFILES_DISTRO_FAMILY="gentoo" ;;
        *" void "*)                                           DOTFILES_DISTRO_FAMILY="void" ;;
        *" nixos "*)                                          DOTFILES_DISTRO_FAMILY="nixos" ;;
    esac

    # Fall back to probing for a package manager binary if os-release didn't
    # resolve a family (covers unusual/rebadged distros).
    if [ "$DOTFILES_DISTRO_FAMILY" = "unknown" ]; then
        if has pacman; then DOTFILES_DISTRO_FAMILY="arch"
        elif has apt-get; then DOTFILES_DISTRO_FAMILY="debian"
        elif has dnf || has yum; then DOTFILES_DISTRO_FAMILY="fedora"
        elif has zypper; then DOTFILES_DISTRO_FAMILY="suse"
        elif has apk; then DOTFILES_DISTRO_FAMILY="alpine"
        elif has xbps-install; then DOTFILES_DISTRO_FAMILY="void"
        elif has emerge; then DOTFILES_DISTRO_FAMILY="gentoo"
        fi
    fi

    DOTFILES_PKG_MANAGER="unknown"
    if has pacman; then DOTFILES_PKG_MANAGER="pacman"
    elif has apt-get; then DOTFILES_PKG_MANAGER="apt"
    elif has dnf; then DOTFILES_PKG_MANAGER="dnf"
    elif has yum; then DOTFILES_PKG_MANAGER="yum"
    elif has zypper; then DOTFILES_PKG_MANAGER="zypper"
    elif has apk; then DOTFILES_PKG_MANAGER="apk"
    elif has xbps-install; then DOTFILES_PKG_MANAGER="xbps"
    elif has emerge; then DOTFILES_PKG_MANAGER="emerge"
    elif has nix-env || has nix; then DOTFILES_PKG_MANAGER="nix"
    elif has brew; then DOTFILES_PKG_MANAGER="brew"
    fi

    DOTFILES_AUR_HELPER=""
    if [ "$DOTFILES_DISTRO_FAMILY" = "arch" ]; then
        has yay && DOTFILES_AUR_HELPER="yay"
        [ -z "$DOTFILES_AUR_HELPER" ] && has paru && DOTFILES_AUR_HELPER="paru"
    fi

    # --- WSL ---
    DOTFILES_IS_WSL=0
    if [ -n "${WSL_DISTRO_NAME:-}" ] || [ -n "${WSL_INTEROP:-}" ]; then
        DOTFILES_IS_WSL=1
    elif [ -r /proc/version ] && grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null; then
        DOTFILES_IS_WSL=1
    fi

    # --- containers ---
    DOTFILES_IS_CONTAINER=0
    if [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
        DOTFILES_IS_CONTAINER=1
    elif [ -r /proc/1/cgroup ] && grep -qE 'docker|containerd|kubepods|lxc' /proc/1/cgroup 2>/dev/null; then
        DOTFILES_IS_CONTAINER=1
    fi

    # --- VM ---
    DOTFILES_IS_VM=0
    if has systemd-detect-virt; then
        local virt
        # systemd-detect-virt exits 1 for "none" (bare metal) -- that's
        # normal, not a failure. `|| true` keeps that from tripping
        # `set -e` (a bare failing assignment aborts the script); it must
        # NOT be `|| echo none`, which would print a second "none" after
        # systemd-detect-virt's own stdout and corrupt the match below,
        # misdetecting bare metal as a VM.
        virt="$(systemd-detect-virt 2>/dev/null)" || true
        [ -z "$virt" ] && virt="none"
        case "$virt" in
            none|"") DOTFILES_IS_VM=0 ;;
            *) [ "$DOTFILES_IS_CONTAINER" = 0 ] && DOTFILES_IS_VM=1 ;;
        esac
    fi

    # --- environment class (best-effort) ---
    if [ "$DOTFILES_IS_WSL" = 1 ]; then
        DOTFILES_ENV_CLASS="wsl"
    elif [ "$DOTFILES_IS_CONTAINER" = 1 ]; then
        DOTFILES_ENV_CLASS="container"
    elif [ "$DOTFILES_IS_VM" = 1 ]; then
        DOTFILES_ENV_CLASS="vm"
    elif [ -n "${XDG_CURRENT_DESKTOP:-}${DESKTOP_SESSION:-}" ] || has Xorg || has gnome-shell; then
        DOTFILES_ENV_CLASS="desktop"
    else
        DOTFILES_ENV_CLASS="server"
    fi

    export DOTFILES_DISTRO_ID DOTFILES_DISTRO_LIKE DOTFILES_DISTRO_FAMILY \
           DOTFILES_PKG_MANAGER DOTFILES_AUR_HELPER DOTFILES_ARCH \
           DOTFILES_IS_WSL DOTFILES_IS_CONTAINER DOTFILES_IS_VM DOTFILES_ENV_CLASS
}

detect_init() {
    DOTFILES_INIT="unknown"
    if [ -d /run/systemd/system ]; then
        DOTFILES_INIT="systemd"
    elif has rc-status; then
        DOTFILES_INIT="openrc"
    elif has runit; then
        DOTFILES_INIT="runit"
    elif has sv && [ -d /etc/sv ]; then
        DOTFILES_INIT="runit"
    fi
    export DOTFILES_INIT
}

detect_os
detect_init
