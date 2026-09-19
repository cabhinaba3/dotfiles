#!/usr/bin/env bash
# ==============================================================================
# Interactive Bash Configuration Orchestrator
# ==============================================================================

# Only execute in interactive shells
case "$-" in
    *i*) ;;
      *) return ;;
esac

BASH_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all modular configurations
for config_module in env options aliases functions integrations; do
    module_file="$BASH_CONFIG_DIR/${config_module}.bash"
    if [ -f "$module_file" ]; then
        # shellcheck source=/dev/null
        . "$module_file"
    fi
done
unset BASH_CONFIG_DIR config_module module_file
