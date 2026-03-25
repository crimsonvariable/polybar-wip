#!/usr/bin/env bash

set -u

THEME_STATE_FILE="/tmp/polybar-theme.state"

json="$(i3-msg -t get_workspaces 2>/dev/null || printf '[]')"

exists_nums="$(printf '%s\n' "$json" | grep -oE '"num":[[:space:]]*-?[0-9]+' | grep -oE -- '-?[0-9]+' | tr '\n' ' ')"
focused_num="$(printf '%s\n' "$json" | tr '{' '\n' | grep '"focused":true' | sed -n 's/.*"num":[[:space:]]*\(-\?[0-9]\+\).*/\1/p' | head -n1)"
visible_nums="$(printf '%s\n' "$json" | tr '{' '\n' | grep '"visible":true' | sed -n 's/.*"num":[[:space:]]*\(-\?[0-9]\+\).*/\1/p' | tr '\n' ' ')"
urgent_nums="$(printf '%s\n' "$json" | tr '{' '\n' | grep '"urgent":true' | sed -n 's/.*"num":[[:space:]]*\(-\?[0-9]\+\).*/\1/p' | tr '\n' ' ')"

theme="neon"
if [[ -r "$THEME_STATE_FILE" ]]; then
  read -r t < "$THEME_STATE_FILE" || true
  [[ -n "${t:-}" ]] && theme="$t"
fi

color_empty="#666666"
color_exists="#dfdfdf"
color_visible="#e60053"
color_focused="#ffb52a"
color_urgent="#bd2c40"

case "$theme" in
  neon)
    color_empty="#595959"
    color_exists="#f0f0f0"
    color_visible="#ff85c0"
    color_focused="#ffc53d"
    color_urgent="#ff4d4f"
    ;;
  synth)
    color_empty="#4b3f66"
    color_exists="#e0d4ff"
    color_visible="#b5179e"
    color_focused="#4cc9f0"
    color_urgent="#f72585"
    ;;
  wired)
    color_empty="#355e3b"
    color_exists="#d8f3dc"
    color_visible="#38b000"
    color_focused="#9ef01a"
    color_urgent="#ff595e"
    ;;
  mono)
    color_empty="#6e6e6e"
    color_exists="#d9d9d9"
    color_visible="#a6a6a6"
    color_focused="#f5f5f5"
    color_urgent="#b0b0b0"
    ;;
  sunset)
    color_empty="#6e4a3a"
    color_exists="#ffe8d6"
    color_visible="#ff7b54"
    color_focused="#ffd166"
    color_urgent="#ef476f"
    ;;
  aurora)
    color_empty="#4b5d67"
    color_exists="#e0fbfc"
    color_visible="#00bbf9"
    color_focused="#80ffdb"
    color_urgent="#ff4d6d"
    ;;
  ember)
    color_empty="#6b3e1f"
    color_exists="#ffe8d6"
    color_visible="#ff6d00"
    color_focused="#ffba08"
    color_urgent="#d00000"
    ;;
  ocean)
    color_empty="#355070"
    color_exists="#caf0f8"
    color_visible="#0096c7"
    color_focused="#48cae4"
    color_urgent="#ef476f"
    ;;
  acid)
    color_empty="#3b5f4a"
    color_exists="#ecf8d4"
    color_visible="#52b69a"
    color_focused="#d9ed92"
    color_urgent="#ff595e"
    ;;
  blood)
    color_empty="#5a1e1e"
    color_exists="#ffd6d6"
    color_visible="#e5383b"
    color_focused="#ff6b6b"
    color_urgent="#ff0000"
    ;;
esac

contains_num() {
  local list=" $1 "
  local n="$2"
  [[ "$list" == *" $n "* ]]
}

out=""
for i in 1 2 3 4 5 6 7 8 9 10; do
  color="$color_empty"

  if contains_num "$exists_nums" "$i"; then
    color="$color_exists"
  fi
  if contains_num "$visible_nums" "$i"; then
    color="$color_visible"
  fi
  if contains_num "$urgent_nums" "$i"; then
    color="$color_urgent"
  fi
  if [[ -n "$focused_num" && "$focused_num" == "$i" ]]; then
    color="$color_focused"
  fi

  out+="%{A1:i3-msg workspace number $i >/dev/null:}%{F${color}}[$i]%{F-}%{A} "
done

printf '%s\n' "${out% }"
