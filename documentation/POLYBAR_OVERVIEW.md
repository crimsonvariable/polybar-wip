# Polybar System Overview (CrimsonVAR)

This file is a technical, readable explanation of the current Polybar setup in `~/.config/polybar`.
It is written so you (or anyone reading later) can understand the *why* and *how* without reverse-engineering every script.

Project notice:
- For authorship/support/scope context, see `~/.config/polybar/documentation/PROJECT_NOTICE.md`.
- For reusable default disclaimer text for future repositories, see `~/.config/polybar/documentation/REPO_NOTICE_TEMPLATE.md`.

## 1) High-Level Architecture

This setup is not a single bar. It is a staged, multi-bar system:
- A boot-only bar shown first (`bar/boot`)
- Main bar row 1 (`bar/main`)
- Main bar row 2 (`bar/main2`)
- Workspace-only bars on non-primary monitors (`bar/workspaces-only`)

Main config: `~/.config/polybar/config.conf`
Launcher: `~/.config/polybar/launch.sh`
Scripts: `~/.config/polybar/scripts/`

## 2) Bar Layout (Current)

### `bar/main` (Top system row)
- `modules-left = ws-list`
- `modules-center = now-playing`
- `modules-right = volume-label volume cpu memory gpu-amd gpu-nv bld-label build-percent`

Purpose:
- Left anchors workspace state.
- Center is media title flow.
- Right is dense system telemetry (audio/cpu/ram/gpu/build).

### `bar/main2` (Second top row)
- `modules-left = custom-note gentoo-update theme-switch flameshot dotfiles-sync`
- `modules-center = load-word candy-loop`
- `modules-right = wifi-label wifi date`

Purpose:
- Left is identity + actions.
- Center is aesthetic/animated lane.
- Right is network + clock.

### `bar/boot` (Temporary startup bar)
- `modules-center = startup-load`

Purpose:
- Show startup animation before normal bars appear.

### `bar/workspaces-only` (Non-primary monitors)
- `modules-center = ws-list`

Purpose:
- Keep other screens clean while still providing clickable workspace control.

## 3) Boot Pipeline (What Happens on Launch)

Implemented in `~/.config/polybar/launch.sh`.

### Sequence
1. Kill running polybar instances (`killall -q polybar`).
2. Write a unique launch generation id to `/tmp/polybar-launch.id`.
3. Wait until all old bars are dead (`pgrep` loop).
4. Log monitor/session info to `/tmp/polybar-launch.log`.
5. Write startup deadline to `/tmp/polybar-startup.until`.
6. Launch `bar/boot` on primary monitor.
7. Poll `startup-load.sh --done` until animation reaches completion.
8. Sleep extra hold time (`STARTUP_HOLD_SECS`, currently 5).
9. Re-check launch generation id to avoid stale delayed spawns.
10. Launch `bar/main` and `bar/main2`.
11. Launch `bar/workspaces-only` on all non-primary monitors.
12. Kill boot bar process.

### Why this design
- Keeps startup visually intentional.
- Avoids half-rendered normal bars while startup animation is still running.
- Makes startup timing deterministic using script hooks instead of fixed blind sleep.
- Prevents duplicate bars when launcher is triggered repeatedly during startup delay windows.

## 4) Theme Engine and Selector (How It Actually Works)

Core files:
- `dynamic-rainbow.sh`
- `theme-switch.sh`

State files:
- `/tmp/polybar-theme.state` (theme name)
- `/tmp/polybar-flow.state` (mode + speed)

### `dynamic-rainbow.sh`
- Reads current theme + flow mode/speed from `/tmp`.
- Builds color arrays for each theme (`neon`, `synth`, `wired`, `mono`, `sunset`, `aurora`, `ember`, `ocean`, `acid`, `blood`).
- Supports animated gradient modes:
  - `flow`
  - `reverse`
  - `pulse`
  - `static`
- Supports `--block`, which paints an entire label with one sampled color.

Used for labels like:
- `VOL`
- `BLD`
- `WIFI`
- `custom-note`
- `gentoo-update` text

### `theme-switch` module behavior
Module definition in `config.conf`:
- `exec = .../theme-switch.sh --label`
- `click-left = .../theme-switch.sh --next`
- `click-middle = .../theme-switch.sh --next-mode`
- `click-right = kitty -e .../theme-switch.sh --menu`

Meaning:
- Left click cycles theme.
- Middle click cycles animation mode.
- Right click opens interactive menu in Kitty.

### `theme-switch.sh --menu` (Kitty UI)
It is a text UI with numbered options:
1. Set theme by number
2. Cycle theme
3. Set mode by number
4. Cycle mode
5. Slow speed (120)
6. Medium speed (220)
7. Fast speed (360)
8. Custom speed (20-1000)
9. Exit

So the “theme selector kitty UI” is a real interactive TUI in terminal, not a fake label.

## 5) Gentoo Updater Module and UI (Quotes + Y/N + Explanations)

Trigger path:
- Polybar module: `gentoo-update`
- Click action: `click-left = kitty -e ~/.config/polybar/scripts/gentoo-update.sh`

### What `gentoo-update.sh` does
It is a step-by-step, opt-in updater with explicit confirmations and safety notes.

#### Core behavior
- Shows intro text.
- Runs `emerge --moo` at start.
- For each maintenance phase, prints a `disclaimer(...)` block containing:
  - command to be run
  - effect/what it does
  - exact meaning of YES
  - exact meaning of NO
- Then asks a strict `[y/n]` prompt.
- If YES, executes that step.
- If NO, skips and continues where safe.
- If a command fails, it prints the failing command and asks whether to continue remaining steps.

#### Steps covered
1. `sudo -v` auth (optional)
2. `sudo emerge --sync`
3. `sudo emerge -avuDU --with-bdeps=y @world`
4. `sudo emerge -av @preserved-rebuild`
5. `sudo emerge --depclean -av` (with extra safety gate if `@world` was skipped)
6. `dispatch-conf` (fallback `etc-update`)
7. `sudo eselect news read`

#### Locale pre-check for `@world`
- Before running the `@world` step, script checks whether `en_US.UTF-8` exists (`locale -a`).
- If missing, it prints explicit fix commands and asks whether to try `@world` anyway.
- This is mainly to avoid `app-shells/pwsh` pkg_pretend failures that hard-stop updates.

#### Quote injection logic
Before each yes/no question, it runs:
- `~/.config/polybar/scripts/random-lain-quote.sh`

That script:
- picks random TSV line from `lain-quotes.tsv`
- prints English quote in white
- prints Japanese quote in magenta
- prints name/source in soft blue

So yes, the updater UI is quote-driven by design at each decision point.

#### End behavior
- Prints step summary (`ran` vs `skipped`).
- Prints another random quote.
- Runs `fastfetch --logo lainos --structure logo`.
- Waits for Enter to close.

## 6) Runtime Modules Explained

### Workspace
#### `ws-list` (`ws-list.sh`)
- Reads i3 workspace JSON (`i3-msg -t get_workspaces`).
- Always renders `[1]...[10]`.
- Every slot is clickable to switch workspace.
- Colors are theme-aware and state-aware:
  - focused
  - visible
  - urgent
  - existing
  - empty

### Media
#### `now-playing` (`now-playing.sh`)
- Pulls metadata via `playerctl`.
- Infers source tag (Spotify/mpv/firefox/chrome-family/etc).
- Keeps fixed output width and marquee-scrolls long titles.
- Designed to avoid layout jitter.

### Audio
#### `volume-label` + `volume`
- Label comes from rainbow block (`VOL`).
- Data comes from `volume-status.sh`.
- Tries PipeWire (`wpctl`) first, Pulse fallback (`pactl`).
- Handles muted and `N/A` states.

### CPU / RAM / GPU bars
#### Shared visual rule
Bars are “full text bars” using `ICONIC!`:
- Loaded portion: active load color
- Unloaded portion: dark gray

This means the string length is fixed while visual intensity changes with load.

#### CPU (`cpu-status.sh`)
- Usage from `/proc/stat` deltas.
- Temp from hwmon path.
- Output pattern: `CPU [ICONIC!] 0xx% tempC`.

#### RAM (`memory-status.sh`)
- Usage from `/proc/meminfo`.
- Same `ICONIC!` style and color thresholds.

#### GPU (`gpu-status.sh`)
- NVIDIA via `nvidia-smi`.
- AMD via `/sys/bus/pci/.../gpu_busy_percent` + hwmon temp.
- Can run in `--amd`, `--nv`, or combined mode.

### Build progress
#### `bld-label` + `build-percent`
- Label `BLD` is rainbow block.
- `build-progress.sh` parses emerge/fetch logs.
- Emits state-oriented output (`idle`, `fetch`, `emerge`, percent when derivable).

### Screenshot actions
#### `flameshot` (config-only module)
- Label `SHOT` is theme-colored via `dynamic-rainbow --block`.
- Click actions:
  - Left click: `flameshot gui` (interactive region capture)
  - Right click: `flameshot full -p ~/Pictures/Screenshots` (full-screen save)
- Matching i3 keybinds:
  - `Print` -> `flameshot gui`
  - `Shift+Print` -> full-screen save

### Candy lane and load-word sync
#### `candy-loop` (`candy-loop.sh`)
- Persistent ILoveCandy-style animation.
- Reveals static trail text behind moving `C/c`.
- Front candies are white `o` markers.
- Holds at 100% before restarting.
- Writes cycle-wrap counter to `/tmp/polybar-candy-cycle.count`.

#### `load-word` (`load-word.sh`)
- Reads the candy cycle counter.
- Advances word only when candy animation cycle completes.
- So text switches are synchronized with animation completion, not random timer flips.

### Wi-Fi
#### `wifi-label` + `wifi`
- Label `WIFI` is rainbow block.
- Data from `wifi-status.sh`.

`wifi-status.sh` features:
- Interface default: `wlan0` (override via `WIFI_IFACE`).
- SSID/signal fallback chain:
  - `iwgetid`
  - `iw`
  - `nmcli`
  - `iwctl`
  - `/proc/net/wireless`
- Signal bar also uses full `ICONIC!` style:
  - loaded chars colored by strength
  - unloaded chars dark gray
- SSID scrolls with fixed viewport.

## 7) State Files Used (Important for Debugging)

Common runtime state paths in `/tmp`:
- `/tmp/polybar-launch.id`
- `/tmp/polybar-theme.state`
- `/tmp/polybar-flow.state`
- `/tmp/polybar-startup.until`
- `/tmp/polybar-startup.pos`
- `/tmp/polybar-candy-loop.state`
- `/tmp/polybar-candy-cycle.count`
- `/tmp/polybar-loadword-prev.state`
- `/tmp/polybar-wifi-scroll.state`
- `/tmp/polybar-launch.log`

If behavior feels “stuck,” inspecting/removing relevant state files is often enough to reset module behavior.

## 8) Operating Philosophy of This Config

This setup deliberately prioritizes:
- visual identity over minimalism
- animation continuity over dead-static output
- fixed-width rendering to avoid layout jitter
- script-level logic and state for richer behavior than stock modules

In short: it is a scripted Polybar runtime, not just a static INI.

## 9) Suggested Commit Message

`polybar: staged multi-bar setup with themed controls, synchronized candy/load modules, and guided gentoo updater UI`

## 10) Suggested Commit Body

- add boot-first startup bar with completion/hold handoff into main bars
- keep two-row primary layout plus workspace-only side-monitor bars
- implement theme engine + interactive theme selector in kitty
- keep now-playing fixed-width with source tags and marquee behavior
- standardize CPU/RAM/GPU/WiFi to ICONIC full-text bars with gray unloaded chars
- add robust Wi-Fi backend fallbacks including iwctl/iwd paths
- synchronize load-word switching to candy-loop cycle completion
- provide guided gentoo updater UI with per-step disclaimers, strict y/n prompts, random quote injection, and final summary output
