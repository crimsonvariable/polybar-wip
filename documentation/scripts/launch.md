# launch.sh

Script path: `~/.config/polybar/launch.sh`

## Purpose

Primary Polybar orchestrator. Starts bars in staged order, writes launch diagnostics, and handles monitor-aware bar placement.

## Inputs / Flags

No flags.

## Launch lifecycle

1. Kills running Polybar instances.
2. Waits for old instances to exit.
3. Writes monitor/session diagnostics to `/tmp/polybar-launch.log`.
4. Sets startup deadline in `/tmp/polybar-startup.until`.
5. Starts `bar/boot` on primary monitor (if detected).
6. Waits for `scripts/startup-load.sh --done` and then holds for `STARTUP_HOLD_SECS`.
7. Starts `bar/main` and `bar/main2`.
8. Starts `bar/workspaces-only` on each non-primary monitor.
9. Stops boot bar process.

## Runtime files

- `/tmp/polybar-launch.log`
- `/tmp/polybar-startup.until`

## Environment exported

- `STARTUP_SECS` (currently `10`)
- `STARTUP_HOLD_SECS` (currently `5`)

These are consumed by `startup-load.sh`.

## Dependencies and assumptions

- `polybar`
- `xrandr`
- `pgrep` / `killall`
- `~/.config/polybar/config.conf` with bars: `boot`, `main`, `main2`, `workspaces-only`

## Manual test

```bash
~/.config/polybar/launch.sh
tail -n 120 /tmp/polybar-launch.log
```
