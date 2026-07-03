#!/usr/bin/env bash
# Shared bash helpers for Clearpath shell scripts (Git Bash / MSYS on Windows).

# jq on Windows often emits CRLF; without stripping, `command -v "jq\r"` fails.
strip_cr() {
  printf '%s' "${1//$'\r'/}"
}
