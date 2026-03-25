#!/usr/bin/env bash

set -euo pipefail

STATE_FILE="/tmp/polybar-candy-loop.state"
CYCLE_FILE="/tmp/polybar-candy-cycle.count"
START_FILE="/tmp/polybar-candy-loop.start"

trail_text="It never happened if there is no memory of it "
trail_len=${#trail_text}

# Dynamic lane length: fit text naturally, with a sane min/max range.
CELLS="$trail_len"
(( CELLS < 22 )) && CELLS=22
(( CELLS > 56 )) && CELLS=56

step_ms=220
hold_ms=2400
hold_ticks=$((hold_ms / step_ms))
now_ms="$(date +%s%3N 2>/dev/null || echo $(( $(date +%s) * 1000 )))"
tick=$((now_ms / step_ms))
start_delay_ms=1000

# Initial delay before animation starts (resets after inactivity/reload).
start_ms="$now_ms"
last_ms="$now_ms"
if [[ -r "$START_FILE" ]]; then
  IFS='|' read -r s l < "$START_FILE" || true
  if [[ "${s:-}" =~ ^[0-9]+$ ]]; then start_ms="$s"; fi
  if [[ "${l:-}" =~ ^[0-9]+$ ]]; then last_ms="$l"; fi
fi

# If script wasn't polled for a while, treat this as a fresh start.
if (( now_ms - last_ms > 2000 )); then
  start_ms="$now_ms"
fi
printf '%s|%s\n' "$start_ms" "$now_ms" > "$START_FILE"

if (( now_ms - start_ms < start_delay_ms )); then
  pos=0
  pac="C"
  pct=0
  lane=""
  for ((i=0; i<CELLS; i++)); do
    if (( i == 0 )); then
      ch="$pac"
    else
      if (( i % 2 == 0 )); then ch="o"; else ch="."; fi
    fi
    if [[ "$ch" == "o" ]]; then
      lane="${lane}%{F#ffffff}${ch}%{F-}"
    else
      lane="${lane}%{F#f1c40f}${ch}%{F-}"
    fi
  done
  printf '[%s] %03d%%\n' "$lane" "$pct"
  exit 0
fi

cycle=$((CELLS + hold_ticks))
phase=$((tick % cycle))

prev_phase=0
if [[ -r "$STATE_FILE" ]]; then
  p="$(cat "$STATE_FILE" 2>/dev/null | tr -d '[:space:]')"
  if [[ "${p:-}" =~ ^[0-9]+$ ]]; then
    prev_phase="$p"
  fi
fi

# Signal cycle completion (wraparound) for status-word-cycle switching.
if (( phase < prev_phase )); then
  count=0
  if [[ -r "$CYCLE_FILE" ]]; then
    c="$(cat "$CYCLE_FILE" 2>/dev/null | tr -d '[:space:]')"
    if [[ "${c:-}" =~ ^[0-9]+$ ]]; then
      count="$c"
    fi
  fi
  count=$((count + 1))
  printf '%s\n' "$count" > "$CYCLE_FILE"
fi
printf '%s\n' "$phase" > "$STATE_FILE"

if (( phase >= CELLS )); then
  pos=$((CELLS - 1))
else
  pos="$phase"
fi

if (( (tick / 2) % 2 == 0 )); then
  pac="C"
else
  pac="c"
fi

lane=""
for ((i=0; i<CELLS; i++)); do
  if (( i < pos )); then
    if (( trail_len > 0 )); then
      # Static anchored reveal: letters don't move, only get uncovered.
      tidx=$((i % trail_len))
      ch="${trail_text:tidx:1}"
    else
      ch="."
    fi
  elif (( i == pos )); then
    ch="$pac"
  else
    # Keep front candies anchored to absolute lane positions (static look).
    if (( i % 2 == 0 )); then
      ch="o"
    else
      ch="."
    fi
  fi
  if [[ "$ch" == "o" ]]; then
    lane="${lane}%{F#ffffff}${ch}%{F-}"
  elif (( i < pos )); then
    lane="${lane}%{F#7ecbff}${ch}%{F-}"
  else
    lane="${lane}%{F#f1c40f}${ch}%{F-}"
  fi
done
pct=$(((pos * 100) / (CELLS - 1)))

printf '[%s] %03d%%\n' "$lane" "$pct"
