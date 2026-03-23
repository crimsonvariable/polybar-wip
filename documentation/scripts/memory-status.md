# memory-status.sh

Script path: `~/.config/polybar/scripts/memory-status.sh`

## Purpose

Renders RAM usage as an `ICONIC!` bar with zero-padded percent.

## Inputs / Flags

No flags.

## Output format

- `<animated RAM label> [<ICONIC bar>] NNN%`

## Data sources

- `/proc/meminfo`
  - `MemTotal`
  - `MemAvailable`

Usage formula:

- `used = MemTotal - MemAvailable`
- `pct = used * 100 / MemTotal`

## Polybar integration

Used by `[module/memory]`.

## Behavior notes

- Color threshold logic matches CPU/GPU/Wi-Fi style.
- Percent is zero-padded for stable width.

## Manual test

```bash
~/.config/polybar/scripts/memory-status.sh
```
