# wifi-status.sh

Script path: `~/.config/polybar/scripts/wifi-status.sh`

## Purpose

Renders Wi-Fi strength as `ICONIC!` bar plus fixed-width scrolling SSID.

## Inputs / Flags

No flags.

Environment variable:

- `WIFI_IFACE` (default `wlan0`)

## Output format

- connected: `[<ICONIC bar>] <scrolling ssid>`
- disconnected: `[ICONIC! gray] <iface>: dc`

## Detection strategy

Interface detection:

1. explicit `WIFI_IFACE` if it exists
2. `iw dev`
3. `nmcli`
4. fallback to configured iface name

Signal strength:

1. `nmcli` if available
2. `/proc/net/wireless`
3. `iwctl station <iface> show` RSSI mapping
4. fallback `0`

SSID:

1. `iwgetid`
2. `iw dev <iface> link`
3. `nmcli`
4. `iwctl station <iface> show`
5. fallback `disconnected`

## State files

- `/tmp/polybar-wifi-scroll.state`

Used for persistent scroll offset.

## Polybar integration

Used by `[module/wifi]`.

Label module `[module/wifi-label]` is rendered separately by `theme-engine.sh --block WIFI`.

## Manual test

```bash
~/.config/polybar/scripts/wifi-status.sh
WIFI_IFACE=wlan0 ~/.config/polybar/scripts/wifi-status.sh
```
