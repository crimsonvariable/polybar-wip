# Polybar Support and Troubleshooting

This runbook is for maintenance, debugging, and safe recovery after edits.

## 1. Quick sanity checks

```bash
bash -n ~/.config/polybar/launch.sh
bash -n ~/.config/polybar/scripts/*.sh
polybar --list-monitors
```

If syntax checks pass and monitors are detected, startup problems are usually config/module-related.

## 2. Launch and inspect logs

```bash
~/.config/polybar/launch.sh
tail -n 120 /tmp/polybar-launch.log
```

What to look for:

- `Parsing config file` appears for each bar instance
- `Loaded font` for required fonts
- module load errors (e.g. missing internal feature support)
- monitor assignment lines from `launch.sh`

## 3. Common issues and fixes

## Problem: bar does not appear after reboot

Check in `~/.config/i3/config`:

- `exec_always --no-startup-id ~/.config/polybar/launch.sh`

Check `~/.xinitrc` launches `i3` successfully.

## Problem: bars disappear immediately

Typical causes:

- script crash due to strict mode (`set -euo pipefail`)
- missing dependency command
- module `exec-if` returning false unexpectedly

Debug by running the script directly:

```bash
~/.config/polybar/scripts/startup-load.sh
~/.config/polybar/scripts/candy-loop.sh
~/.config/polybar/scripts/wifi-status.sh
```

## Problem: build percent stuck on text only

`build-progress.sh` needs readable emerge logs:

- `/var/log/emerge.log`
- `/var/log/emerge-fetch.log`

If unreadable, state is limited to coarse statuses (`emerge`, `fetch`, `idle`, etc).

## Problem: now playing/SSID text shifts layout

Your setup uses fixed-width scrolling logic in scripts.
If jitter returns, verify:

- `NOW_PLAYING_WIDTH` remains set to a stable value
- wifi `WIDTH` constant is unchanged
- module order in `modules-center` is unchanged

## Problem: now-playing says `stopped` while one player is active

Check which players/statuses are visible to `playerctl`:

```bash
playerctl -l
for p in $(playerctl -l | awk '!seen[$0]++'); do
  printf '%s\t%s\n' "$p" "$(playerctl -p "$p" status 2>/dev/null || echo ERR)"
done
```

`now-playing.sh` now prefers one active source (`Playing` then `Paused`) and reads
status/metadata from that same source to avoid mixed-source false `stopped`.

## Problem: theme labels not updating

Theme/flow state files may be stale:

```bash
rm -f /tmp/polybar-theme.state /tmp/polybar-flow.state
polybar-msg cmd restart
```

## Problem: startup animation not finishing

Check:

- `/tmp/polybar-startup.until`
- `/tmp/polybar-startup.pos`
- `STARTUP_SECS` and `STARTUP_HOLD_SECS` exported by launcher

## Problem: duplicate polybars after reload/manual launch

Current launcher has generation-lock protection via:

- `/tmp/polybar-launch.id`

If duplicates still appear, force clean relaunch:

```bash
killall -q polybar
rm -f /tmp/polybar-launch.id
~/.config/polybar/launch.sh
```

Also verify only one i3 autostart line exists for polybar in `~/.config/i3/config`.

## Problem: updater fails on `@world` with locale error (pwsh)

If you see messages like:
- `Could not switch to the en_US.UTF-8 locale`

Fix:

```bash
sudo sh -c 'grep -q "^en_US.UTF-8 UTF-8$" /etc/locale.gen || echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen'
sudo locale-gen
locale -a | grep -i 'en_US\.utf'
```

Then rerun updater / world update.

## Problem: screenshot module/keybind does nothing

Check:

```bash
command -v flameshot
```

If missing, install Flameshot and reload i3 config (`Mod+Shift+c`).

## Problem: `TOOLS` module click does nothing

Verify both files and execute bits:

```bash
ls -l ~/.config/polybar/scripts/tools-launcher.sh ~/.config/rofi/scripts/tool-hub.sh
command -v rofi
```

Expected:
- both scripts executable
- `rofi` present in PATH

## 4. Safe reset procedure

If visuals get heavily out-of-sync:

```bash
killall -q polybar
rm -f /tmp/polybar-*.state /tmp/polybar-*.count /tmp/polybar-*.until /tmp/polybar-*.pos 2>/dev/null
~/.config/polybar/launch.sh
```

This resets transient state only, not your permanent config.

## 5. Recovery checklist after major edits

1. Run shell syntax checks.
2. Run `~/.config/polybar/launch.sh` manually.
3. Tail `/tmp/polybar-launch.log`.
4. Confirm each module script still runs standalone.
5. Confirm click actions from modules open expected tools (kitty menus/updater).

## 6. Before sharing or committing

Recommended:

```bash
git status
bash -n ~/.config/polybar/launch.sh
bash -n ~/.config/polybar/scripts/*.sh
```

Also keep docs in sync:

- update changed script doc in `documentation/scripts/`
- update `DEPENDENCIES.md` if new command/tool was introduced

## 7. Escalation notes

Use this support order:

1. Script-level standalone test
2. Module-level config check
3. Launcher monitor mapping check
4. i3/xinit session autostart check

That order isolates failures fastest.
