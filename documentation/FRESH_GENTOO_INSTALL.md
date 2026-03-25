# Fresh Gentoo Install Guide

Use this if you want to clone the Polybar repo and apply it quickly on a new Gentoo install.

## 1. Clone the repo

```bash
git clone git@github.com:crimsonvariable/polybar-wip.git
cd polybar-wip
```

If your repository name is different, replace `polybar-wip` in commands.

## 2. Install core runtime tools

Minimum commands expected by this setup:

- `polybar`
- `xrandr`
- `i3-msg`
- `kitty`
- `playerctl`
- `wpctl` or `pactl`
- `iw` and/or `iwctl`
- `nvidia-smi` (only if using NVIDIA module)
- `fastfetch` (optional visual extras)
- `flameshot` (screenshot module + i3 screenshot binds)
- `rofi` (TOOLS launcher module)

## 3. Apply config into `~/.config/polybar`

From repo root:

```bash
./scripts/install-gentoo.sh
```

The installer:

- backs up existing `~/.config/polybar` (timestamped)
- copies current repo files
- fixes executable bits on launcher/scripts

## 4. Ensure i3 autostart line exists

In `~/.config/i3/config`, include:

```ini
exec_always --no-startup-id ~/.config/polybar/launch.sh
```

## 5. Start Polybar

```bash
~/.config/polybar/launch.sh
```

## 6. Screenshot target directory (recommended)

```bash
mkdir -p ~/Pictures/Screenshots
```

This is used by:
- i3 `Shift+Print` full screenshot bind
- Polybar `SHOT` module right-click action

## 7. Optional post-install checks

```bash
bash -n ~/.config/polybar/launch.sh
bash -n ~/.config/polybar/scripts/*.sh
tail -n 80 /tmp/polybar-launch.log
```

## 8. Notes

- This is a WIP personal setup, intentionally customized.
- Read `documentation/ENVIRONMENT.md` and `documentation/DEPENDENCIES.md` before debugging.
