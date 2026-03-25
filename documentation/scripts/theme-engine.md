# theme-engine.sh

Script path: `~/.config/polybar/scripts/theme-engine.sh`

## Purpose

Central color engine for animated labels and text gradients.

## Inputs / Flags

- default mode: per-character flowing gradient
- `--block <text>`: one solid interpolated color across entire text block
- `--pipe <name>`: use an independent theme/flow state channel
- `--channel <name>`: alias for `--pipe`

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

Named pipes/channels use:

- `/tmp/polybar-theme.<name>.state`
- `/tmp/polybar-flow.<name>.state`

Example: `--pipe spacer` uses `/tmp/polybar-theme.spacer.state`.

## Core logic

- Creates continuous gradient over full text width.
- Uses color interpolation between theme palette stops.
- Applies time-based phase shift for motion.

## Polybar integration

Used by several modules for animated labels/text, including:

- `volume-label`
- `wifi-label`
- `bld-label`
- `tools-launcher` (`TOOLS`)
- `identity-label`
- `gentoo-update` label text

## Manual test

```bash
~/.config/polybar/scripts/theme-engine.sh "HELLO"
~/.config/polybar/scripts/theme-engine.sh --block "CPU"
~/.config/polybar/scripts/theme-engine.sh --pipe spacer --block "/"
```
