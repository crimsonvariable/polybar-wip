# cpu-status.sh

Script path: `~/.config/polybar/scripts/cpu-status.sh`

## Purpose

Renders CPU usage as themed `ICONIC!` bar with zero-padded percent and temperature.

## Inputs / Flags

No flags.

## Output format

- `<animated CPU label> [<ICONIC bar>] NNN% <temp or -->`

Example:

- `CPU [ICONIC!] 034% 51C`

## Data sources

- Usage delta from `/proc/stat`
- Temperature from `TEMP_PATH` (default `/sys/class/hwmon/hwmon1/temp1_input`)
- Label color animation from `dynamic-rainbow.sh --block CPU`

## State files

- `/tmp/polybar-cpu-prev.state`

## Polybar integration

Used by `[module/cpu]`.

## Behavior notes

- Zero-padded percent keeps layout stable.
- If temp source is missing/unreadable, prints `--`.
- Bar color thresholds:
  - `<40`: green
  - `<70`: amber
  - `>=70`: red

## Manual test

```bash
~/.config/polybar/scripts/cpu-status.sh
```
