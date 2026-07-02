#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="${TMPDIR:-/tmp}/clearpath-hook-smoke-$$"
mkdir -p "$TMP"
export CLAUDE_PROJECT_DIR="$TMP"
mkdir -p "$TMP/.clearpath/docs"
trap 'rm -rf "$TMP"' EXIT

session="$ROOT/scripts/session-start-autopilot.sh"
prompt="$ROOT/scripts/user-prompt-autopilot.sh"

run_hook() {
  local hook="$1" input="$2"
  if [[ -n "$input" ]]; then
    printf '%s' "$input" | bash "$hook"
  else
    bash "$hook"
  fi
}

expect_contains() {
  local label="$1" haystack="$2" needle="$3"
  if grep -Fq "$needle" <<< "$haystack"; then
    echo "PASS: $label"
  else
    echo "FAIL: $label expected to contain: $needle" >&2
    echo "$haystack" >&2
    exit 1
  fi
}

out="$(run_hook "$session" "")"
expect_contains "session-start marks autopilot active" "$out" "CLEARPATH_AUTOPILOT: active"
expect_contains "session-start recommends /clearpath:go" "$out" "/clearpath:go"

out="$(run_hook "$prompt" '{"user_prompt":"approve the design"}')"
expect_contains "prompt hook detects approve intent" "$out" "design-approved-continue"

out="$(run_hook "$prompt" '{"user_prompt":"Build me a SaaS landing page"}')"
expect_contains "prompt hook detects build-new-product" "$out" "build-new-product"

if [[ -f "$ROOT/hooks/hooks.json" ]] && command -v jq >/dev/null 2>&1; then
  if jq -e '.hooks.PreToolUse' "$ROOT/hooks/hooks.json" >/dev/null 2>&1; then
    echo "FAIL: hooks.json still defines PreToolUse gate hooks" >&2
    exit 1
  fi
  echo "PASS: hooks.json has no PreToolUse gate hooks"
fi

echo "PASS: hook smoke test"
