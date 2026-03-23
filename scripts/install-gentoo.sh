#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/polybar"
BACKUP=1
FORCE=0

usage() {
  cat <<'USAGE'
Usage:
  install-gentoo.sh [--target DIR] [--no-backup] [--force] [--help]

What it does:
- Copies this repo into ~/.config/polybar (or custom target)
- Backs up existing target by default
- Sets executable bits on scripts and launch.sh
- Prints dependency and i3 autostart reminders

Examples:
  ~/.config/polybar/scripts/install-gentoo.sh
  ~/.config/polybar/scripts/install-gentoo.sh --target ~/.config/polybar
  ~/.config/polybar/scripts/install-gentoo.sh --force
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      [[ $# -ge 2 ]] || { echo "Missing value for --target" >&2; exit 2; }
      TARGET_DIR="$2"
      shift 2
      ;;
    --no-backup)
      BACKUP=0
      shift
      ;;
    --force)
      FORCE=1
      shift
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

need_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "Missing required command: $cmd" >&2
    exit 1
  }
}

need_cmd rsync
need_cmd date

if [[ ! -f "$REPO_ROOT/config.conf" || ! -d "$REPO_ROOT/scripts" ]]; then
  echo "Repository layout check failed at: $REPO_ROOT" >&2
  exit 1
fi

if [[ -d "$TARGET_DIR" && "$BACKUP" == "1" ]]; then
  stamp="$(date +%Y-%m-%d_%H-%M-%S)"
  backup_dir="${TARGET_DIR}.backup.${stamp}"
  if [[ "$FORCE" == "1" || -n "$(find "$TARGET_DIR" -mindepth 1 -maxdepth 1 2>/dev/null)" ]]; then
    cp -a "$TARGET_DIR" "$backup_dir"
    echo "Backup created: $backup_dir"
  fi
fi

mkdir -p "$TARGET_DIR"

rsync -a --delete \
  --exclude '.git' \
  --exclude 'backups' \
  --exclude '.gitignore' \
  "$REPO_ROOT/" "$TARGET_DIR/"

chmod +x "$TARGET_DIR/launch.sh" "$TARGET_DIR/scripts"/*.sh

echo
echo "Installed to: $TARGET_DIR"
echo
echo "Suggested dependency check commands:"
echo "  polybar xrandr i3-msg kitty playerctl wpctl pactl iw iwctl nvidia-smi fastfetch"
echo
echo "i3 autostart line (if missing):"
echo "  exec_always --no-startup-id ~/.config/polybar/launch.sh"
echo
echo "Done. Reload i3 or run: ~/.config/polybar/launch.sh"
