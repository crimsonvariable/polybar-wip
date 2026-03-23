#!/bin/sh

killall -q polybar

while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

LOG=/tmp/polybar-launch.log
STARTUP_FILE=/tmp/polybar-startup.until
STARTUP_SECS=10
STARTUP_HOLD_SECS=5
export STARTUP_SECS
export STARTUP_HOLD_SECS
{
  echo "==== $(date) ===="
  echo "DISPLAY=$DISPLAY"
  xrandr --query 2>/dev/null | awk '/ connected/{print "XRANDR:", $1, $2, $3}'
  polybar --list-monitors 2>/dev/null | sed 's/^/POLYBAR: /'
} >> "$LOG"

expr "$(date +%s)" + "$STARTUP_SECS" > "$STARTUP_FILE" 2>/dev/null || true

monitors="$(xrandr --query 2>/dev/null | awk '/ connected/{print $1}')"
if [ -z "$monitors" ]; then
  monitors="$(polybar --list-monitors 2>/dev/null | cut -d: -f1)"
fi
primary="$(xrandr --query 2>/dev/null | awk '/ connected primary/{print $1; exit}')"

if [ -n "$primary" ]; then
  MONITOR="$primary" polybar -c ~/.config/polybar/config.conf boot >>"$LOG" 2>&1 &
else
  polybar -c ~/.config/polybar/config.conf boot >>"$LOG" 2>&1 &
fi
boot_pid=$!

(
  if [ -x ~/.config/polybar/scripts/startup-load.sh ]; then
    while ! ~/.config/polybar/scripts/startup-load.sh --done >/dev/null 2>&1; do
      sleep 0.2
    done
    sleep "$STARTUP_HOLD_SECS"
  else
    sleep "$((STARTUP_SECS + STARTUP_HOLD_SECS))"
  fi

  polybar -c ~/.config/polybar/config.conf main >>"$LOG" 2>&1 &
  polybar -c ~/.config/polybar/config.conf main2 >>"$LOG" 2>&1 &

  for m in $monitors; do
    if [ -n "$primary" ] && [ "$m" = "$primary" ]; then
      continue
    fi
    MONITOR="$m" polybar -c ~/.config/polybar/config.conf workspaces-only >>"$LOG" 2>&1 &
  done

  kill "$boot_pid" 2>/dev/null || true
) &
