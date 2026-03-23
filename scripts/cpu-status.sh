#!/usr/bin/env bash

set -euo pipefail

STATE_FILE="/tmp/polybar-cpu-prev.state"
TEMP_PATH="/sys/class/hwmon/hwmon1/temp1_input"

anim_label() {
  ~/.config/polybar/scripts/dynamic-rainbow.sh --block "$1" 2>/dev/null || printf '%s' "$1"
}

read_cpu_totals() {
  awk '/^cpu /{idle=$5+$6; total=0; for(i=2;i<=11;i++) total+=$i; print total, idle; exit}' /proc/stat
}

read_temp_c() {
  local raw
  if [[ -r "$TEMP_PATH" ]]; then
    raw="$(cat "$TEMP_PATH" 2>/dev/null | tr -d '[:space:]')"
    if [[ "$raw" =~ ^[0-9]+$ ]]; then
      printf '%d' $((raw / 1000))
      return
    fi
  fi
  printf '--'
}

build_bar() {
  local pct="$1"
  local active="$2"
  local filled i bar chars total ch
  chars="ICONIC!"
  total=${#chars}
  filled=$((pct * total / 100))
  (( filled > total )) && filled=total

  bar=""
  for ((i=0; i<total; i++)); do
    ch="${chars:i:1}"
    if (( i < filled )); then
      bar+="%{F${active}}${ch}%{F-}"
    else
      bar+="%{F#555555}${ch}%{F-}"
    fi
  done
  printf '%s' "$bar"
}

bar_color() {
  local pct="$1"
  if (( pct < 40 )); then
    printf '#9ece6a'
  elif (( pct < 70 )); then
    printf '#e0af68'
  else
    printf '#f7768e'
  fi
}

read -r cur_total cur_idle < <(read_cpu_totals)

if [[ -r "$STATE_FILE" ]]; then
  read -r prev_total prev_idle < "$STATE_FILE"
else
  prev_total="$cur_total"
  prev_idle="$cur_idle"
fi

printf '%s %s\n' "$cur_total" "$cur_idle" > "$STATE_FILE"

delta_total=$((cur_total - prev_total))
delta_idle=$((cur_idle - prev_idle))

if (( delta_total <= 0 )); then
  usage=0
else
  usage=$(((100 * (delta_total - delta_idle)) / delta_total))
fi

(( usage < 0 )) && usage=0
(( usage > 100 )) && usage=100

temp_c="$(read_temp_c)"
color="$(bar_color "$usage")"
bar="$(build_bar "$usage" "$color")"
label="$(anim_label 'CPU')"

if [[ "$temp_c" == "--" ]]; then
  printf '%s [%s] %03d%% --\n' "$label" "$bar" "$usage"
else
  printf '%s [%s] %03d%% %sC\n' "$label" "$bar" "$usage" "$temp_c"
fi
