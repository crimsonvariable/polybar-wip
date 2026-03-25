#!/usr/bin/env bash

set -euo pipefail

PROGRESS_SCRIPT="$HOME/.config/polybar/scripts/build-progress.sh"

if [[ $# -eq 0 ]]; then
  echo "usage: task-run-with-progress.sh <build command...>" >&2
  echo "example: task-run-with-progress.sh ninja -C build" >&2
  exit 2
fi

"$PROGRESS_SCRIPT" --reset >/dev/null 2>&1 || true

set +e
"$@" 2>&1 | "$PROGRESS_SCRIPT" --ingest
status=${PIPESTATUS[0]}
set -e

exit "$status"
