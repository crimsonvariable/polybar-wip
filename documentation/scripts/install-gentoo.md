# install-gentoo.sh

Script path: `~/.config/polybar/scripts/install-gentoo.sh`

## Purpose

Installs this Polybar repository into `~/.config/polybar` on a Gentoo machine.

## Inputs / Flags

- default: install into `~/.config/polybar` with backup
- `--target DIR`: custom install target
- `--no-backup`: skip backup copy
- `--force`: force backup behavior when target exists
- `--help`: usage text

## What it does

1. Validates repo structure
2. Backs up existing target (timestamped)
3. Rsyncs repo files into target (excluding `.git`, `backups`, `.gitignore`)
4. Ensures launcher/scripts are executable
5. Prints dependency and i3 autostart reminders

## Manual test

```bash
~/.config/polybar/scripts/install-gentoo.sh --help
~/.config/polybar/scripts/install-gentoo.sh
```
