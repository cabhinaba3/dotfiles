# systemd --user units

Only `distant-manager.service` was found to be genuinely user-authored on
the source machine (a background listener for the
[`distant`](https://github.com/chipsenkbeil/distant) remote-dev CLI). It's
templated with `{{HOME}}` instead of a hardcoded path and only installed
if both systemd and the `distant` binary are present
(`scripts/link-configs.sh:link_systemd_user_units`).

Everything else enabled under `systemctl --user` on the source machine
(`wireplumber`, `pipewire*`, `gnome-keyring-daemon`, `p11-kit-server`,
`xdg-user-dirs`, `speech-dispatcher`) is shipped and enabled by the
relevant packages themselves (audio stack, keyring, etc.) — reproducing
those here would just be redundant with installing the packages, so
they're intentionally not tracked as "dotfiles."
