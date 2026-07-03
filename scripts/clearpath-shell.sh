#!/usr/bin/env bash
# Shared bash helpers for Clearpath shell scripts (Git Bash / MSYS on Windows).

# jq on Windows often emits CRLF; without stripping, `command -v "jq\r"` fails.
strip_cr() {
  printf '%s' "${1//$'\r'/}"
}

# Some Windows hook launchers attach a non-TTY stdin handle that never
# reaches EOF. Read stdin only when data is immediately available.
read_optional_stdin() {
  if [[ -t 0 ]]; then
    return 1
  fi
  if ! IFS= read -r -t 0 -n 0; then
    return 1
  fi
  cat 2>/dev/null || true
}
