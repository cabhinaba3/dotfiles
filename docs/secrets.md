# Secrets

## What was found on the source machine, and excluded

| Item | Where | Disposition |
|---|---|---|
| `GEMINI_API_KEY` | live in `~/.bashrc` | **Real API key.** Not ported anywhere. `bash/bashrc.block` sources `~/.bashrc.local` (gitignored, machine-local) for exactly this kind of value — see `bash/local.env.example`. |
| `~/.claude/.credentials.json` | Claude Code OAuth store | Excluded entirely. Re-authenticate on each machine via `claude` (interactive) — see `claude/README.md`. |
| `~/.ssh/id_ed25519` | SSH private key | Excluded. Generate a new keypair per machine, or copy the private key out-of-band (never through this repo) if you need the same identity everywhere. |
| `~/.ssh/known_hosts`, `known_hosts.old` | SSH | Excluded (also just good practice — stale host-key caches aren't useful to carry between machines). |
| A `.pem` file under `~/Downloads/...` referenced by `~/.ssh/config` | personal remote-testbed key | Excluded. `ssh/config.d/ilabt-testbed.example` templates the path as `{{PATH_TO_YOUR_ILABT_PEM_KEY}}`. |
| `~/.git-credentials` | did not exist on this machine | N/A — but `.gitignore` still excludes the pattern in case it ever does. |
| `~/.config/gh/hosts.yml` | GitHub CLI wasn't installed | N/A — pattern still excluded for the same reason. |
| `CLAUDE_CODE_MESSAGING_TOKEN`, `STARSHIP_SESSION_KEY` | ephemeral runtime env vars | Not secrets in the traditional sense (regenerated every session) but never captured — they're process-local, not configuration. |
| `pass` password-store contents | `~/.password-store/` (implied by `pass` being installed) | Never inspected, never captured. |

## How this repo protects against re-introducing secrets

- `.gitignore` at the repo root excludes `*.local`, `.bashrc.local`,
  `*.pem`, `*.key`, `id_rsa*`, `id_ed25519*` (non-`.pub`), `.credentials.json`,
  `.git-credentials`, `hosts.yml`, and `.env`/`.env.*` — so even an
  accidental `cp` of a real key into the repo won't get committed.
- No script in this repo ever calls `git add`/`git commit`/`git push` —
  installing dotfiles never touches git history. You control what gets
  committed and when.
- Every `*.example` / `*.template` file that stands in for something
  personal uses `{{PLACEHOLDER}}` syntax, not a real value with a comment
  saying "change this."

## If you find a secret in a file here anyway

Treat it as a bug: rotate the credential immediately (assume it's
compromised the moment it touched a file, even a local one), then remove
it from this repo and from git history (`git filter-repo` or BFG, not a
plain `rm` + commit, since the old blob stays in history otherwise).
