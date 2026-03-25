#!/usr/bin/env bash

set -euo pipefail

UNTIL_FILE="/tmp/polybar-startup.until"
POS_FILE="/tmp/polybar-startup.pos"
PROGRESS_SECS="${STARTUP_SECS:-10}"
HOLD_SECS="${STARTUP_HOLD_SECS:-5}"
CELLS=34

read_until_ts() {
  [[ -r "$UNTIL_FILE" ]] || return 1
  local ts
  ts="$(cat "$UNTIL_FILE" 2>/dev/null | tr -d '[:space:]')"
  [[ "$ts" =~ ^[0-9]+$ ]] || return 1
  printf '%s' "$ts"
}

calc_pct() {
  local until_ts now remain elapsed base_pct pct
  until_ts="$(read_until_ts)" || { printf '100'; return 0; }
  now="$(date +%s)"

  remain=$((until_ts - now))
  elapsed=$((PROGRESS_SECS - remain))
  (( elapsed < 0 )) && elapsed=0
  (( elapsed > PROGRESS_SECS )) && elapsed=PROGRESS_SECS

  base_pct=$((elapsed * 100 / PROGRESS_SECS))
  pct="$base_pct"
  (( pct < 0 )) && pct=0
  (( pct > 100 )) && pct=100
  printf '%s' "$pct"
}

is_alive() {
  local until_ts now
  until_ts="$(read_until_ts)" || return 1
  now="$(date +%s)"
  (( now < until_ts + HOLD_SECS ))
}

if [[ "${1:-}" == "--alive" ]]; then
  if is_alive; then
    exit 0
  fi
  rm -f "$UNTIL_FILE" 2>/dev/null || true
  rm -f "$POS_FILE" 2>/dev/null || true
  exit 1
fi

if [[ "${1:-}" == "--done" ]]; then
  pos_done=0
  if [[ -r "$POS_FILE" ]]; then
    IFS='|' read -r p _ < "$POS_FILE" || true
    if [[ "${p:-}" =~ ^[0-9]+$ ]]; then
      pos_done="$p"
    fi
  fi
  if (( pos_done >= CELLS )); then
    exit 0
  fi
  exit 1
fi

if ! is_alive; then
  rm -f "$UNTIL_FILE" 2>/dev/null || true
  rm -f "$POS_FILE" 2>/dev/null || true
  exit 1
fi

now="$(date +%s)"
now_ms="$(date +%s%3N 2>/dev/null || echo $((now * 1000)))"
tick=$((now_ms / 200))
pct="$(calc_pct)"

target=$((pct * CELLS / 100))
(( target < 0 )) && target=0
(( target > CELLS )) && target=CELLS

pos=0
prev_tick=-1
if [[ -r "$POS_FILE" ]]; then
  IFS='|' read -r p t < "$POS_FILE" || true
  if [[ "${p:-}" =~ ^[0-9]+$ ]]; then pos="$p"; fi
  if [[ "${t:-}" =~ ^[0-9]+$ ]]; then prev_tick="$t"; fi
fi

if (( tick != prev_tick )); then
  hold=0
  if (( ((tick + target) % 7) == 0 || (tick % 17) == 0 )); then
    hold=1
  fi

  if (( hold == 0 )); then
    if (( pos < target )); then
      step=1
      if (( target - pos > 5 && (tick % 9) == 0 )); then
        step=2
      fi
      pos=$((pos + step))
      (( pos > target )) && pos=target
    elif (( pos > target )); then
      pos="$target"
    fi
  fi
fi

(( pos < 0 )) && pos=0
(( pos > CELLS )) && pos=CELLS
printf '%s|%s\n' "$pos" "$tick" > "$POS_FILE"

filled="$pos"
empty=$((CELLS - filled))

case $((tick % 6)) in
  0|3|4) pac="C" ;;
  *) pac="c" ;;
esac

eaten="$(printf '%*s' "$filled" "" | tr ' ' '#')"
candies="$(printf '%*s' "$empty" "" | tr ' ' 'o')"
pct=$((pos * 100 / CELLS))
(( pct < 0 )) && pct=0
(( pct > 100 )) && pct=100

label="$(~/.config/polybar/scripts/theme-engine.sh --block "CrimsonVAR Gentoo" 2>/dev/null || printf 'CrimsonVAR Gentoo')"
printf '%s [%%{F#f1c40f}%s%s%s%%{F-}] %03d%%\n' "$label" "$eaten" "$pac" "$candies" "$pct"
