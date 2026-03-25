#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="${DOTFILES_REPO:-$HOME/dotfiles-private}"
PROFILE="gentoo"
QUICK=0

usage() {
  cat <<'USAGE'
Usage:
  repo-sync.sh [--quick] [profile]

Examples:
  ~/.config/polybar/scripts/repo-sync.sh
  ~/.config/polybar/scripts/repo-sync.sh gentoo
  ~/.config/polybar/scripts/repo-sync.sh --quick gentoo
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --quick)
      QUICK=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      PROFILE="$1"
      shift
      ;;
  esac
done

SYNC_SCRIPT="$REPO_DIR/scripts/sync-from-system.sh"

if [[ ! -x "$SYNC_SCRIPT" ]]; then
  echo "Missing sync script: $SYNC_SCRIPT"
  echo "Expected repo: $REPO_DIR"
  exit 1
fi

printf 'Dotfiles sync\n'
printf 'Repo   : %s\n' "$REPO_DIR"
printf 'Profile: %s\n\n' "$PROFILE"

"$SYNC_SCRIPT" "$PROFILE"

cd "$REPO_DIR"
changes="$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')"

printf '\nCurrent status:\n'
git status --short

if [[ "$QUICK" == "1" ]]; then
  printf '\nQuick mode complete.\n'
  exit 0
fi

if [[ "$changes" == "0" ]]; then
  printf '\nNo changes to commit. Press Enter to close...'
  read -r _
  exit 0
fi

printf '\nThere are %s change(s).\n' "$changes"
read -r -p 'Commit and push now? [y/N]: ' reply
if [[ ! "$reply" =~ ^[Yy]$ ]]; then
  printf 'Skipped commit/push. Press Enter to close...'
  read -r _
  exit 0
fi

default_msg="chore(dotfiles): sync ${PROFILE} profile $(date +%F)"
read -r -p "Commit message [${default_msg}]: " msg
msg="${msg:-$default_msg}"

git add .
if git diff --cached --quiet; then
  printf '\nNothing staged after add. Press Enter to close...'
  read -r _
  exit 0
fi

git commit -m "$msg"
git push

printf '\nDone. Press Enter to close...'
read -r _
