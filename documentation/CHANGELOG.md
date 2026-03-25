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
- Added TOOLS action integration:
  - new script wrapper: `scripts/tools-launcher.sh`
  - new script docs page: `documentation/scripts/tools-launcher.md`
  - overview/index/dependency/support docs updated for tools hub path
- `now-playing.sh` player selection logic improved to avoid mixed-source `stopped` states

## Notes

- Snapshot documentation under `backups/snapshots/` remains archival and is not rewritten on every live-doc update.
