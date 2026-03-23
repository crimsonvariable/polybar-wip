# build-run.sh

Script path: `~/.config/polybar/scripts/build-run.sh`

## Purpose

Wrapper that runs an arbitrary build command and pipes output to `build-progress.sh --ingest` so Polybar can track progress from stdout/stderr patterns.

## Inputs / Flags

- positional command required: `build-run.sh <build command...>`

No extra flags.

## Output behavior

- Forwards wrapped command output to terminal.
- Updates `/tmp/polybar-build-progress.state` via ingest parser.
- Exits with the wrapped command's exit code.

## Polybar integration

Indirect helper for `[module/build-percent]`.

## Example

```bash
~/.config/polybar/scripts/build-run.sh emerge -avuDN @world
~/.config/polybar/scripts/build-run.sh ninja -C build
```
