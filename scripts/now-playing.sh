#!/usr/bin/env bash

set -u

STATE_FILE="/tmp/polybar-now-playing.state"
WIDTH="${NOW_PLAYING_WIDTH:-34}"
GAP="   //   "

map_player_tag() {
  local name="${1,,}"
  case "$name" in
    spotify) printf '%s' "SP" ;;
    mpv) printf '%s' "MP" ;;
    firefox|firefoxesr) printf '%s' "FR" ;;
    chrome|google-chrome|chromium|brave|microsoft-edge|microsoft-edge-dev) printf '%s' "CH" ;;
    vlc) printf '%s' "VL" ;;
    cmus) printf '%s' "CM" ;;
    ncspot) printf '%s' "NC" ;;
    strawberry) printf '%s' "SB" ;;
    *) printf '%s' "PL" ;;
  esac
}

trim() {
  local s="$1"
  s="${s//$'\n'/ }"
  s="${s//$'\r'/ }"
  s="${s//$'\t'/ }"
  while [[ "$s" == *"  "* ]]; do
    s="${s//  / }"
  done
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

fetch_now_playing() {
  local status artist title text player tag

  if ! command -v playerctl >/dev/null 2>&1; then
    printf '%s\t%s' "ST" "stopped"
    return
  fi

  player="$(playerctl metadata --format '{{playerName}}' 2>/dev/null || true)"
  tag="$(map_player_tag "$player")"

  status="$(playerctl status 2>/dev/null || true)"
  if [[ -z "$status" || "$status" == "Stopped" ]]; then
    printf '%s\t%s' "${tag:-ST}" "stopped"
    return
  fi

  artist="$(playerctl metadata artist 2>/dev/null || true)"
  title="$(playerctl metadata title 2>/dev/null || true)"
  artist="$(trim "$artist")"
  title="$(trim "$title")"

  if [[ -n "$artist" && -n "$title" ]]; then
    text="$artist - $title"
  elif [[ -n "$title" ]]; then
    text="$title"
  elif [[ -n "$artist" ]]; then
    text="$artist"
  else
    text="playing"
  fi

  if [[ "$status" == "Paused" ]]; then
    text="[PAUSED] $text"
  fi

  printf '%s\t%s' "$tag" "$text"
}

render_fixed_or_scroll() {
  local text="$1"
  local hash old_hash offset line loop view new_offset

  if ! [[ "$WIDTH" =~ ^[0-9]+$ ]] || (( WIDTH < 8 )); then
    WIDTH=34
  fi

  if (( ${#text} <= WIDTH )); then
    printf '%-*s\n' "$WIDTH" "$text"
    return
  fi

  hash="$(printf '%s' "$text" | md5sum | awk '{print $1}')"
  old_hash=""
  offset=0
  if [[ -r "$STATE_FILE" ]]; then
    IFS= read -r old_hash < "$STATE_FILE" || true
    IFS= read -r offset < <(sed -n '2p' "$STATE_FILE") || true
  fi

  if [[ "$old_hash" != "$hash" ]] || ! [[ "$offset" =~ ^[0-9]+$ ]]; then
    offset=0
  fi

  loop="${text}${GAP}"
  line="${loop}${loop}"
  view="${line:$offset:$WIDTH}"
  printf '%s\n' "$view"

  new_offset=$((offset + 1))
  if (( new_offset >= ${#loop} )); then
    new_offset=0
  fi
  printf '%s\n%s\n' "$hash" "$new_offset" > "$STATE_FILE"
}

IFS=$'\t' read -r tag text < <(fetch_now_playing)
[[ -n "${tag:-}" ]] || tag="PL"
[[ -n "${text:-}" ]] || text="stopped"

payload="$(render_fixed_or_scroll "$text")"
printf '%%{F#e60053}%s%%{F-} %s\n' "$tag" "$payload"
