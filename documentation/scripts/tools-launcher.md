# tools-launcher.sh

Script path: `~/.config/polybar/scripts/tools-launcher.sh`

## Purpose

Stable Polybar launcher wrapper for the external rofi tools hub script.

## Inputs / Flags

No flags.

## Output format

No normal stdout output (launch action script).

Error behavior:
- If target script is missing/not executable:
  - shows `rofi -e` popup when rofi exists
  - else prints error to stderr

## Target chain

- Wrapper target: `~/.config/rofi/scripts/tool-hub.sh`
- Expected launcher behavior is defined by that rofi-side script.

## Polybar module integration

Used by `[module/tools-launcher]` in `config.conf`:

- label text from `theme-engine.sh --block 'TOOLS'`
- left click runs `~/.config/polybar/scripts/tools-launcher.sh`

## Dependencies and assumptions

- `rofi`
- `~/.config/rofi/scripts/tool-hub.sh` exists and is executable

## Manual test

```bash
~/.config/polybar/scripts/tools-launcher.sh
ls -l ~/.config/polybar/scripts/tools-launcher.sh ~/.config/rofi/scripts/tool-hub.sh
command -v rofi
```
