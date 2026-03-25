# theme-control.sh

Script path: `~/.config/polybar/scripts/theme-control.sh`

## Purpose

State manager and control UI for theme palettes and animation modes used by `theme-engine.sh`.

## Inputs / Flags

- `--pipe <name>`: target a named channel (defaults to `main`)
- `--label`: print compact status label for Polybar
- `--next`: cycle to next theme
- `--next-mode`: cycle to next mode
- `--menu`: open interactive terminal menu
- `--help`: usage/help text

If `--menu` is opened without `--pipe`, it first asks:

- `A` -> `main`
- `B` -> `spacer`

## State files

- `main` pipe:
  - `/tmp/polybar-theme.state`
  - `/tmp/polybar-flow.state`
- named pipe `<name>`:
  - `/tmp/polybar-theme.<name>.state`
  - `/tmp/polybar-flow.<name>.state`

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

Used by `[module/theme-control]`:

- left click -> `--next`
- middle click -> `--next-mode`
- right click -> `kitty -e ... --menu`

## Manual test

```bash
~/.config/polybar/scripts/theme-control.sh --label
~/.config/polybar/scripts/theme-control.sh --next
~/.config/polybar/scripts/theme-control.sh --next-mode
kitty -e ~/.config/polybar/scripts/theme-control.sh --menu
~/.config/polybar/scripts/theme-control.sh --pipe spacer --menu
```
