#!/usr/bin/env bash
# Fallback name mapping used when a distro-specific map (arch.sh, debian.sh,
# ...) doesn't override a name. Format: "common-name:distro-name". If a
# common name has no entry here, it is passed through unchanged.
#
# This file intentionally has no distro-specific overrides -- it exists so
# packages/<family>.sh can `source common.sh` and only list the handful of
# names that actually differ on that distro.
COMMON_PKG_MAP=()
