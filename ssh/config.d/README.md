# `~/.ssh/config.d/`

Drop-in SSH host blocks. Nothing in this directory is installed
automatically by `install.sh` — SSH host config is personal/machine
opt-in only (see [`../README.md`](../README.md)). Each `*.example` file
here documents a snippet you can copy into `~/.ssh/config` (or into
`~/.ssh/config.d/` with an `Include ~/.ssh/config.d/*.conf` line at the
top of `~/.ssh/config`, if you'd rather keep them split) after filling
in your own key path and username.
