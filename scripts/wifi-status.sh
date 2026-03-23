#!/usr/bin/env bash

set -euo pipefail

STATE_FILE="/tmp/polybar-wifi-scroll.state"
WIDTH=14
GAP="   "
WIFI_IFACE="${WIFI_IFACE:-wlan0}"

detect_iface() {
  if [[ -d "/sys/class/net/${WIFI_IFACE}" ]]; then
    printf '%s' "$WIFI_IFACE"
    return 0
  fi

  if command -v iw >/dev/null 2>&1; then
    local i
    i="$(iw dev 2>/dev/null | awk '$1=="Interface"{print $2; exit}')"
    if [[ -n "${i:-}" ]]; then
      printf '%s' "$i"
      return 0
    fi
  fi

  if command -v nmcli >/dev/null 2>&1; then
    local i
    i="$(nmcli -t -f DEVICE,TYPE dev 2>/dev/null | awk -F: '$2=="wifi"{print $1; exit}')"
    if [[ -n "${i:-}" ]]; then
      printf '%s' "$i"
      return 0
    fi
  fi

  printf '%s' "$WIFI_IFACE"
}

get_strength_pct() {
  local iface="$1"

  if command -v nmcli >/dev/null 2>&1; then
    local s
    s="$(nmcli -t -f IN-USE,SIGNAL,DEVICE dev wifi 2>/dev/null | awk -F: -v d="$iface" '$1=="*" && $3==d {print $2; exit}')"
    if [[ "$s" =~ ^[0-9]+$ ]]; then
      printf '%s' "$s"
      return 0
    fi
    s="$(nmcli -t -f SIGNAL,DEVICE dev wifi list --rescan no 2>/dev/null | awk -F: -v d="$iface" '$2==d {print $1; exit}')"
    if [[ "$s" =~ ^[0-9]+$ ]]; then
      printf '%s' "$s"
      return 0
    fi
  fi

  if [[ -r /proc/net/wireless ]]; then
    local q
    q="$(awk -v d="${iface}:" '$1==d {gsub(/\./,"",$3); print int($3); exit}' /proc/net/wireless 2>/dev/null || true)"
    if [[ "$q" =~ ^[0-9]+$ ]]; then
      # /proc/net/wireless link quality is commonly 0..70
      q=$((q * 100 / 70))
      (( q < 0 )) && q=0
      (( q > 100 )) && q=100
      printf '%s' "$q"
      return 0
    fi
  fi

  # iwd / iwctl fallback
  if command -v iwctl >/dev/null 2>&1; then
    local dbm pct
    dbm="$(iwctl station "$iface" show 2>/dev/null | awk '/RSSI/ {for(i=1;i<=NF;i++) if ($i ~ /^-?[0-9]+$/) {print $i; exit}}')"
    if [[ "$dbm" =~ ^-?[0-9]+$ ]]; then
      # Approximate dBm -> quality percent mapping.
      pct=$((2 * (dbm + 100)))
      (( pct < 0 )) && pct=0
      (( pct > 100 )) && pct=100
      printf '%s' "$pct"
      return 0
    fi
  fi

  printf '0'
}

get_ssid() {
  local iface="$1"

  if command -v iwgetid >/dev/null 2>&1; then
    local id
    id="$(iwgetid "$iface" -r 2>/dev/null || iwgetid -r 2>/dev/null || true)"
    if [[ -n "$id" ]]; then
      printf '%s' "$id"
      return 0
    fi
  fi

  if command -v iw >/dev/null 2>&1; then
    local id
    id="$(iw dev "$iface" link 2>/dev/null | sed -n 's/^\\s*SSID: //p' | head -n1)"
    if [[ -n "$id" ]]; then
      printf '%s' "$id"
      return 0
    fi
  fi

  if command -v nmcli >/dev/null 2>&1; then
    local id
    id="$(nmcli -t -f ACTIVE,SSID,DEVICE dev wifi 2>/dev/null | awk -F: -v d="$iface" '$1=="yes" && $3==d {print $2; exit}')"
    if [[ -n "$id" ]]; then
      printf '%s' "$id"
      return 0
    fi
  fi

  # iwd / iwctl fallback
  if command -v iwctl >/dev/null 2>&1; then
    local id
    id="$(iwctl station "$iface" show 2>/dev/null | awk -F'Connected network' 'NF>1 {gsub(/^[ \t]+/, "", $2); print $2; exit}')"
    if [[ -n "$id" && "$id" != "(none)" ]]; then
      printf '%s' "$id"
      return 0
    fi
  fi

  printf 'disconnected'
}

scroll_text() {
  local text="$1"
  local hash old_hash offset loop line view
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

  if (( ${#text} <= WIDTH )); then
    printf '%-*s\n' "$WIDTH" "$text"
    printf '%s\n0\n' "$hash" > "$STATE_FILE"
    return
  fi

  loop="${text}${GAP}"
  line="${loop}${loop}"
  view="${line:$offset:$WIDTH}"
  printf '%s\n' "$view"

  offset=$((offset + 1))
  if (( offset >= ${#loop} )); then
    offset=0
  fi
  printf '%s\n%s\n' "$hash" "$offset" > "$STATE_FILE"
}

iface="$(detect_iface)"
ssid="$(get_ssid "$iface")"
strength="$(get_strength_pct "$iface")"
[[ "$strength" =~ ^[0-9]+$ ]] || strength=0
(( strength < 0 )) && strength=0
(( strength > 100 )) && strength=100

if (( strength < 40 )); then
  color="#9ece6a"
elif (( strength < 70 )); then
  color="#e0af68"
else
  color="#f7768e"
fi

chars="ICONIC!"
total=${#chars}
filled=$((strength * total / 100))
(( filled < 0 )) && filled=0
(( filled > total )) && filled=total
bar=""
for ((i=0; i<total; i++)); do
  ch="${chars:i:1}"
  if (( i < filled )); then
    bar="${bar}%{F${color}}${ch}%{F-}"
  else
    bar="${bar}%{F#555555}${ch}%{F-}"
  fi
done

if [[ "$ssid" == "disconnected" ]]; then
  printf '[%%{F#555555}ICONIC!%%{F-}] %s\n' "$(scroll_text "${iface}: dc")"
else
  printf '[%s] %s\n' "$bar" "$(scroll_text "$ssid")"
fi
