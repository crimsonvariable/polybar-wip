#!/usr/bin/env bash

set -u

fmt_pct() {
  local n="$1"
  printf "%03d%%" "$n"
}

if command -v wpctl >/dev/null 2>&1; then
  line="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"
  if [[ "$line" =~ [Mm][Uu][Tt][Ee][Dd] ]]; then
    echo "muted"
    exit 0
  fi
  vol="$(printf '%s' "$line" | grep -Eo '[0-9]+(\.[0-9]+)?' | head -n1 || true)"
  if [[ -n "$vol" ]]; then
    awk -v v="$vol" 'BEGIN { printf "%03d%%\n", (v*100)+0.5 }'
    exit 0
  fi
fi

if command -v pactl >/dev/null 2>&1; then
  mute="$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}' || true)"
  if [[ "$mute" == "yes" ]]; then
    echo "muted"
    exit 0
  fi
  vol="$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -Eo '[0-9]+%' | head -n1 || true)"
  if [[ -n "$vol" ]]; then
    num="${vol%%%}"
    if [[ "$num" =~ ^[0-9]+$ ]]; then
      fmt_pct "$num"
    else
      echo "$vol"
    fi
    exit 0
  fi
fi

echo "N/A"
