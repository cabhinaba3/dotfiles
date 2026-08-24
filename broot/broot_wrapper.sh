# Broot Shell Wrapper
#
# Broot needs a shell wrapper to be able to change the directory of your
# active terminal (since a child process cannot change the parent's directory).
#
# Source this file in your ~/.bashrc or ~/.zshrc like this:
# source /path/to/broot_wrapper.sh
#
# Then, use the `br` command to open broot. When you press Alt+Enter on a
# directory, it will quit broot and cd into that directory.

function br {
    local cmd cmd_file code
    cmd_file=$(mktemp)
    if broot --outcmd "$cmd_file" "$@"; then
        cmd=$(<"$cmd_file")
        command rm -f "$cmd_file"
        eval "$cmd"
    else
        code=$?
        command rm -f "$cmd_file"
        return "$code"
    fi
}
