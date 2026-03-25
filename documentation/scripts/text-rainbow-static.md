# text-rainbow-static.sh

Script path: `~/.config/polybar/scripts/text-rainbow-static.sh`

## Purpose

Simple static per-letter rainbow helper (non-time-animated).

## Inputs / Flags

- positional text argument required

## Output format

- `%{F#...}` colored characters plus final `%{F-}` reset.

## Polybar integration

General helper script; currently not a primary module dependency in active config.

## Behavior notes

- Spaces are preserved uncolored.
- Palette is fixed inside script.

## Manual test

```bash
~/.config/polybar/scripts/text-rainbow-static.sh "CrimsonVAR Gentoo"
```
