#!/usr/bin/env bash

set -euo pipefail

STATE_FILE="/tmp/polybar-theme.state"
FLOW_FILE="/tmp/polybar-flow.state"
render_mode="gradient"
if [[ "${1:-}" == "--block" ]]; then
  render_mode="block"
  shift
fi
text="${*:-}"
[[ -z "$text" ]] && exit 0

theme="neon"
if [[ -r "$STATE_FILE" ]]; then
  read -r t < "$STATE_FILE" || true
  [[ -n "${t:-}" ]] && theme="$t"
fi

mode="flow"
speed=220
if [[ -r "$FLOW_FILE" ]]; then
  read -r m s < "$FLOW_FILE" || true
  [[ -n "${m:-}" ]] && mode="$m"
  if [[ "${s:-}" =~ ^[0-9]+$ ]]; then
    speed="$s"
  fi
fi

colors=()
case "$theme" in
  neon)
    colors=("#ff4d4d" "#ff7a45" "#ff9f40" "#ffc53d" "#ffe66d" "#73d13d" "#36cfc9" "#40a9ff" "#597ef7" "#9254de" "#d3adf7" "#ff85c0")
    ;;
  synth)
    colors=("#f72585" "#b5179e" "#7209b7" "#560bad" "#480ca8" "#3a0ca3" "#3f37c9" "#4361ee" "#4895ef" "#4cc9f0")
    ;;
  wired)
    colors=("#9ef01a" "#70e000" "#38b000" "#008000" "#007200" "#006400" "#00b4d8" "#48cae4")
    ;;
  mono)
    colors=("#f5f5f5" "#d9d9d9" "#bfbfbf" "#a6a6a6" "#8c8c8c")
    ;;
  sunset)
    colors=("#ff4d6d" "#ff7b54" "#ffb347" "#ffd166" "#f9f871" "#fcbf49" "#f77f00")
    ;;
  aurora)
    colors=("#00f5d4" "#00bbf9" "#00a6fb" "#8338ec" "#c77dff" "#80ffdb")
    ;;
  ember)
    colors=("#ff3c38" "#ff6d00" "#ff8500" "#ff9e00" "#ffba08" "#faa307")
    ;;
  ocean)
    colors=("#03045e" "#023e8a" "#0077b6" "#0096c7" "#00b4d8" "#48cae4" "#90e0ef")
    ;;
  acid)
    colors=("#d9ed92" "#b5e48c" "#99d98c" "#76c893" "#52b69a" "#34a0a4" "#168aad")
    ;;
  blood)
    colors=("#2b0a0a" "#5c0b0b" "#8a0303" "#ba181b" "#d00000" "#e5383b" "#ff6b6b")
    ;;
  *)
    colors=("#ff4d4d" "#ff9f40" "#ffe66d" "#73d13d" "#36cfc9" "#597ef7" "#d3adf7")
    ;;
esac

n=${#colors[@]}
(( n > 0 )) || exit 0

hex_to_dec() {
  local h="$1"
  printf '%d' "$((16#${h}))"
}

interp_color() {
  local c1="$1" c2="$2" frac="$3"
  local r1 g1 b1 r2 g2 b2 r g b

  r1=$(hex_to_dec "${c1:1:2}")
  g1=$(hex_to_dec "${c1:3:2}")
  b1=$(hex_to_dec "${c1:5:2}")
  r2=$(hex_to_dec "${c2:1:2}")
  g2=$(hex_to_dec "${c2:3:2}")
  b2=$(hex_to_dec "${c2:5:2}")

  r=$(((r1 * (1000 - frac) + r2 * frac) / 1000))
  g=$(((g1 * (1000 - frac) + g2 * frac) / 1000))
  b=$(((b1 * (1000 - frac) + b2 * frac) / 1000))

  printf '#%02x%02x%02x' "$r" "$g" "$b"
}

len=${#text}
(( len > 0 )) || exit 0

# One continuous gradient across the entire module text, then shift it over time.
# total is segmented into n color intervals; phase makes it "flow".
total=$((n * 1000))
ticks=$(date +%s)
raw=$((ticks * speed))
case "$mode" in
  flow)
    phase=$((raw % total))
    ;;
  reverse)
    phase=$(((total - (raw % total)) % total))
    ;;
  pulse)
    tw=$((2 * total))
    p=$((raw % tw))
    if (( p > total )); then
      phase=$((tw - p))
    else
      phase=$p
    fi
    ;;
  static)
    phase=0
    ;;
  *)
    phase=$((raw % total))
    ;;
esac

out=""
for ((i=0; i<len; i++)); do
  ch="${text:i:1}"

  if (( len == 1 )); then
    pos=$phase
  else
    pos=$(((i * total) / len + phase))
    pos=$((pos % total))
  fi

  idx=$((pos / 1000))
  frac=$((pos % 1000))
  next=$(((idx + 1) % n))

  col="$(interp_color "${colors[idx]}" "${colors[next]}" "$frac")"
  out+="%{F${col}}${ch}"
done

if [[ "$render_mode" == "block" ]]; then
  mid_pos=$(((len * total) / (2 * len) + phase))
  mid_pos=$((mid_pos % total))
  mid_idx=$((mid_pos / 1000))
  mid_frac=$((mid_pos % 1000))
  mid_next=$(((mid_idx + 1) % n))
  col="$(interp_color "${colors[mid_idx]}" "${colors[mid_next]}" "$mid_frac")"
  printf '%%{F%s}%s%%{F-}\n' "$col" "$text"
  exit 0
fi

out+="%{F-}"
printf '%s\n' "$out"
