# theme-switch.sh

Script path: `~/.config/polybar/scripts/theme-switch.sh`

## Purpose

State manager and control UI for theme palettes and animation modes used by `dynamic-rainbow.sh`.

## Inputs / Flags

- `--label`: print compact status label for Polybar
- `--next`: cycle to next theme
- `--next-mode`: cycle to next mode
- `--menu`: open interactive terminal menu
- `--help`: usage/help text

## State files

- `/tmp/polybar-theme.state`
- `/tmp/polybar-flow.state`

`/tmp/polybar-flow.state` format: `<mode> <speed>`

## Interactive menu actions

1. Set theme by index
2. Cycle theme
3. Set mode by index
4. Cycle mode
5. Slow speed (120)
6. Medium speed (220)
7. Fast speed (360)
8. Custom speed (20-1000)
9. Exit

## Output format

`--label` prints:

- `%{F<theme_color>}[THM:THEME|MODE]%{F-}`

Used directly by Polybar module text.

## Polybar integration

Used by `[module/theme-switch]`:

- left click -> `--next`
- middle click -> `--next-mode`
- right click -> `kitty -e ... --menu`

## Manual test

```bash
~/.config/polybar/scripts/theme-switch.sh --label
~/.config/polybar/scripts/theme-switch.sh --next
~/.config/polybar/scripts/theme-switch.sh --next-mode
kitty -e ~/.config/polybar/scripts/theme-switch.sh --menu
```
