#!/usr/bin/env bash

set -euo pipefail

reverse=0
if [[ "${1:-}" == "--reverse" ]]; then
  reverse=1
fi

STEP_MS="${SPACER_SPINNER_STEP_MS:-${PORTAGE_SPINNER_STEP_MS:-120}}"
if ! [[ "$STEP_MS" =~ ^[0-9]+$ ]] || (( STEP_MS < 40 )); then
  STEP_MS=120
fi

# Portage-style spinner frames.
FRAMES=( '/' '-' '\' '|' )
COUNT="${#FRAMES[@]}"

now_ms="$(date +%s%3N 2>/dev/null || echo $(( $(date +%s) * 1000 )))"
idx=$(( (now_ms / STEP_MS) % COUNT ))
if (( reverse )); then
  idx=$((COUNT - 1 - idx))
fi

frame="${FRAMES[$idx]}"
pipe_name="${SPACER_SPINNER_PIPE:-${PORTAGE_SPINNER_PIPE:-spacer}}"

if [[ -x "${HOME}/.config/polybar/scripts/theme-engine.sh" ]]; then
  "${HOME}/.config/polybar/scripts/theme-engine.sh" --pipe "$pipe_name" --block "$frame"
else
  printf '%s\n' "$frame"
fi
