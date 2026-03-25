#!/usr/bin/env bash

set -euo pipefail

did_sync=0
did_world=0
did_preserved=0
did_depclean=0
did_config=0
did_news=0

confirm() {
  local prompt="$1"
  local reply
  while true; do
    read -r -p "$prompt [y/n]: " reply
    case "$reply" in
      y|Y) return 0 ;;
      n|N) return 1 ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}

has_en_us_utf8_locale() {
  locale -a 2>/dev/null | tr '[:upper:]' '[:lower:]' | grep -Eq '^en_us\.utf-?8$'
}

print_locale_fix_instructions() {
  cat <<'EOF'
[WARN] Missing required locale: en_US.UTF-8
One of your packages (app-shells/pwsh) requires this locale in pkg_pretend.

Fix once, then rerun updater:
  sudo sh -c "grep -q '^en_US.UTF-8 UTF-8$' /etc/locale.gen || echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen"
  sudo locale-gen
  sudo eselect locale list
  sudo eselect locale set <number-for-en_US.utf8>
  sudo env-update
  source /etc/profile
EOF
}

ask_with_quote() {
  local prompt="$1"
  printf '\n'
  ~/.config/polybar/scripts/quote-random.sh || true
  printf '\n'
  confirm "$prompt"
}

run_or_continue() {
  local label="$1"
  shift
  local rc

  set +e
  "$@"
  rc=$?
  set -e

  if [[ "$rc" -eq 0 ]]; then
    return 0
  fi

  printf '\n[ERROR] %s failed (exit %s)\n' "$label" "$rc"
  printf '  Command: %s\n' "$*"
  if confirm "Continue with remaining steps?"; then
    return 1
  fi

  echo "Stopping updater by request."
  exit "$rc"
}

step() {
  printf '\n==> %s\n' "$1"
}

disclaimer() {
  local title="$1"
  local cmd="$2"
  local what_it_does="$3"
  local yes_meaning="$4"
  local no_meaning="$5"
  printf '\n%s\n' "$title"
  printf '  COMMAND : %s\n' "$cmd"
  printf '  EFFECT  : %s\n' "$what_it_does"
  printf '  YES: %s\n' "$yes_meaning"
  printf '  NO : %s\n' "$no_meaning"
}

printf 'Gentoo Update (Opt-in per step)\n'
printf 'You choose each step manually. No means skip and continue when safe.\n'
printf 'Commands run with sudo only when you approve that step.\n\n'
emerge --moo || true
printf '\n'

step "Sudo auth"
if ask_with_quote "Authenticate sudo now?"; then
  run_or_continue "sudo auth" sudo -v || true
else
  echo "Skipped sudo auth now (you may be prompted later when running chosen steps)."
fi

disclaimer \
  "Step 1: Sync tree" \
  "sudo emerge --sync" \
  "Updates local Portage repository metadata (available package versions/ebuilds)." \
  "Runs sync now, so later upgrade decisions are based on fresh repository state." \
  "Skips sync and continues. Usually safe, but version data may be stale."
if ask_with_quote "Run sync step?"; then
  step "Syncing tree"
  if run_or_continue "sync tree" sudo emerge --sync; then
    did_sync=1
  fi
fi

disclaimer \
  "Step 2: Update @world" \
  "sudo emerge -avuDU --with-bdeps=y @world" \
  "Calculates and applies system/user package upgrades with deep dependency + USE-flag changes." \
  "Runs full @world upgrade flow and prompts you to review proposed changes." \
  "Skips world update and continues. Safe, but no upgrades are applied."
if ask_with_quote "Run @world update step?"; then
  if ! has_en_us_utf8_locale; then
    print_locale_fix_instructions
    if ! confirm "Locale is missing. Try @world anyway?"; then
      echo "Skipped @world for now. Fix locale and rerun when ready."
    else
      step "Updating @world"
      if run_or_continue "@world update" sudo emerge -avuDU --with-bdeps=y @world; then
        did_world=1
      fi
    fi
  else
    step "Updating @world"
    if run_or_continue "@world update" sudo emerge -avuDU --with-bdeps=y @world; then
      did_world=1
    fi
  fi
fi

disclaimer \
  "Step 3: preserved-rebuild" \
  "sudo emerge -av @preserved-rebuild" \
  "Rebuilds packages linked to preserved old libraries after upgrades." \
  "Runs preserved-rebuild now to reduce breakage from old library links." \
  "Skips and continues. Often safe short-term; can be run later."
if ask_with_quote "Run preserved-rebuild step?"; then
  step "Running preserved-rebuild"
  if run_or_continue "preserved-rebuild" sudo emerge -av @preserved-rebuild; then
    did_preserved=1
  fi
fi

disclaimer \
  "Step 4: depclean" \
  "sudo emerge --depclean -av" \
  "Removes packages no longer needed by dependency graph (orphan cleanup)." \
  "Runs depclean now (with review prompt) to remove unneeded packages." \
  "Skips and continues. Safe; no packages removed."
if ask_with_quote "Run depclean step?"; then
  if [[ "$did_world" -eq 0 ]]; then
    echo "Safety gate: @world was skipped. Depclean right now may be risky."
    if ask_with_quote "Force depclean anyway?"; then
      step "Running depclean (forced)"
      if run_or_continue "depclean (forced)" sudo emerge --depclean -av; then
        did_depclean=1
      fi
    else
      echo "Depclean skipped for safety."
    fi
  else
    step "Running depclean"
    if run_or_continue "depclean" sudo emerge --depclean -av; then
      did_depclean=1
    fi
  fi
fi

disclaimer \
  "Step 5: merge config updates" \
  "sudo dispatch-conf  (fallback: sudo etc-update)" \
  "Opens interactive merge for updated config files in /etc." \
  "Starts config merge now so service/package config changes can be reconciled immediately." \
  "Skips and continues. Safe, but config updates remain pending."
if ask_with_quote "Run config merge step now?"; then
  step "Merging config updates"
  if command -v dispatch-conf >/dev/null 2>&1; then
    if run_or_continue "dispatch-conf" sudo dispatch-conf; then
      did_config=1
    fi
  else
    if run_or_continue "etc-update" sudo etc-update; then
      did_config=1
    fi
  fi
fi

disclaimer \
  "Step 6: read Gentoo news" \
  "sudo eselect news read" \
  "Shows pending Gentoo news items (important migration/maintenance notices)." \
  "Reads news now so you can catch required manual actions." \
  "Skips and finishes. Safe, but you may miss important notices."
if ask_with_quote "Read Gentoo news now?"; then
  step "Reading Gentoo news"
  if run_or_continue "eselect news read" sudo eselect news read; then
    did_news=1
  fi
fi

printf '\nSummary\n'
printf '  sync:             %s\n' "$( [[ $did_sync -eq 1 ]] && echo ran || echo skipped )"
printf '  @world:           %s\n' "$( [[ $did_world -eq 1 ]] && echo ran || echo skipped )"
printf '  preserved-rebuild:%s\n' "$( [[ $did_preserved -eq 1 ]] && echo ran || echo skipped )"
printf '  depclean:         %s\n' "$( [[ $did_depclean -eq 1 ]] && echo ran || echo skipped )"
printf '  config merge:     %s\n' "$( [[ $did_config -eq 1 ]] && echo ran || echo skipped )"
printf '  news:             %s\n' "$( [[ $did_news -eq 1 ]] && echo ran || echo skipped )"

printf '\n'
~/.config/polybar/scripts/quote-random.sh || true

printf '\n'
fastfetch --logo lainos --structure logo || true

printf '\nDone. Press Enter to close...'
read -r _
