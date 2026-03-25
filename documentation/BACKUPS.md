# Backups and Snapshots

This project uses timestamped local snapshots so you can roll back or hand off clean context quickly.

## One-command backup

```bash
~/.config/polybar/scripts/snapshot-backup.sh
```

Optional label:

```bash
~/.config/polybar/scripts/snapshot-backup.sh --label "before-gpu-refactor"
```

## What a snapshot contains

- `config.conf`
- `backups/legacy/config.conf.jpfont.backup` (if present)
- `launch.sh`
- `scripts/`
- `documentation/`
- generated: `documentation/STACK_AS_OF_LAST_COMMIT.md`
- generated: `MANIFEST.txt` (file list + checksums)

## Snapshot location

Default root:

- `/mnt/storage/backups/polybar/snapshots/` (HDD target)

Automatic fallback if HDD path is not writable:

- `~/.config/polybar/backups/snapshots/`

One-time fix (if `/mnt/storage` is root-owned and not writable by your user):

```bash
sudo mkdir -p /mnt/storage/backups/polybar/snapshots
sudo chown -R "$USER:$USER" /mnt/storage/backups/polybar
```

Convenience pointers:

- `latest` symlink -> newest snapshot
- `LATEST_PATH.txt` -> absolute path of newest snapshot

## Commit-oriented handoff phrase

You can say this to future Codex sessions:

"Update my Polybar backup by creating a new snapshot and refresh the stack note as of last commit."

That maps directly to running `snapshot-backup.sh`.

## Home shortcut tools

Local helper folder:

- `~/codex-tools/`
- `~/codex-tools/update-polybar-backup.sh`
- `~/codex-tools/README-polybar-backup.md`

## Notes

- If your repository has no commits yet, stack note records `no-commits-yet`.
- Snapshot is local and non-destructive.
