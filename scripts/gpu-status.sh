#!/usr/bin/env bash

set -u

anim_label() {
  ~/.config/polybar/scripts/dynamic-rainbow.sh --block "$1" 2>/dev/null || printf '%s' "$1"
}

build_bar() {
  local util="$1"
  local active="$2"
  local filled i bar chars total ch
  chars="ICONIC!"
  total=${#chars}
  filled=$((util * total / 100))
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

bar_color_for_util() {
  local util="$1"
  if (( util < 40 )); then
    printf '#9ece6a'
  elif (( util < 70 )); then
    printf '#e0af68'
  else
    printf '#f7768e'
  fi
}

render_segment() {
  local label="$1"
  local util="$2"
  local temp="$3"
  local bar color pct t

  if [[ "$util" =~ ^[0-9]+$ ]]; then
    (( util < 0 )) && util=0
    (( util > 100 )) && util=100
    color="$(bar_color_for_util "$util")"
    bar="$(build_bar "$util" "$color")"
    printf -v pct "%03d%%" "$util"
  else
    bar="%{F#555555}ICONIC!%{F-}"
    pct="N/A"
  fi

  if [[ "$temp" =~ ^[0-9]+$ ]]; then
    t="${temp}C"
  else
    t="N/A"
  fi

  if [[ "$pct" == "N/A" ]]; then
    printf '%s [%s] N/A\n' "$label" "$bar"
  else
    printf '%s [%s] %s %s\n' "$label" "$bar" "$pct" "$t"
  fi
}

# NVIDIA (first GPU only)
nv_util=""
nv_temp=""
nv_query="$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1)"
if [[ "$nv_query" =~ ^[[:space:]]*[0-9]+[[:space:]]*,[[:space:]]*[0-9]+[[:space:]]*$ ]]; then
  nv_util="$(printf '%s' "$nv_query" | cut -d',' -f1 | tr -d '[:space:]')"
  nv_temp="$(printf '%s' "$nv_query" | cut -d',' -f2 | tr -d '[:space:]')"
fi

# AMD (first AMD VGA device exposing gpu_busy_percent)
amd_util=""
amd_temp=""
amd_dev=""
for d in /sys/bus/pci/devices/*; do
  [[ -f "$d/vendor" && -f "$d/class" ]] || continue
  [[ "$(cat "$d/vendor" 2>/dev/null)" == "0x1002" ]] || continue
  c="$(cat "$d/class" 2>/dev/null)"
  [[ "$c" == 0x03* ]] || continue
  if [[ -f "$d/gpu_busy_percent" ]]; then
    amd_dev="$d"
    break
  fi
done

if [[ -n "$amd_dev" ]]; then
  amd_util="$(cat "$amd_dev/gpu_busy_percent" 2>/dev/null | tr -d '[:space:]')"
  for tf in "$amd_dev"/hwmon/*/temp1_input; do
    if [[ -f "$tf" ]]; then
      raw="$(cat "$tf" 2>/dev/null | tr -d '[:space:]')"
      if [[ "$raw" =~ ^[0-9]+$ ]]; then
        amd_temp=$((raw / 1000))
      fi
      break
    fi
  done
fi

case "${1:-}" in
  --nv)
    render_segment "$(anim_label 'NV')" "${nv_util:-}" "${nv_temp:-}"
    ;;
  --amd)
    render_segment "$(anim_label 'AMD')" "${amd_util:-}" "${amd_temp:-}"
    ;;
  *)
    nv_seg="$(render_segment "$(anim_label 'NV')" "${nv_util:-}" "${nv_temp:-}")"
    amd_seg="$(render_segment "$(anim_label 'AMD')" "${amd_util:-}" "${amd_temp:-}")"
    printf '%s  %s\n' "$nv_seg" "$amd_seg"
    ;;
esac
