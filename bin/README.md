Reserved for hand-written personal scripts you want on `PATH` on every
machine (this repo's `install.sh` doesn't put anything here automatically
yet). The audit that built this repo found nothing in the source
machine's `~/.local/bin` worth vendoring — it was all installer-managed
binaries/symlinks (Claude Code, uv, distant, pip shims), not hand-written
scripts. See `docs/machine-specific.md`.

If you add a script here, symlink it from `~/.local/bin/<name>` (already
on `PATH`, see `bash/bashrc.block`) the same way `scripts/link-configs.sh`
links everything else.
