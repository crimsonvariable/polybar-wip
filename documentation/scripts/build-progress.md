# build-progress.sh

Script path: `~/.config/polybar/scripts/build-progress.sh`

## Purpose

Tracks build/emerge progress for Polybar, including fetch ETA parsing when available.

## Inputs / Flags

- default: emit current status string
- `--ingest`: read build output from stdin and update state
- `--reset`: clear state file

## Output format

Possible outputs include:

- `idle`
- `fetch`
- `NNN% ETA` (e.g. `089% 15s`) from `emerge-fetch.log`
- `emerge`
- `emerge NNN%`
- `done`

Percent values are zero-padded to 3 digits.

## Data sources

- Process check: `pgrep ... emerge`
- Logs:
  - `/var/log/emerge.log`
  - `/var/log/portage/emerge.log`
  - `/var/tmp/portage/.emerge.log`
  - `/var/log/emerge-fetch.log`

## State files

- `/tmp/polybar-build-progress.state`

State format: `percent|active|updated_epoch`

## Polybar module integration

Used by:

- `[module/build-percent]` in `config.conf`

## Behavior notes

- If not running through ingest wrapper, script still tries to detect active emerge via process + logs.
- Fetch progress is preferred when fetch log is fresh.
- If logs are unreadable, falls back to coarse strings (`emerge`, `fetch`, `idle`).

## Manual test

```bash
~/.config/polybar/scripts/build-progress.sh
~/.config/polybar/scripts/build-progress.sh --reset
```
