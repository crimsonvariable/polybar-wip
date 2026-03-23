# startup-load.sh

Script path: `~/.config/polybar/scripts/startup-load.sh`

## Purpose

Boot-only progress animation shown in the dedicated `boot` bar before main bars appear.

## Inputs / Flags

- default: print current animation frame
- `--alive`: exit 0 while startup animation window is still active
- `--done`: exit 0 when animation position has reached full cells

## Environment variables

- `STARTUP_SECS` (default 10)
- `STARTUP_HOLD_SECS` (default 5)

These are exported by `launch.sh`.

## Output format

- `<animated label> [<pacman lane>] NNN%`

Internally combines:

- eaten region (`#`)
- current head (`C`/`c`)
- remaining candies (`o`)

## State files

- `/tmp/polybar-startup.until`
- `/tmp/polybar-startup.pos`

## Polybar integration

Used by `[module/startup-load]` in `[bar/boot]`.

`launch.sh` waits for `--done` before starting main bars, then kills boot bar.

## Manual test

```bash
STARTUP_SECS=10 STARTUP_HOLD_SECS=5 ~/.config/polybar/scripts/startup-load.sh
~/.config/polybar/scripts/startup-load.sh --alive; echo $?
~/.config/polybar/scripts/startup-load.sh --done; echo $?
```
