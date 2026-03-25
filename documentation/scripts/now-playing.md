# now-playing.sh

Script path: `~/.config/polybar/scripts/now-playing.sh`

## Purpose

Displays current media metadata with source tag and fixed-width scrolling text to prevent center-layout jitter.

## Inputs / Flags

No flags.

Environment variable:

- `NOW_PLAYING_WIDTH` (default: `34`)

## Output format

- `<TAG> <payload>`
- Tag is colorized (`%{F#e60053}`)

Example tag map:

- `SP` Spotify
- `MP` mpv
- `FR` Firefox
- `CH` Chrome/Chromium/Brave/Edge family
- fallback: `PL`

## Behavior

- Uses `playerctl` for status + metadata.
- Selects one target player source (`Playing` preferred, then `Paused`, then first available).
- Reads status and metadata from that same selected player to avoid cross-player mismatches.
- If stopped/unavailable, prints `stopped`.
- If paused, prefixes with `[PAUSED]`.
- Scrolls long text using a persistent offset state.
- Pads short text to fixed width.

## State files

- `/tmp/polybar-now-playing.state`

## Polybar integration

Used by `[module/now-playing]`.

## Manual test

```bash
~/.config/polybar/scripts/now-playing.sh
NOW_PLAYING_WIDTH=40 ~/.config/polybar/scripts/now-playing.sh
```
