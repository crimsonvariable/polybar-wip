#!/usr/bin/env bash

set -euo pipefail

TOOL_HUB="${HOME}/.config/rofi/scripts/tool-hub.sh"

if [[ -x "$TOOL_HUB" ]]; then
  exec "$TOOL_HUB"
fi

if command -v rofi >/dev/null 2>&1; then
  rofi -e "Missing or not executable: $TOOL_HUB"
else
  printf 'Missing or not executable: %s\n' "$TOOL_HUB" >&2
fi
