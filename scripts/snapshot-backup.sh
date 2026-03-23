#!/usr/bin/env bash

set -euo pipefail

SRC_DIR="${HOME}/.config/polybar"
REPO_DIR="${HOME}/.config"
DEFAULT_HDD_DEST="/mnt/storage/backups/polybar/snapshots"
LOCAL_FALLBACK_DEST="${HOME}/.config/polybar/backups/snapshots"
DEST_ROOT="$DEFAULT_HDD_DEST"
LABEL=""
DEST_SET_BY_USER=0

usage() {
  cat <<'USAGE'
Usage:
  snapshot-backup.sh [--dest DIR] [--label TEXT] [--help]

Creates a timestamped Polybar snapshot containing:
- config + scripts + documentation
- stack note: STACK_AS_OF_LAST_COMMIT.md
- file manifest

Examples:
  ~/.config/polybar/scripts/snapshot-backup.sh
  ~/.config/polybar/scripts/snapshot-backup.sh --label "pre-theme-refactor"
  ~/.config/polybar/scripts/snapshot-backup.sh --dest /mnt/storage/backups/polybar/snapshots
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dest)
      [[ $# -ge 2 ]] || { echo "Missing value for --dest" >&2; exit 2; }
      DEST_ROOT="$2"
      DEST_SET_BY_USER=1
      shift 2
      ;;
    --label)
      [[ $# -ge 2 ]] || { echo "Missing value for --label" >&2; exit 2; }
      LABEL="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if ! mkdir -p "$DEST_ROOT" 2>/dev/null || [[ ! -w "$DEST_ROOT" ]]; then
  if [[ "$DEST_SET_BY_USER" -eq 1 ]]; then
    echo "Cannot create destination: $DEST_ROOT" >&2
    exit 1
  fi
  echo "Warning: default HDD destination unavailable: $DEST_ROOT" >&2
  echo "Falling back to local destination: $LOCAL_FALLBACK_DEST" >&2
  DEST_ROOT="$LOCAL_FALLBACK_DEST"
fi

stamp="$(date +%Y-%m-%d_%H-%M-%S)"
if [[ -n "$LABEL" ]]; then
  clean_label="$(printf '%s' "$LABEL" | tr ' /' '__' | tr -cd '[:alnum:]_.-')"
  [[ -z "$clean_label" ]] && clean_label="label"
  snapshot_dir="${DEST_ROOT}/${stamp}_${clean_label}"
else
  snapshot_dir="${DEST_ROOT}/${stamp}"
fi

mkdir -p "$snapshot_dir"

copy_if_exists() {
  local rel="$1"
  if [[ -e "${SRC_DIR}/${rel}" ]]; then
    cp -a "${SRC_DIR}/${rel}" "$snapshot_dir/"
  fi
}

copy_if_exists "config.conf"
copy_if_exists "config.conf.bak-jpfont"
copy_if_exists "launch.sh"
copy_if_exists "scripts"
copy_if_exists "documentation"

if [[ ! -e "$snapshot_dir/documentation" ]]; then
  mkdir -p "$snapshot_dir/documentation"
fi

stack_note="$snapshot_dir/documentation/STACK_AS_OF_LAST_COMMIT.md"
manifest="$snapshot_dir/MANIFEST.txt"

os_pretty="$(awk -F= '/^PRETTY_NAME=/{gsub(/\047/,"",$2); print $2}' /etc/os-release 2>/dev/null || true)"
kernel="$(uname -srmo 2>/dev/null || true)"
user_shell="$(getent passwd "${USER}" 2>/dev/null | awk -F: '{print $7}' || true)"
profile="$(eselect profile show 2>/dev/null | sed -n 's/^  //p' | tr '\n' '; ' | sed 's/;[[:space:]]*$//' || true)"

hdd_line="$(lsblk -dn -o NAME,SIZE,ROTA,MODEL 2>/dev/null | awk '$3==1 {printf "/dev/%s (%s) model=%s\n", $1, $2, $4}' | paste -sd '; ' - || true)"
[[ -z "$hdd_line" ]] && hdd_line="not-detected"

git_branch="unknown"
git_commit="none"
git_commit_subject="none"
git_commit_date="none"
git_status_short="unknown"

if git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git_branch="$(git -C "$REPO_DIR" symbolic-ref --short -q HEAD 2>/dev/null || echo detached-or-unborn)"

  if git -C "$REPO_DIR" rev-parse --verify HEAD >/dev/null 2>&1; then
    git_commit="$(git -C "$REPO_DIR" rev-parse --short HEAD 2>/dev/null || echo unknown)"
    git_commit_subject="$(git -C "$REPO_DIR" log -1 --pretty=%s 2>/dev/null || echo unknown)"
    git_commit_date="$(git -C "$REPO_DIR" log -1 --pretty=%ci 2>/dev/null || echo unknown)"
  else
    git_commit="no-commits-yet"
    git_commit_subject="repository initialized but no commit exists yet"
    git_commit_date="n/a"
  fi

  git_status_short="$(git -C "$REPO_DIR" status --short 2>/dev/null | wc -l | tr -d ' ') changes"
fi

cat > "$stack_note" <<STACK
# Stack Snapshot (As Of Last Commit)

Generated: $(date -Iseconds)
Snapshot path: $snapshot_dir

## Git context

- Repo: $REPO_DIR
- Branch: $git_branch
- Last commit: $git_commit
- Commit date: $git_commit_date
- Commit subject: $git_commit_subject
- Working tree status: $git_status_short

## Environment stack

- Distro: ${os_pretty:-unknown}
- Gentoo profile: ${profile:-unknown}
- Kernel: ${kernel:-unknown}
- User shell: ${user_shell:-unknown}
- Session stack: X11 via \`~/.xinitrc\`, WM \`i3\` (default), Polybar launched from \`~/.config/i3/config\`
- Audio stack: PipeWire + WirePlumber (+ pipewire-pulse compatibility)
- Media control: playerctl
- Network control path: iw/iwctl (nmcli optional)
- Storage note (rotational disks): ${hdd_line}

## Polybar scope in this snapshot

- \`config.conf\`
- \`launch.sh\`
- \`scripts/\`
- \`documentation/\`

## Notes

This file is intended for commit-oriented handoff prompts, e.g.:

"Use the stack snapshot from documentation/STACK_AS_OF_LAST_COMMIT.md and update backup with a new snapshot."
STACK

{
  echo "Snapshot created: $snapshot_dir"
  echo "Generated: $(date -Iseconds)"
  echo "Source: $SRC_DIR"
  echo
  echo "Included top-level paths:"
  (cd "$snapshot_dir" && ls -1)
  echo
  echo "SHA256 checksums:"
  (cd "$snapshot_dir" && find . -type f | sort | while IFS= read -r f; do sha256sum "$f"; done)
} > "$manifest"

ln -sfn "$snapshot_dir" "${DEST_ROOT}/latest"
printf '%s\n' "$snapshot_dir" > "${DEST_ROOT}/LATEST_PATH.txt"

printf 'Snapshot ready: %s\n' "$snapshot_dir"
printf 'Latest symlink: %s/latest\n' "$DEST_ROOT"
printf 'Stack note: %s\n' "$stack_note"
printf 'Manifest: %s\n' "$manifest"
