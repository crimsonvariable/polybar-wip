# Polybar Dependencies and Compatibility

This file lists every practical dependency for the current configuration and scripts, including optional fallbacks.

## Core runtime (required)

- `polybar`
- `bash`
- `awk`, `sed`, `grep`, `cut`, `tr`, `head`, `tail`, `md5sum`, `stat`
- `xrandr`
- `i3-msg`
- `killall`, `pgrep`

Without these, one or more bars/modules fail hard.

## Polybar script dependencies by feature

## Audio

- Primary: `wpctl` (PipeWire)
- Fallback: `pactl` (PulseAudio compatibility)
- Script: `scripts/volume-status.sh`
- Behavior:
  - If `wpctl` works, its value is used.
  - Else if `pactl` works, that value is used.
  - Else output is `N/A`.

## Media / Now Playing

- `playerctl`
- Script: `scripts/now-playing.sh`
- Behavior:
  - If missing, module falls back to `ST stopped`.

## Wi-Fi

- Interface tools: `iw` and/or `iwctl` and/or `nmcli`
- Optional SSID helper: `iwgetid`
- Kernel source: `/proc/net/wireless`
- Script: `scripts/wifi-status.sh`
- Behavior:
  - Multiple detection paths are implemented.
  - If none work, signal tends to degrade to `0` and/or `disconnected` text.

## GPU

- NVIDIA path: `nvidia-smi`
- AMD path: `/sys/bus/pci/devices/*` (`vendor=0x1002`, `gpu_busy_percent`)
- Script: `scripts/gpu-status.sh`
- Behavior:
  - Missing vendor tools/files returns `N/A` output for that segment.

## Build progress / Gentoo emerge

- Log sources:
  - `/var/log/emerge.log`
  - `/var/log/portage/emerge.log`
  - `/var/tmp/portage/.emerge.log`
  - `/var/log/emerge-fetch.log`
- Script: `scripts/build-progress.sh`
- Behavior:
  - If logs are unreadable (permissions), percent detail is limited.

## Theme and terminal interactions

- `kitty` for click-open menus and updater terminal flow
- Scripts:
  - `scripts/theme-switch.sh`
  - `scripts/gentoo-update.sh`

## Screenshot module / i3 screenshot binds

- `flameshot`
- Save path used by full-shot action: `~/Pictures/Screenshots`
- Integrations:
  - i3 binds: `Print`, `Shift+Print`
  - Polybar action module: `flameshot` (`SHOT`)

## Gentoo updater workflow

- `sudo`
- `emerge`
- Optional but recommended:
  - `dispatch-conf` (preferred config merge)
  - `etc-update` (fallback)
  - `eselect`
  - `fastfetch`
- Script: `scripts/gentoo-update.sh`
- Note:
  - `app-shells/pwsh` may require locale `en_US.UTF-8` to exist in `locale -a`
  - updater script now warns before `@world` if locale is missing

## Quote system

- `shuf` (preferred random selector)
- Fallback randomization uses `awk` only
- Data file: `scripts/lain-quotes.tsv`
- Script: `scripts/random-lain-quote.sh`

## State files and writable paths

These scripts persist state under `/tmp`:

- `/tmp/polybar-theme.state`
- `/tmp/polybar-flow.state`
- `/tmp/polybar-candy-loop.state`
- `/tmp/polybar-candy-cycle.count`
- `/tmp/polybar-candy-loop.start`
- `/tmp/polybar-startup.until`
- `/tmp/polybar-startup.pos`
- `/tmp/polybar-loadword-prev.state`
- `/tmp/polybar-now-playing.state`
- `/tmp/polybar-wifi-scroll.state`
- `/tmp/polybar-cpu-prev.state`
- `/tmp/polybar-build-progress.state`
- `/tmp/polybar-launch.id`

These are recreated automatically when missing.

## Permission-sensitive items

## Emerge logs

To show detailed build/fetch progress in non-root Polybar:

- Ensure your user can read emerge logs.
- Typical options:
  - ACLs (`setfacl`)
  - group membership if logs are group-readable
  - custom log path permissions

## Sudo-using scripts

- `scripts/gentoo-update.sh` intentionally prompts and runs privileged commands only with explicit user confirmation.

## Optional extras

- `fastfetch` (nice final visual in updater)
- `lolcat` (not currently required by scripts)

## Quick dependency check snippet

```bash
for c in polybar bash xrandr i3-msg kitty flameshot playerctl wpctl pactl iw iwctl nmcli nvidia-smi fastfetch sudo emerge; do
  command -v "$c" >/dev/null 2>&1 && echo "ok  $c" || echo "miss $c"
done
```
