#!/usr/bin/env bash

set -euo pipefail

anim_label() {
  ~/.config/polybar/scripts/theme-engine.sh --block "$1" 2>/dev/null || printf '%s' "$1"
}

read_mem() {
  awk '
    /^MemTotal:/ {t=$2}
    /^MemAvailable:/ {a=$2}
    END {
      if (t > 0) {
        used=t-a
        pct=(used*100)/t
        printf "%d\n", pct
      } else {
        print 0
      }
    }
  ' /proc/meminfo
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

pct="$(read_mem)"
color="$(bar_color "$pct")"
bar="$(build_bar "$pct" "$color")"
label="$(anim_label 'RAM')"

printf '%s [%s] %03d%%\n' "$label" "$bar" "$pct"
