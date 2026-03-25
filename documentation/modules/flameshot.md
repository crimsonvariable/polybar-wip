# flameshot module (`SHOT`)

Config location: `~/.config/polybar/config.conf`

## Purpose

Provides a fast screenshot action in Polybar without opening a separate menu module.

## Polybar wiring

Module block:

```ini
[module/flameshot]
type = custom/script
exec = ~/.config/polybar/scripts/theme-engine.sh --block 'SHOT'
interval = 0.2
click-left = flameshot gui
click-right = flameshot full -p ~/Pictures/Screenshots
```

Placed in bar:

```ini
[bar/main2]
modules-left = identity-label gentoo-update theme-control flameshot tools-launcher repo-sync
```

## Click actions

- Left click: interactive region capture (`flameshot gui`)
- Right click: full-screen save to `~/Pictures/Screenshots`

## Matching i3 binds

In `~/.config/i3/config`:

- `bindsym Print exec --no-startup-id flameshot gui`
- `bindsym Shift+Print exec --no-startup-id flameshot full -p ~/Pictures/Screenshots`

## Dependencies

- `flameshot`
- writable screenshot target directory (`~/Pictures/Screenshots`)

## Manual test

```bash
command -v flameshot
mkdir -p ~/Pictures/Screenshots
flameshot gui
flameshot full -p ~/Pictures/Screenshots
```
