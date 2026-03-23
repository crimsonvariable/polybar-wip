# candy-loop.sh

Script path: `~/.config/polybar/scripts/candy-loop.sh`

## Purpose

Main looping Pac-Man style animation module with dynamic lane length and text-reveal trail.

## Inputs / Flags

No flags currently.

## Output format

Single-line animated payload:

- `[<colored lane>] NNN%`

Where lane contains:

- revealed trail text behind Pac-Man (`C` / `c`)
- white candies (`o`) ahead
- dot separators and colorized segments

## Core behavior

- Dynamic lane length based on `trail_text` length (clamped range).
- Startup delay before motion begins.
- Nonlinear mouth animation (`C`/`c`) based on tick pattern.
- Holds at 100% for configured `hold_ms`.
- Emits cycle-complete signal when phase wraps.

## State files

- `/tmp/polybar-candy-loop.state` (last phase)
- `/tmp/polybar-candy-cycle.count` (completed cycles)
- `/tmp/polybar-candy-loop.start` (start timing)

## Polybar module integration

Used by:

- `[module/candy-loop]`

Also drives word switching in `load-word.sh` through `polybar-candy-cycle.count`.

## Modularity points

Change these directly in script:

- `trail_text`
- `step_ms`
- `hold_ms`
- dynamic lane min/max clamp

## Manual test

```bash
~/.config/polybar/scripts/candy-loop.sh
watch -n 0.2 ~/.config/polybar/scripts/candy-loop.sh
```
