# gpu-status.sh

Script path: `~/.config/polybar/scripts/gpu-status.sh`

## Purpose

Renders GPU utilization bars and temperatures for NVIDIA and AMD with graceful `N/A` fallback.

## Inputs / Flags

- `--nv`: show NVIDIA segment only
- `--amd`: show AMD segment only
- default: show both segments on one line

## Output format

- `<LABEL> [<ICONIC bar>] NNN% <tempC>`
- If unavailable: `<LABEL> [ICONIC! gray] N/A`

## Detection paths

NVIDIA:

- `nvidia-smi --query-gpu=utilization.gpu,temperature.gpu`

AMD:

- `/sys/bus/pci/devices/*` with:
  - `vendor` == `0x1002`
  - class starts with `0x03`
  - `gpu_busy_percent`
- temp via matching `hwmon/*/temp1_input`

## Polybar integration

Used by:

- `[module/gpu-amd]` (`--amd`)
- `[module/gpu-nv]` (`--nv`)

## Behavior notes

- Uses same `ICONIC!` bar concept as CPU/RAM/Wi-Fi.
- Percent is 3-digit padded when numeric.
- Color threshold logic is load-based.

## Manual test

```bash
~/.config/polybar/scripts/gpu-status.sh --amd
~/.config/polybar/scripts/gpu-status.sh --nv
```
