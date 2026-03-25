# status-word-cycle.sh

Script path: `~/.config/polybar/scripts/status-word-cycle.sh`

## Purpose

Displays rotating themed words (Lain + Gentoo + easter eggs) with color accent tied to CPU load.

## Inputs / Flags

No flags.

Environment variable:

- `STATUS_WORD_ALLOW_WIDE=1`
  - allows non-ASCII/wide glyph words in random pool
- Backward compatible alias: `LOAD_WORD_ALLOW_WIDE=1`

## Output format

- Fixed-width colored word (default width `DISPLAY_LEN=10`)
- Non-space chars use load accent color

## Switching model

Word index is tied to candy animation cycle count:

- reads `/tmp/polybar-candy-cycle.count`
- index = `cycle % word_count`

This makes switching feel synchronized with the loop animation.

## Data sources

- CPU load from `/proc/stat` delta
- theme file `/tmp/polybar-theme.state` only affects base gray variant in mono mode

## State files

- `/tmp/polybar-status-word-prev.state`
- consumes `/tmp/polybar-candy-cycle.count`

## Polybar integration

Used by `[module/status-word-cycle]`.

## Modularity points

- Edit `words=(...)` list to add/remove terms.
- `DISPLAY_LEN` controls layout stability.

## Manual test

```bash
~/.config/polybar/scripts/status-word-cycle.sh
STATUS_WORD_ALLOW_WIDE=1 ~/.config/polybar/scripts/status-word-cycle.sh
```
