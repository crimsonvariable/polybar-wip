# Polybar Documentation Index

This folder is the source-of-truth for your Polybar setup.

## What this folder contains

- `POLYBAR_OVERVIEW.md`
  - Big-picture architecture and behavior overview.
- `PROJECT_NOTICE.md`
  - Authorship, scope, support model, and collaboration expectations.
- `REPO_NOTICE_TEMPLATE.md`
  - Reusable default disclaimer text for future repositories.
- `ENVIRONMENT.md`
  - OS/session/toolchain context and assumptions for debugging.
- `BACKUPS.md`
  - Snapshot workflow and handoff phrase for future Codex sessions.
- `FRESH_GENTOO_INSTALL.md`
  - Step-by-step apply guide for a fresh Gentoo system.
- `DEPENDENCIES.md`
  - Runtime dependencies, optional tools, and fallback behavior.
- `SUPPORT.md`
  - Troubleshooting and support runbook.
- `scripts/*.md`
  - One page per script with flags, outputs, state files, and module wiring.

## Fast navigation

- Core visual/theming engine:
  - `scripts/dynamic-rainbow.md`
  - `scripts/theme-switch.md`
- Startup animation lifecycle:
  - `scripts/startup-load.md`
  - `scripts/candy-loop.md`
  - `scripts/load-word.md`
- Status modules:
  - `scripts/cpu-status.md`
  - `scripts/memory-status.md`
  - `scripts/gpu-status.md`
  - `scripts/volume-status.md`
  - `scripts/wifi-status.md`
  - `scripts/now-playing.md`
  - `scripts/build-progress.md`
  - `scripts/ws-list.md`
- Interactive workflows:
  - `scripts/gentoo-update.md`
  - `scripts/build-run.md`
  - `scripts/snapshot-backup.md`
  - `scripts/install-gentoo.md`
- Quote/text helpers:
  - `scripts/random-lain-quote.md`
  - `scripts/rainbow-text.md`

## Editing conventions

When adding new scripts, add a matching `scripts/<name>.md` using this minimal structure:

1. Purpose
2. Inputs / Flags
3. Output format
4. State files
5. Polybar module integration
6. Dependencies and fallback behavior
7. Manual test commands

This keeps docs understandable for you, future collaborators, and future Codex sessions.
