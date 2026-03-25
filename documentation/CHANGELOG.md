# Changelog

This file tracks notable repo-level changes in plain language.

## 2026-03-25

### Added

- New Polybar screenshot action module: `SHOT` (`[module/flameshot]`).
- New module docs folder: `documentation/modules/`.
- New module page: `documentation/modules/flameshot.md`.

### Changed

- i3 screenshot keybinds:
  - `Print` -> `flameshot gui`
  - `Shift+Print` -> full screenshot to `~/Pictures/Screenshots`
- `launch.sh` now uses a generation lock (`/tmp/polybar-launch.id`) to prevent duplicate delayed bar spawns.
- `gentoo-update.sh` now:
  - handles step failures with continue/stop prompts
  - pre-checks for missing `en_US.UTF-8` before `@world`
- Documentation refreshed to match current behavior:
  - overview, dependencies, support, environment, install guide, launch/updater script pages

## Notes

- Snapshot documentation under `backups/snapshots/` remains archival and is not rewritten on every live-doc update.
