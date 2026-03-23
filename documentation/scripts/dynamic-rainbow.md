# dynamic-rainbow.sh

Script path: `~/.config/polybar/scripts/dynamic-rainbow.sh`

## Purpose

Central color engine for animated labels and text gradients.

## Inputs / Flags

- default mode: per-character flowing gradient
- `--block <text>`: one solid interpolated color across entire text block

Arguments after flag are treated as text payload.

## Output format

Polybar color tags:

- `%{F#RRGGBB}...%{F-}`

## Theme system

Themes are selected from `/tmp/polybar-theme.state`:

- `neon`, `synth`, `wired`, `mono`, `sunset`, `aurora`, `ember`, `ocean`, `acid`, `blood`

Animation mode/speed from `/tmp/polybar-flow.state`:

- mode: `flow`, `reverse`, `pulse`, `static`
- speed: integer (used in phase calculation)

## Core logic

- Creates continuous gradient over full text width.
- Uses color interpolation between theme palette stops.
- Applies time-based phase shift for motion.

## Polybar integration

Used by several modules for animated labels/text, including:

- `volume-label`
- `wifi-label`
- `bld-label`
- `custom-note`
- `gentoo-update` label text

## Manual test

```bash
~/.config/polybar/scripts/dynamic-rainbow.sh "HELLO"
~/.config/polybar/scripts/dynamic-rainbow.sh --block "CPU"
```
