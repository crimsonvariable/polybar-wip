# Environment and Stack Context

This file explains the host environment so script decisions and breakage patterns make sense.

Last updated: 2026-03-25

## Base system

- Distro: Gentoo Linux 2.18
- Profile: `default/linux/amd64/23.0`
- Kernel: `Linux 6.18.12-gentoo-x86_64`
- User shell: `fish` (`/usr/bin/fish`)

## Session stack

- Display server: X11
- Session start: `~/.xinitrc`
- Window manager: i3 (default `SESSION=i3`)
- Polybar launch path: `exec_always --no-startup-id ~/.config/polybar/launch.sh` in `~/.config/i3/config`
- Screenshot actions:
  - i3: `Print` -> `flameshot gui`
  - i3: `Shift+Print` -> `flameshot full -p ~/Pictures/Screenshots`
  - Polybar module: `SHOT` click actions wired to same commands
- Tools menu actions:
  - Polybar module: `TOOLS` -> `~/.config/polybar/scripts/tools-launcher.sh`
  - Wrapper target: `~/.config/rofi/scripts/tool-hub.sh`

## Monitor topology assumptions

From current X setup:

- `DisplayPort-0`: primary, 2560x1440 @ 165 Hz
- `DisplayPort-1`: 2560x1440 @ 155 Hz, rotated left
- `DisplayPort-2`: 2560x1440 @ 155 Hz, rotated right

Polybar depends on monitor names and XRandR visibility for multi-bar mapping.

## Audio stack assumptions

- PipeWire + WirePlumber + pipewire-pulse compatibility
- `volume-status.sh` tries `wpctl` first, then `pactl`
- `~/.xinitrc` calls `~/.config/i3/scripts/audio-recover.sh`

If audio modules misbehave, check PipeWire/WirePlumber process state first.

## Network stack assumptions

- Primary Wi-Fi tools: `iw` / `iwctl` (`iwd` style workflow)
- Optional fallback: `nmcli` if available
- Interface default in scripts: `wlan0` (can be overridden with `WIFI_IFACE`)

## GPU assumptions

- AMD + NVIDIA dual-path support in script logic
- AMD stats: `/sys/bus/pci/devices/*/gpu_busy_percent`
- NVIDIA stats: `nvidia-smi`
- If a GPU is unavailable or in VFIO/pass-through context, modules can return `N/A`

## Font assumptions

- Main style font: `Ac437 IBM VGA 9x16` (size set in Polybar config)
- Japanese fallback in Polybar: `Unifont-JP`

## Build/progress assumptions

- Build progress module parses emerge logs and fetch logs
- For detailed percentages, user needs read access to:
  - `/var/log/emerge.log`
  - `/var/log/emerge-fetch.log`

## Storage context

Current rotational HDD detected:

- `/dev/sda` (ST2000DM008-2UB1, 1.8T) mounted at `/mnt/storage`

## Why this matters

This project is intentionally environment-coupled.
When behavior changes after updates/reboots, compare current system state against this file first.
