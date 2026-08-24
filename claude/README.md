# Claude Code

## What was found on the source machine

- **Install method**: native standalone installer (`curl -fsSL
  https://claude.ai/install.sh | bash`) — *not* npm, *not* a distro
  package. It self-manages versioned binaries under
  `~/.local/share/claude/versions/<version>/`, symlinked from
  `~/.local/bin/claude`, and self-updates in place (confirmed via
  `~/.claude.json`'s `installMethod: "native"` and
  `~/.claude/.last-update-result.json`).
- **Shell integration**: nothing beyond `~/.local/bin` being on `PATH`
  (see `bash/bashrc.block`). No aliases, no completion script.
- **User-level commands/agents/skills/hooks**: none configured — this is
  a stock install plus one plugin (`humanizer`) and a handful of
  preference tweaks in `settings.json`.
- **MCP servers**: none configured, globally or per-project.
- **Auth**: OAuth via `~/.claude/.credentials.json` (mode 0600). No
  `ANTHROPIC_API_KEY` in the environment.

## Installing

`./install.sh` (the main installer) calls `claude/install.sh`, which:

1. Checks whether `claude` is already on `PATH` and actually runs
   (`claude --version`). If so, it's left alone — the native installer
   manages its own updates, so this repo doesn't fight it.
2. Otherwise, runs the official native installer
   (`curl -fsSL https://claude.ai/install.sh | bash`).
3. Falls back to `npm install -g @anthropic-ai/claude-code` only if the
   native installer isn't usable (no `curl`) and `npm` is available.
4. Verifies the result with `claude --version`.

No root required — everything installs under `$HOME`.

## Authentication (you must do this yourself, on each new machine)

**Nothing in this repo can authenticate Claude Code for you, and nothing
here contains credentials.** After install, run:

```bash
claude          # first run walks you through OAuth login interactively
```

or, for a headless/CI/remote box with no browser available, generate a
long-lived token *on a machine where you can complete the interactive
flow* and copy just the token to the headless box:

```bash
claude setup-token   # prints a token; export it as ANTHROPIC_API_KEY
                      # (or whatever the installed version's docs say)
                      # on the headless machine, out-of-band -- never
                      # commit it anywhere in this repo
```

Check `claude --help` / `claude doctor` on the target machine for the
exact current mechanism — this changes between versions, and the
installer above always fetches whatever is current at install time.

## Configuration this repo does reproduce

- `config/settings.json.template` → installed to `~/.claude/settings.json`
  **only if that file doesn't already exist** (never overwrites your live
  preferences). Contains the model/theme/effort-level preferences and the
  `humanizer` plugin registration found on the source machine — no
  secrets.
- `config/settings.local.json.example` — a reference copy of the
  machine-local permission overrides found (`WebFetch`/`WebSearch`
  allowlist). Not installed automatically since `settings.local.json` is
  meant to be genuinely per-machine; copy it by hand if you want the same
  allowlist.

## Deliberately NOT reproduced

- `~/.claude/.credentials.json` — OAuth secret, excluded entirely, see
  Authentication above.
- `~/.claude.json` — contains `machineID`/`userID`/onboarding state that
  is inherently per-install; regenerated automatically on first run.
- Everything under `~/.claude/{cache,sessions,jobs,shell-snapshots,
  paste-cache,projects,plans,session-env,stats-cache.json,telemetry,
  history.jsonl,ide,file-history,backups}` — runtime state/cache, not
  configuration.
- Commands, agents, skills, hooks, MCP servers: **none existed** on the
  source machine to capture. If you add any later, the natural place for
  portable (non-secret) ones is `claude/commands/`, `claude/agents/`,
  `claude/skills/`, `claude/hooks/` in this repo, installed by symlinking
  into `~/.claude/{commands,agents,skills,hooks}/` — that plumbing isn't
  built yet since there's nothing to link, but the directories are ready.

## Remote / headless / non-interactive usage

Claude Code supports non-interactive invocation (`claude -p "prompt"` /
`--print`, exit-code-driven scripting) and MCP servers for tool
integration once you're authenticated — both are standard CLI
capabilities, not something this repo needs to configure. What *is*
environment-dependent, and what this repo sets up so those modes work
the same on any machine:

- `claude` resolvable on `PATH` (via `~/.local/bin`)
- A working `~/.claude/settings.json` with a sane default
  `permissions.defaultMode`
- No assumption of a GUI/browser being present at *runtime* — only the
  one-time interactive login needs that (or `claude setup-token` run
  elsewhere, see above)
