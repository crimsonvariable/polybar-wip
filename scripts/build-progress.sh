#!/usr/bin/env bash

set -u

STATE_FILE="/tmp/polybar-build-progress.state"

fmt_pct() {
  local n="$1"
  printf "%03d%%" "$n"
}

get_emerge_fetch_status() {
  local line pct eta
  [[ -r /var/log/emerge-fetch.log ]] || return 1

  line="$(tail -n 600 /var/log/emerge-fetch.log 2>/dev/null | tr '\r' '\n' | grep -aE '[0-9]{1,3}%.*([0-9]+[smhd]|[0-9]+:[0-9]{2})' | tail -n 1 || true)"
  [[ -n "$line" ]] || return 1

  if [[ "$line" =~ ([0-9]{1,3})% ]]; then
    pct="${BASH_REMATCH[1]}"
  else
    return 1
  fi

  if [[ "$line" =~ ([0-9]+:[0-9]{2}|[0-9]+[smhd])[[:space:]]*$ ]]; then
    eta="${BASH_REMATCH[1]}"
  else
    return 1
  fi

  printf '%03d%% %s' "$pct" "$eta"
}

get_emerge_progress() {
  local log line done total
  for log in /var/log/emerge.log /var/log/portage/emerge.log /var/tmp/portage/.emerge.log; do
    [[ -r "$log" ]] || continue
    line="$(tail -n 1200 "$log" 2>/dev/null | grep -aE 'completed emerge \([0-9]+[[:space:]]+of[[:space:]]+[0-9]+\)|\([0-9]+[[:space:]]+of[[:space:]]+[0-9]+\)|\[[0-9]+/[0-9]+\]|[[:space:]][0-9]+/[0-9]+[[:space:]]' | tail -n 1 || true)"
    [[ -n "$line" ]] || continue

    done=""
    total=""

    if [[ "$line" =~ \(([0-9]+)[[:space:]]+of[[:space:]]+([0-9]+)\) ]]; then
      done="${BASH_REMATCH[1]}"
      total="${BASH_REMATCH[2]}"
    elif [[ "$line" =~ \[([0-9]+)\/([0-9]+)\] ]]; then
      done="${BASH_REMATCH[1]}"
      total="${BASH_REMATCH[2]}"
    elif [[ "$line" =~ (^|[^0-9])([0-9]+)\/([0-9]+)([^0-9]|$) ]]; then
      done="${BASH_REMATCH[2]}"
      total="${BASH_REMATCH[3]}"
    fi

    if [[ "$done" =~ ^[0-9]+$ && "$total" =~ ^[0-9]+$ && "$total" -gt 0 ]]; then
      printf '%s %s' "$done" "$total"
      return 0
    fi
  done

  return 1
}

emit_status() {
  local now percent active updated age done total fetch_mtime fetch_status
  now="$(date +%s)"

  # Fallback: show emerge activity even when not using --ingest wrapper.
  if pgrep -fa "(^|/)emerge($|[[:space:]])|(^|/)emerge.real($|[[:space:]])" >/dev/null 2>&1; then
    # During distfile fetch, progress counters may be absent from emerge.log.
    if [[ -r /var/log/emerge-fetch.log ]]; then
      fetch_mtime="$(stat -c %Y /var/log/emerge-fetch.log 2>/dev/null || echo 0)"
      if [[ "$fetch_mtime" =~ ^[0-9]+$ ]] && (( now - fetch_mtime < 20 )); then
        if fetch_status="$(get_emerge_fetch_status)"; then
          echo "$fetch_status"
        else
          echo "fetch"
        fi
        return
      fi
    fi

    if read -r done total < <(get_emerge_progress); then
      if [[ "$total" =~ ^[0-9]+$ && "$total" -gt 1 && "$done" =~ ^[0-9]+$ ]]; then
        percent=$((done * 100 / total))
        (( percent < 0 )) && percent=0
        (( percent > 100 )) && percent=100
        echo "emerge $(fmt_pct "$percent")"
      else
        echo "emerge"
      fi
    else
      echo "emerge"
    fi
    return
  fi

  if [[ ! -f "$STATE_FILE" ]]; then
    echo "idle"
    return
  fi

  IFS='|' read -r percent active updated < "$STATE_FILE"
  percent="${percent:-0}"
  active="${active:-0}"
  updated="${updated:-0}"

  if [[ "$updated" =~ ^[0-9]+$ ]]; then
    age=$((now - updated))
  else
    age=9999
  fi

  if [[ "$active" == "1" && "$age" -lt 30 ]]; then
    echo "$(fmt_pct "$percent")"
    return
  fi

  if [[ "$percent" == "100" && "$age" -lt 20 ]]; then
    echo "done"
    return
  fi

  echo "idle"
}

write_state() {
  local percent active
  percent="$1"
  active="$2"
  printf '%s|%s|%s\n' "$percent" "$active" "$(date +%s)" > "$STATE_FILE"
}

ingest_stream() {
  local line done total percent
  while IFS= read -r line; do
    if [[ "$line" =~ \[([0-9]+)\/([0-9]+)\] ]]; then
      done="${BASH_REMATCH[1]}"
      total="${BASH_REMATCH[2]}"
      if [[ "$total" -gt 0 ]]; then
        percent=$((done * 100 / total))
        write_state "$percent" 1
      fi
    elif [[ "$line" =~ ([0-9]{1,3})% ]]; then
      percent="${BASH_REMATCH[1]}"
      if [[ "$percent" -le 100 ]]; then
        write_state "$percent" 1
      fi
    fi

    printf '%s\n' "$line"
  done

  if [[ -f "$STATE_FILE" ]]; then
    IFS='|' read -r percent _ _ < "$STATE_FILE"
    if [[ "${percent:-0}" -ge 100 ]]; then
      write_state 100 0
    else
      write_state "${percent:-0}" 0
    fi
  else
    write_state 0 0
  fi
}

case "${1:-}" in
  --ingest)
    ingest_stream
    ;;
  --reset)
    rm -f "$STATE_FILE"
    ;;
  *)
    emit_status
    ;;
esac
