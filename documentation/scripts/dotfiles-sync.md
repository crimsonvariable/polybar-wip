# dotfiles-sync.sh

Script path: `~/.config/polybar/scripts/dotfiles-sync.sh`

## Purpose

Syncs your live `~/.config` into the private dotfiles repository profile and optionally handles commit + push in one interactive flow.

## Inputs / Flags

- default: sync profile and prompt for commit/push
- `--quick`: sync only, no commit/push prompt
- `--help`: usage text
- positional profile: profile name (default `gentoo`)

Environment variable:

- `DOTFILES_REPO` (default: `~/dotfiles-private`)

## What it does

1. Resolves target dotfiles repo and profile.
2. Calls `<repo>/scripts/sync-from-system.sh <profile>`.
3. Prints `git status --short` in the dotfiles repo.
4. In normal mode:
   - asks whether to commit/push
   - asks for commit message (with default message)
   - runs `git add .`, `git commit`, `git push`
5. In quick mode: exits after sync + status output.

## Polybar integration

Used by `[module/dotfiles-sync]` in `config.conf`:

- left click: interactive sync/commit/push flow in Kitty
- right click: quick sync mode in Kitty

## Dependencies and assumptions

- `git`
- `~/dotfiles-private/scripts/sync-from-system.sh` exists and is executable
- remote auth configured for push (SSH key/token)

## Manual test

```bash
~/.config/polybar/scripts/dotfiles-sync.sh --quick gentoo
~/.config/polybar/scripts/dotfiles-sync.sh gentoo
```
