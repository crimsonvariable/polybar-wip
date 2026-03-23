#!/usr/bin/env bash

set -euo pipefail

STATE_FILE="/tmp/polybar-theme.state"
FLOW_FILE="/tmp/polybar-flow.state"
themes=("neon" "synth" "wired" "mono" "sunset" "aurora" "ember" "ocean" "acid" "blood")
modes=("flow" "reverse" "pulse" "static")

get_theme() {
  if [[ -r "$STATE_FILE" ]]; then
    read -r t < "$STATE_FILE" || true
    for v in "${themes[@]}"; do
      [[ "$v" == "${t:-}" ]] && { printf '%s' "$v"; return; }
    done
  fi
  printf 'neon'
}

set_theme() {
  printf '%s\n' "$1" > "$STATE_FILE"
}

get_mode() {
  if [[ -r "$FLOW_FILE" ]]; then
    read -r m _ < "$FLOW_FILE" || true
    for v in "${modes[@]}"; do
      [[ "$v" == "${m:-}" ]] && { printf '%s' "$v"; return; }
    done
  fi
  printf 'flow'
}

get_speed() {
  if [[ -r "$FLOW_FILE" ]]; then
    read -r _ s < "$FLOW_FILE" || true
    if [[ "${s:-}" =~ ^[0-9]+$ ]]; then
      printf '%s' "$s"
      return
    fi
  fi
  printf '220'
}

set_flow() {
  local mode="$1"
  local speed="$2"
  printf '%s %s\n' "$mode" "$speed" > "$FLOW_FILE"
}

next_theme() {
  local cur="$1"
  local i
  for i in "${!themes[@]}"; do
    if [[ "${themes[$i]}" == "$cur" ]]; then
      printf '%s' "${themes[$(((i + 1) % ${#themes[@]}))]}"
      return
    fi
  done
  printf 'neon'
}

next_mode() {
  local cur="$1"
  local i
  for i in "${!modes[@]}"; do
    if [[ "${modes[$i]}" == "$cur" ]]; then
      printf '%s' "${modes[$(((i + 1) % ${#modes[@]}))]}"
      return
    fi
  done
  printf 'flow'
}

label_color() {
  case "$1" in
    neon) printf '#ff85c0' ;;
    synth) printf '#4cc9f0' ;;
    wired) printf '#70e000' ;;
    mono) printf '#d9d9d9' ;;
    sunset) printf '#ffb347' ;;
    aurora) printf '#80ffdb' ;;
    ember) printf '#ff6d00' ;;
    ocean) printf '#48cae4' ;;
    acid) printf '#99d98c' ;;
    blood) printf '#e5383b' ;;
    *) printf '#ff85c0' ;;
  esac
}

show_menu() {
  local cur mode speed choice i midx
  while true; do
    cur="$(get_theme)"
    mode="$(get_mode)"
    speed="$(get_speed)"
    printf '\nTheme/Flow Control\n'
    printf 'Current theme: %s\n' "$cur"
    printf 'Current mode : %s\n' "$mode"
    printf 'Current speed: %s\n\n' "$speed"
    printf 'Available themes: '
    for i in "${!themes[@]}"; do
      if (( i > 0 )); then printf ', '; fi
      printf '%s' "${themes[$i]}"
    done
    printf '\n'
    printf 'Available modes : '
    for i in "${!modes[@]}"; do
      if (( i > 0 )); then printf ', '; fi
      printf '%s' "${modes[$i]}"
    done
    printf '\n\n'
    printf '1) Set theme\n'
    printf '2) Cycle theme\n'
    printf '3) Set mode\n'
    printf '4) Cycle mode\n'
    printf '5) Speed: slow (120)\n'
    printf '6) Speed: medium (220)\n'
    printf '7) Speed: fast (360)\n'
    printf '8) Custom speed\n'
    printf '9) Exit\n\n'
    read -r -p 'Choice: ' choice
    case "${choice:-}" in
      1)
        printf '\nThemes:\n'
        for i in "${!themes[@]}"; do
          printf '%d) %s\n' $((i + 1)) "${themes[$i]}"
        done
        read -r -p 'Theme number: ' i
        if [[ "$i" =~ ^[0-9]+$ ]] && (( i >= 1 && i <= ${#themes[@]} )); then
          set_theme "${themes[$((i - 1))]}"
        fi
        ;;
      2)
        set_theme "$(next_theme "$cur")"
        ;;
      3)
        printf '\nModes:\n'
        for midx in "${!modes[@]}"; do
          printf '%d) %s\n' $((midx + 1)) "${modes[$midx]}"
        done
        read -r -p 'Mode number: ' midx
        if [[ "$midx" =~ ^[0-9]+$ ]] && (( midx >= 1 && midx <= ${#modes[@]} )); then
          set_flow "${modes[$((midx - 1))]}" "$speed"
        fi
        ;;
      4)
        set_flow "$(next_mode "$mode")" "$speed"
        ;;
      5)
        set_flow "$mode" 120
        ;;
      6)
        set_flow "$mode" 220
        ;;
      7)
        set_flow "$mode" 360
        ;;
      8)
        read -r -p 'Custom speed (20-1000): ' speed
        if [[ "$speed" =~ ^[0-9]+$ ]] && (( speed >= 20 && speed <= 1000 )); then
          set_flow "$mode" "$speed"
        fi
        ;;
      9|"")
        break
        ;;
    esac
  done
  printf 'Press Enter to close...'
  read -r _
}

show_help() {
  cat <<'EOF'
theme-switch.sh - Theme + animation controller for Polybar rainbow modules

Usage:
  theme-switch.sh --label
  theme-switch.sh --next
  theme-switch.sh --next-mode
  theme-switch.sh --menu
  theme-switch.sh --help

Menu option guide:
  1) Set theme
     Choose a specific theme by number.
     Example: picking "5" selects the 5th theme in the list.

  2) Cycle theme
     Move to the next theme in sequence.
     Example: neon -> synth -> wired -> ...

  3) Set mode
     Choose a specific animation mode by number.
     Modes: flow, reverse, pulse, static.

  4) Cycle mode
     Move to the next animation mode.
     Example: flow -> reverse -> pulse -> static -> flow.

  5) Speed: slow (120)
     Set animation speed to 120 (slower movement).

  6) Speed: medium (220)
     Set animation speed to 220 (balanced/default).

  7) Speed: fast (360)
     Set animation speed to 360 (faster movement).

  8) Custom speed
     Enter your own speed (range: 20-1000).
     Example: 500 for very fast movement.

  9) Exit
     Close the menu.

Direct command examples:
  ~/.config/polybar/scripts/theme-switch.sh --label
  ~/.config/polybar/scripts/theme-switch.sh --next
  ~/.config/polybar/scripts/theme-switch.sh --next-mode
  ~/.config/polybar/scripts/theme-switch.sh --menu
EOF
}

cmd="${1:---label}"
case "$cmd" in
  --label)
    cur="$(get_theme)"
    col="$(label_color "$cur")"
    mode="$(get_mode)"
    printf '%%{F%s}[THM:%s|%s]%%{F-}\n' "$col" "${cur^^}" "${mode^^}"
    ;;
  --next)
    cur="$(get_theme)"
    nxt="$(next_theme "$cur")"
    set_theme "$nxt"
    ;;
  --next-mode)
    mode="$(get_mode)"
    speed="$(get_speed)"
    set_flow "$(next_mode "$mode")" "$speed"
    ;;
  --menu)
    show_menu
    ;;
  --help|-h)
    show_help
    ;;
  *)
    printf 'usage: %s [--label|--next|--next-mode|--menu|--help]\n' "$(basename "$0")" >&2
    exit 1
    ;;
esac
