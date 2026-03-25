# snapshot-create.sh

Script path: `~/.config/polybar/scripts/snapshot-create.sh`

## Purpose

Creates a timestamped local snapshot of the Polybar project and writes a stack handoff note for commit-oriented context.

## Inputs / Flags

- default: create snapshot in `/mnt/storage/backups/polybar/snapshots/`
- `--dest DIR`: custom destination root
- `--label TEXT`: append label to snapshot folder name
- `--help`: usage output

If the default HDD path is unavailable/unwritable, script falls back to:

- `~/.config/polybar/backups/snapshots/`

## Output artifacts

Inside each snapshot:

- copied project items:
  - `config.conf`
  - `backups/legacy/config.conf.jpfont.backup` (if present)
  - `launch.sh`
  - `scripts/`
  - `documentation/`
- generated files:
  - `documentation/STACK_AS_OF_LAST_COMMIT.md`
  - `MANIFEST.txt`

Also updates in destination root:

- `latest` symlink
- `LATEST_PATH.txt`

## Git metadata behavior

The stack note captures:

- branch name
- last commit hash/date/subject
- working tree change count

If no commit exists yet, it writes `no-commits-yet`.

## Manual test

```bash
~/.config/polybar/scripts/snapshot-create.sh
~/.config/polybar/scripts/snapshot-create.sh --label "manual-test"
```
