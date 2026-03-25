# gentoo-update.sh

Script path: `~/.config/polybar/scripts/gentoo-update.sh`

## Purpose

Interactive, opt-in Gentoo maintenance runner launched from Polybar click action (`kitty -e ...`).

## Workflow summary

At launch:

1. Prints intro and `emerge --moo`.
2. Asks for optional `sudo -v` auth pre-step.
3. Presents step-by-step maintenance actions.
4. For each step:
   - shows command + explanation + explicit meaning of Yes/No
   - shows random quote before confirmation
   - runs only if user says yes
   - if step fails, shows failing command + asks whether to continue remaining steps
5. Prints summary of what ran/skipped.
6. Prints final quote and `fastfetch --logo lainos --structure logo`.

## Steps covered

- `sudo emerge --sync`
- `sudo emerge -avuDU --with-bdeps=y @world`
- `sudo emerge -av @preserved-rebuild`
- `sudo emerge --depclean -av`
  - includes safety gate if `@world` was skipped
- `sudo dispatch-conf` (fallback `sudo etc-update`)
- `sudo eselect news read`

Before `@world`, script checks if `en_US.UTF-8` exists in `locale -a`.
If missing, it prints exact fix commands and asks if you still want to try `@world`.

## Inputs / Flags

No CLI flags (interactive flow).

## Polybar integration

Triggered by click action on `[module/gentoo-update]` label module.

## Dependencies

- `sudo`, `emerge`, `kitty`
- optional/conditional: `dispatch-conf`, `etc-update`, `eselect`, `fastfetch`
- quote helper: `random-lain-quote.sh`

## Failure behavior

- Script runs in strict mode (`set -euo pipefail`) but core maintenance steps are wrapped with a guarded runner.
- On failure, runner prints:
  - step label
  - exact command
  - exit code
- Then prompts: continue or stop.
- Non-critical cosmetic commands (`emerge --moo`, quote output, fastfetch) are guarded with `|| true`.

## Manual test

```bash
kitty -e ~/.config/polybar/scripts/gentoo-update.sh
# or
~/.config/polybar/scripts/gentoo-update.sh
```
