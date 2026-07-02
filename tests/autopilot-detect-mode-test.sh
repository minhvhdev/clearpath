#!/usr/bin/env bash
# autopilot-detect-mode-test.sh
# Verifies the project mode detector across the documented scenarios.
# Also smoke-checks the SessionStart and UserPromptSubmit autopilot
# scripts produce routing context.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DETECT="$ROOT/scripts/clearpath-detect-mode.sh"
SESSION="$ROOT/scripts/session-start-autopilot.sh"
PROMPT_HOOK="$ROOT/scripts/user-prompt-autopilot.sh"

if ! command -v jq >/dev/null 2>&1; then
  echo "SKIP: jq is required for autopilot-detect-mode-test.sh" >&2
  exit 0
fi

# Each test gets its own temp dir.
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

assert_mode() {
  local label="$1" expected="$2" dir="$3"
  local actual
  actual="$(CLAUDE_PROJECT_DIR="$dir" "$DETECT" --format json | jq -r '.detected_mode // "?"')"
  if [[ "$actual" == "$expected" ]]; then
    echo "PASS: $label (mode=$actual)"
  else
    echo "FAIL: $label expected mode=$expected got mode=$actual" >&2
    CLAUDE_PROJECT_DIR="$dir" "$DETECT" --format json >&2
    exit 1
  fi
}

# 1. Empty directory -> new-empty-project.
EMPTY="$WORK/empty"
mkdir -p "$EMPTY"
assert_mode "empty dir -> new-empty-project" "new-empty-project" "$EMPTY"

# 2. Scaffolded: package.json but no source, no Clearpath.
SCAF="$WORK/scaffolded"
mkdir -p "$SCAF"
cat > "$SCAF/package.json" <<'JSON'
{"name":"x","version":"0.0.0"}
JSON
assert_mode "scaffolded (manifest only) -> new-scaffolded-project" "new-scaffolded-project" "$SCAF"

# 3. Clearpath project: docs/clearpath/BOOT.md exists.
CLP="$WORK/clearpath-proj"
mkdir -p "$CLP/docs/clearpath"
echo "# boot" > "$CLP/docs/clearpath/BOOT.md"
assert_mode "Clearpath project -> existing-clearpath-project" "existing-clearpath-project" "$CLP"

# 4. Adopt-existing: real git repo with src and tracked files.
ADOPT="$WORK/adopt"
mkdir -p "$ADOPT/src"
cat > "$ADOPT/package.json" <<'JSON'
{"name":"adopt-demo","version":"0.1.0"}
JSON
(cd "$ADOPT" && git init -q && git -c user.email=t@t -c user.name=t add -A && git -c user.email=t@t -c user.name=t commit -q -m "init")
mkdir -p "$ADOPT/src/app"
echo "export const App = () => null" > "$ADOPT/src/app/index.tsx"
(cd "$ADOPT" && git -c user.email=t@t -c user.name=t add -A && git -c user.email=t@t -c user.name=t commit -q -m "add")
assert_mode "adopt-existing project -> adopt-existing-project" "adopt-existing-project" "$ADOPT"

# 5. SessionStart hook emits routing context without writing files.
CLAUDE_PROJECT_DIR="$EMPTY" SESS_OUT="$("$SESSION")"
if grep -q "CLEARPATH_AUTOPILOT: active" <<< "$SESS_OUT" && grep -q "CLEARPATH_AUTOPILOT_MODE:" <<< "$SESS_OUT"; then
  echo "PASS: session-start-autopilot emits autopilot context"
else
  echo "FAIL: session-start-autopilot did not emit expected context" >&2
  printf '%s\n' "$SESS_OUT" >&2
  exit 1
fi
# Must not have created files in the project dir.
if [[ -n "$(find "$EMPTY" -mindepth 1 -maxdepth 1 2>/dev/null)" ]]; then
  echo "FAIL: session-start-autopilot wrote files into project dir" >&2
  exit 1
else
  echo "PASS: session-start-autopilot did not write project files"
fi

# 6. UserPromptSubmit classifies a build request and injects context.
PROMPT_INPUT='{"user_prompt":"Build me a SaaS landing page for analytics"}'
PROMPT_OUT="$(printf '%s' "$PROMPT_INPUT" | CLAUDE_PROJECT_DIR="$ADOPT" "$PROMPT_HOOK")"
INTENT_HIT="$(grep -c "CLEARPATH_AUTOPILOT_PROMPT_INTENT: build-new-product" <<< "$PROMPT_OUT" || true)"
ROUTE_HIT="$(grep -c "CLEARPATH_AUTOPILOT_INTERNAL_ROUTE: /clearpath:adopt" <<< "$PROMPT_OUT" || true)"
if [[ "$INTENT_HIT" -ge 1 && "$ROUTE_HIT" -ge 1 ]]; then
  echo "PASS: user-prompt-autopilot classifies build request and routes correctly"
else
  echo "FAIL: user-prompt-autopilot did not classify or route correctly" >&2
  echo "intent_hit=$INTENT_HIT route_hit=$ROUTE_HIT" >&2
  printf '%s\n' "$PROMPT_OUT" | head -10 >&2
  exit 1
fi

# 7. Unrelated prompt is short and does not inject routing noise.
UNRELATED_INPUT='{"user_prompt":"hello there"}'
UNRELATED_OUT="$(printf '%s' "$UNRELATED_INPUT" | CLAUDE_PROJECT_DIR="$ADOPT" "$PROMPT_HOOK")"
if grep -q "CLEARPATH_AUTOPILOT_PROMPT_INTENT: unrelated" <<< "$UNRELATED_OUT" \
   && ! grep -q "CLEARPATH_AUTOPILOT_ROUTING:" <<< "$UNRELATED_OUT"; then
  echo "PASS: user-prompt-autopilot keeps unrelated prompts short"
else
  echo "FAIL: user-prompt-autopilot injected routing for unrelated prompt" >&2
  printf '%s\n' "$UNRELATED_OUT" >&2
  exit 1
fi

echo "OK: autopilot-detect-mode-test passed all cases"
exit 0
