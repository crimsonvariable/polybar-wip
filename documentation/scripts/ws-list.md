# ws-list.sh

Script path: `~/.config/polybar/scripts/ws-list.sh`

## Purpose

Custom i3 workspace renderer with clickable `[1]...[10]` segments and theme-reactive colors.

## Inputs / Flags

No flags.

## Data sources

- `i3-msg -t get_workspaces`
- `/tmp/polybar-theme.state`

From workspace JSON it computes:

- existing workspaces
- focused workspace
- visible workspaces
- urgent workspaces

## Output format

- Polybar clickable segments:
  - `%{A1:i3-msg workspace number N >/dev/null:}%{F#...}[N]%{F-}%{A}`

## Color model

Each workspace slot 1..10 is colored by state priority:

1. focused
2. urgent
3. visible
4. exists
5. empty

Theme-specific palettes are hard-coded for the available themes.

## Polybar integration

Used by:

- `[module/ws-list]`
- appears in main and workspace-only bars

## Manual test

```bash
~/.config/polybar/scripts/ws-list.sh
```
