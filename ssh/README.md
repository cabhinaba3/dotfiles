# SSH configuration — opt-in only

`install.sh` **never** touches `~/.ssh` automatically. SSH config is too
personal (usernames, key paths, which remote hosts even exist) and too
sensitive to script blindly. This directory only holds sanitized templates.

## What's here

- `config.d/defaults.example` — generic, secret-free `Host *` block (safe
  to adopt on any machine).
- `config.d/ilabt-testbed.example` — a template for this user's personal
  remote-testbed access. Hostnames/usernames are real (they're not
  secrets), but the private key path is a placeholder — the actual `.pem`
  key must be copied to the new machine out-of-band (e.g. a password
  manager attachment or `scp` over an already-trusted channel) and never
  committed here.

## How to use

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
cat ssh/config.d/defaults.example >> ~/.ssh/config
# edit in your own values, then optionally:
cat ssh/config.d/ilabt-testbed.example >> ~/.ssh/config
chmod 600 ~/.ssh/config
```

## What is never captured in this repo

- Private keys (`id_ed25519`, `id_rsa`, any `.pem`/`.ppk` file)
- `known_hosts` / `known_hosts.old`
- `authorized_keys`
- Any SSH agent socket or forwarded-agent state

Generate a new keypair on each new machine (`ssh-keygen -t ed25519`) and
register the **public** key with whatever remote services you need —
don't copy private key material between machines through this repo.
