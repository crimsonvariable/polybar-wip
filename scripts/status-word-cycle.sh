#!/usr/bin/env bash

set -euo pipefail

CPU_STATE_FILE="/tmp/polybar-status-word-prev.state"
THEME_STATE_FILE="/tmp/polybar-theme.state"
CYCLE_FILE="/tmp/polybar-candy-cycle.count"

words=(
  "WIRED"
  "SERIAL"
  "PROTOCOL"
  "NODE"
  "NAVI"
  "PSYCHE"
  "RESONANCE"
  "SYNAPSE"
  "LAYER09"
  "GHOSTSIG"
  "LOGIC"
  "LINKSTATE"
  "SIGNAL"
  "STACKTRACE"
  "MEMGHOST"
  "玲音"
  "有線"
  "接続"
  "通信"
  "記録"
  "信号"
  "現実"
  "存在"
  "世界"
  "開け"
  "GENTOO"
  "PORTAGE"
  "EMERGE"
  "@WORLD"
  "DEPCLEAN"
  "REBUILD"
  "USEFLAG"
  "ESELECT"
  "KERNEL"
  "DISTCC"
  "BINHOST"
  "KEYWORD"
  "LARRY"
  "MOO"
  "SYNCING"
  "UNMASK"
  "PATCHSET"
  "ROLLING"
  "RECOMPILE"
  "WORLDSET"
  "TUX"
  "PENGUIN"
  "MAXIM<3"
  "Thierry<3"
)
DISPLAY_LEN=10
ALLOW_WIDE="${STATUS_WORD_ALLOW_WIDE:-${LOAD_WORD_ALLOW_WIDE:-0}}"

read_cpu_totals() {
  awk '/^cpu /{idle=$5+$6; total=0; for(i=2;i<=11;i++) total+=$i; print total, idle; exit}' /proc/stat
}

read -r cur_total cur_idle < <(read_cpu_totals)
if [[ -r "$CPU_STATE_FILE" ]]; then
  read -r prev_total prev_idle < "$CPU_STATE_FILE"
else
  prev_total="$cur_total"
  prev_idle="$cur_idle"
fi
printf '%s %s\n' "$cur_total" "$cur_idle" > "$CPU_STATE_FILE"

delta_total=$((cur_total - prev_total))
delta_idle=$((cur_idle - prev_idle))
if (( delta_total <= 0 )); then
  usage=0
else
  usage=$(((100 * (delta_total - delta_idle)) / delta_total))
fi
(( usage < 0 )) && usage=0
(( usage > 100 )) && usage=100

# Accent color tracks load.
if (( usage < 40 )); then
  hi="#9ece6a"
elif (( usage < 70 )); then
  hi="#e0af68"
else
  hi="#f7768e"
fi

base="#666666"
if [[ -r "$THEME_STATE_FILE" ]]; then
  read -r theme < "$THEME_STATE_FILE" || true
  if [[ "${theme:-}" == "mono" ]]; then
    base="#8c8c8c"
  fi
fi

pick_words=()
if [[ "$ALLOW_WIDE" == "1" ]]; then
  pick_words=("${words[@]}")
else
  # Keep center alignment stable by default: avoid wide glyph words.
  for w in "${words[@]}"; do
    if printf '%s' "$w" | LC_ALL=C grep -qE '^[ -~]+$'; then
      pick_words+=("$w")
    fi
  done
fi

if (( ${#pick_words[@]} == 0 )); then
  pick_words=("WIRED" "GENTOO" "EMERGE" "PENGUIN")
fi

cycle=0
if [[ -r "$CYCLE_FILE" ]]; then
  c="$(cat "$CYCLE_FILE" 2>/dev/null | tr -d '[:space:]')"
  if [[ "${c:-}" =~ ^[0-9]+$ ]]; then
    cycle="$c"
  fi
fi

widx=$(( cycle % ${#pick_words[@]} ))
word="${pick_words[widx]}"
len=${#word}

# Freeze module width so neighboring modules do not shift.
if (( len > DISPLAY_LEN )); then
  word="${word:0:DISPLAY_LEN}"
  len=${#word}
elif (( len < DISPLAY_LEN )); then
  printf -v word "%-${DISPLAY_LEN}s" "$word"
  len=${#word}
fi

out=""
for ((i=0; i<len; i++)); do
  ch="${word:i:1}"
  if [[ "$ch" != " " ]]; then
    out+="%{F${hi}}${ch}"
  else
    out+="%{F${base}}${ch}"
  fi
done
out+="%{F-}"

printf '%s\n' "$out"
