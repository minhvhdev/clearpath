#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR="${1:-${CLAUDE_PROJECT_DIR:-$(pwd)}}"
fail=0
msg() { printf '%s\n' "$*"; }
err() { printf 'FAIL: %s\n' "$*"; fail=1; }
pass() { printf 'PASS: %s\n' "$*"; }

check_file() { [[ -f "$PROJECT_DIR/$1" ]] && pass "$1 exists" || err "$1 missing"; }
check_max_lines() {
  local rel="$1" max="$2"
  if [[ -f "$PROJECT_DIR/$rel" ]]; then
    local n
    n=$(wc -l < "$PROJECT_DIR/$rel" | tr -d ' ')
    if (( n <= max )); then pass "$rel <= $max lines ($n)"; else err "$rel exceeds $max lines ($n)"; fi
  fi
}

check_file docs/clearpath/BOOT.md
check_file docs/clearpath/CURRENT_CONTEXT.md
check_file docs/clearpath/STATE.md
check_file docs/clearpath/ARTIFACT_INDEX.json
check_max_lines docs/clearpath/BOOT.md 200
check_max_lines docs/clearpath/CURRENT_CONTEXT.md 300

if command -v jq >/dev/null 2>&1 && [[ -f "$PROJECT_DIR/docs/clearpath/ARTIFACT_INDEX.json" ]]; then
  jq -e . "$PROJECT_DIR/docs/clearpath/ARTIFACT_INDEX.json" >/dev/null && pass "ARTIFACT_INDEX.json parses" || err "ARTIFACT_INDEX.json invalid"
fi

if [[ -d "$PROJECT_DIR/docs/changes" ]]; then
  while IFS= read -r -d '' dir; do
    [[ -f "$dir/CHANGE_INDEX.md" ]] || err "$(realpath --relative-to="$PROJECT_DIR" "$dir") missing CHANGE_INDEX.md"
  done < <(find "$PROJECT_DIR/docs/changes" -mindepth 1 -maxdepth 1 -type d -print0)
fi

if grep -R --include='*.md' -nE '```(ts|tsx|js|jsx|py|go|rs|java|cs|php|rb)' "$PROJECT_DIR/docs/clearpath" "$PROJECT_DIR/docs/changes" >/tmp/clearpath_artifact_lint_code.$$ 2>/dev/null; then
  err "Artifacts contain code blocks; ensure they summarize and link instead of duplicating source. See /tmp/clearpath_artifact_lint_code.$$"
else
  rm -f /tmp/clearpath_artifact_lint_code.$$ || true
  pass "No obvious source-code duplication in artifacts"
fi

exit "$fail"
