# spacer-spinner.sh

Script path: `~/.config/polybar/scripts/spacer-spinner.sh`

## Purpose

Render a Portage-style spinner frame (`/ - \ |`) for Polybar spacer animation modules.

## Inputs / Flags

- default: forward direction
- `--reverse`: reverse direction (used for mirrored left/right spinner effect)

## Environment variables

- `SPACER_SPINNER_STEP_MS` (default `120`): frame step speed in ms, minimum `40`
- `SPACER_SPINNER_PIPE` (default `spacer`): `theme-engine` pipe/channel name
- Backward compatible aliases:
  - `PORTAGE_SPINNER_STEP_MS`
  - `PORTAGE_SPINNER_PIPE`

## Output format

Single spinner character with Polybar color formatting from `theme-engine.sh --block`.

## Polybar integration

Used by:

- `[module/spacer-spin-left]` with `--reverse`
- `[module/spacer-spin-right]` default direction

These spinner modules now use an independent color pipe (`spacer`) so they can be themed separately from the rest of the bar.

## Manual test

```bash
~/.config/polybar/scripts/spacer-spinner.sh
~/.config/polybar/scripts/spacer-spinner.sh --reverse
SPACER_SPINNER_PIPE=main ~/.config/polybar/scripts/spacer-spinner.sh
```
