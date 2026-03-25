# volume-status.sh

Script path: `~/.config/polybar/scripts/volume-status.sh`

## Purpose

Outputs current sink volume in stable zero-padded percent format.

## Inputs / Flags

No flags.

## Output format

- `NNN%`
- `muted`
- `N/A`

## Detection order

1. `wpctl get-volume @DEFAULT_AUDIO_SINK@`
2. `pactl get-sink-* @DEFAULT_SINK@`

## Polybar integration

Used by `[module/volume]`.

`[module/volume-label]` is separate and rendered by `theme-engine.sh --block VOL`.

## Manual test

```bash
~/.config/polybar/scripts/volume-status.sh
```
