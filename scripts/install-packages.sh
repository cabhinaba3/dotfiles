#!/usr/bin/env bash
# Resolves the package manifest against the detected distro family and
# installs whatever categories were requested. Expects lib.sh and
# detect-os.sh to already be sourced, and DOTFILES_ROOT to be set.
#
# usage: install_packages <category> [<category> ...]
# categories: core shell modern-cli development networking desktop optional

# translate one common name through packages/<family>.sh's PKG_MAP,
# falling back to the name unchanged.
pkg_translate() {
    local name="$1" entry
    for entry in "${PKG_MAP[@]:-}"; do
        [ -z "$entry" ] && continue
        case "$entry" in
            "$name:"*) echo "${entry#*:}"; return 0 ;;
        esac
    done
    echo "$name"
}

install_packages() {
    local categories=("$@")
    local family_file="$DOTFILES_ROOT/packages/${DOTFILES_DISTRO_FAMILY}.sh"

    if [ ! -f "$family_file" ]; then
        warn "no package mapping for distro family '$DOTFILES_DISTRO_FAMILY' (pkg manager: $DOTFILES_PKG_MANAGER)"
        warn "skipping automatic package installation -- install packages/common.sh's list manually"
        return 0
    fi

    if [ "$(id -u)" != 0 ] && ! has sudo && [ "${DOTFILES_DRY_RUN:-0}" != 1 ]; then
        warn "not root and no 'sudo' available -- cannot install system packages"
        warn "ask your administrator to install packages/${DOTFILES_DISTRO_FAMILY}.sh's list, or re-run as root"
        return 0
    fi

    # shellcheck source=/dev/null
    . "$DOTFILES_ROOT/packages/common.sh"
    # shellcheck source=/dev/null
    . "$family_file"
    # shellcheck source=/dev/null
    . "$DOTFILES_ROOT/packages/manifest.sh"

    local wanted=() cat_var pkgs pkg resolved
    for cat in "${categories[@]}"; do
        case "$cat" in
            core)        pkgs="$PKGS_CORE" ;;
            shell)       pkgs="$PKGS_SHELL" ;;
            modern-cli)  pkgs="$PKGS_MODERN_CLI" ;;
            development) pkgs="$PKGS_DEVELOPMENT" ;;
            networking)  pkgs="$PKGS_NETWORKING" ;;
            desktop)     pkgs="$PKGS_DESKTOP" ;;
            optional)    pkgs="$PKGS_OPTIONAL" ;;
            *) warn "unknown package category: $cat"; continue ;;
        esac
        for pkg in $pkgs; do
            resolved="$(pkg_translate "$pkg")"
            [ -n "$resolved" ] || continue
            wanted+=("$resolved")
        done
    done

    # de-dupe while preserving order
    local seen="" final=()
    for pkg in "${wanted[@]}"; do
        case " $seen " in *" $pkg "*) continue ;; esac
        seen="$seen $pkg"
        if pkg_is_installed "$pkg" 2>/dev/null; then
            verbose "already installed: $pkg"
        else
            final+=("$pkg")
        fi
    done

    if [ ${#final[@]} -eq 0 ]; then
        log "all requested packages already installed"
        return 0
    fi

    info "packages to install (${DOTFILES_PKG_MANAGER}): ${final[*]}"
    pkg_install "${final[@]}"
}
