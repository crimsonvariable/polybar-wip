#!/usr/bin/env bash

set -euo pipefail

QUOTES_FILE="$HOME/.config/polybar/scripts/lain-quotes.tsv"

# Colors:
# English: white, Japanese: magenta, Name/source: soft blue.
C_RESET='\033[0m'
C_EN='\033[97m'
C_JP='\033[95m'
C_NAME='\033[38;5;111m'

if [[ ! -r "$QUOTES_FILE" ]]; then
  printf '%s\n' '"Quote file missing."'
  exit 0
fi

pick_line() {
  if command -v shuf >/dev/null 2>&1; then
    shuf -n 1 "$QUOTES_FILE"
  else
    awk 'BEGIN{srand()} {a[NR]=$0} END{if(NR>0) print a[int(rand()*NR)+1]}' "$QUOTES_FILE"
  fi
}

line="$(pick_line)"
if [[ -z "$line" ]]; then
  exit 0
fi

IFS=$'\t' read -r en jp name <<< "$line"

printf '%b%s%b\n' "$C_EN" "$en" "$C_RESET"
printf '%b%s%b\n' "$C_JP" "$jp" "$C_RESET"
printf '%b%s%b\n' "$C_NAME" "$name" "$C_RESET"
