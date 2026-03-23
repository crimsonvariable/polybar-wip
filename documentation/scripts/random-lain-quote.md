# random-lain-quote.sh

Script path: `~/.config/polybar/scripts/random-lain-quote.sh`

## Purpose

Prints one random bilingual quote block with color-coded lines.

## Data source

- `~/.config/polybar/scripts/lain-quotes.tsv`
- TSV columns expected:
  1. English quote
  2. Japanese quote
  3. attribution line

## Selection logic

- Uses `shuf -n 1` when available
- Falls back to `awk` random line selection

## Output format

Three terminal lines:

- English (white)
- Japanese (magenta)
- Name/source (soft blue)

ANSI escape colors are used (for terminal output, not Polybar tags).

## Polybar integration

Used by `gentoo-update.sh` before prompts and at completion.

## Failure behavior

- If quote file is missing/unreadable, prints a safe fallback message.

## Manual test

```bash
~/.config/polybar/scripts/random-lain-quote.sh
```
