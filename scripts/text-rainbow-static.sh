#!/usr/bin/env bash

set -euo pipefail

text="${*:-}"
if [[ -z "$text" ]]; then
  exit 0
fi

# Gentle rainbow palette that works on transparent bars.
colors=(
  "#ff4d4d" "#ff7a45" "#ff9f40" "#ffc53d" "#ffe66d"
  "#b7eb8f" "#73d13d" "#36cfc9" "#40a9ff" "#597ef7"
  "#9254de" "#d3adf7" "#ff85c0" "#ff4d4f"
)

out=""
idx=0
n=${#colors[@]}
len=${#text}

for ((i=0; i<len; i++)); do
  ch="${text:i:1}"
  if [[ "$ch" == " " ]]; then
    out+=" "
    continue
  fi
  out+="%{F${colors[idx]}}${ch}"
  idx=$(((idx + 1) % n))
done

out+="%{F-}"
printf '%s\n' "$out"
