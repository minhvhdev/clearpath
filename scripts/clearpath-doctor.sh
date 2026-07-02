#!/usr/bin/env bash
set -u
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
PROJECT_DIR="${1:-${CLAUDE_PROJECT_DIR:-$(pwd)}}"
fail=0
warn=0
pass(){ printf 'PASS: %s\n' "$*"; }
warning(){ printf 'WARN: %s\n' "$*"; warn=$((warn+1)); }
err(){ printf 'FAIL: %s\n' "$*"; fail=$((fail+1)); }

[[ -f "$PLUGIN_ROOT/.claude-plugin/plugin.json" ]] && pass "manifest exists" || err "missing .claude-plugin/plugin.json"
[[ ! -f "$PLUGIN_ROOT/plugin.json" ]] && pass "no root plugin.json" || err "root plugin.json should not exist"
[[ -f "$PLUGIN_ROOT/hooks/hooks.json" ]] && pass "hooks/hooks.json exists" || err "missing hooks/hooks.json"
[[ -f "$PLUGIN_ROOT/.mcp.json" ]] && pass ".mcp.json exists" || err "missing .mcp.json"

if command -v jq >/dev/null 2>&1; then
  pass "jq installed"
  jq -e . "$PLUGIN_ROOT/.claude-plugin/plugin.json" >/dev/null && pass "plugin.json parses" || err "plugin.json invalid"
  jq -e . "$PLUGIN_ROOT/hooks/hooks.json" >/dev/null && pass "hooks.json parses" || err "hooks.json invalid"
  jq -e . "$PLUGIN_ROOT/.mcp.json" >/dev/null && pass ".mcp.json parses" || err ".mcp.json invalid"
else
  err "jq missing; hooks fail closed without jq"
fi

command -v git >/dev/null 2>&1 && pass "git installed" || warning "git not found"
command -v node >/dev/null 2>&1 && pass "node installed" || warning "node not found; chrome-devtools MCP via npx may fail"
command -v npx >/dev/null 2>&1 && pass "npx installed" || warning "npx not found; chrome-devtools MCP may fail"
command -v claude >/dev/null 2>&1 && pass "claude CLI installed" || warning "claude CLI not found in this shell; cannot run claude plugin validate here"

# Large-repo adopt-mode escalation (v0.4.3): "do not read the whole
# repo" for large-repo adoption is meaningless if missing Serena /
# Codebase-Memory is only ever a warning. If the target project looks
# like a large adopt-existing-project candidate, missing MCP
# prerequisites become hard failures instead of warnings.
LARGE_ADOPT=0
if [[ -d "$PROJECT_DIR/.git" ]] && command -v git >/dev/null 2>&1; then
  TRACKED_COUNT="$(cd "$PROJECT_DIR" && git ls-files 2>/dev/null | wc -l | tr -d ' ')"
  if [[ "${TRACKED_COUNT:-0}" -ge 200 ]] && [[ ! -e "$PROJECT_DIR/docs/clearpath/BOOT.md" ]] && [[ ! -d "$PROJECT_DIR/.clearpath" ]]; then
    LARGE_ADOPT=1
  fi
fi

if command -v uvx >/dev/null 2>&1; then
  pass "uvx installed"
elif [[ "$LARGE_ADOPT" -eq 1 ]]; then
  err "uvx not found; Serena MCP cannot run and the target project looks like a large (>= 200 tracked files) adopt-existing-project. Large-repo adoption without Serena risks reading the whole repo. Install uvx or explicitly accept limited-mode adoption before proceeding."
else
  warning "uvx not found; Serena MCP may fail"
fi

if command -v codebase-memory-mcp >/dev/null 2>&1; then
  pass "codebase-memory-mcp installed"
elif [[ "$LARGE_ADOPT" -eq 1 ]]; then
  err "codebase-memory-mcp not on PATH and the target project looks like a large (>= 200 tracked files) adopt-existing-project. Install it or explicitly accept limited-mode adoption before proceeding."
else
  warning "codebase-memory-mcp not on PATH; install it before large-repo adoption"
fi

for f in "$PLUGIN_ROOT"/scripts/*.sh "$PLUGIN_ROOT"/bin/*; do
  [[ -f "$f" ]] || continue
  bash -n "$f" && pass "bash syntax ok: ${f#$PLUGIN_ROOT/}" || err "bash syntax failed: ${f#$PLUGIN_ROOT/}"
  [[ -x "$f" ]] && pass "executable: ${f#$PLUGIN_ROOT/}" || err "not executable: ${f#$PLUGIN_ROOT/}"
done

if [[ -x "$PLUGIN_ROOT/tests/hook-smoke-test.sh" ]]; then
  "$PLUGIN_ROOT/tests/hook-smoke-test.sh" >/tmp/clearpath_hook_smoke.$$ 2>&1 && pass "hook smoke tests pass" || { err "hook smoke tests failed"; cat /tmp/clearpath_hook_smoke.$$; }
  rm -f /tmp/clearpath_hook_smoke.$$ || true
else
  err "missing executable tests/hook-smoke-test.sh"
fi

if [[ -d "$PROJECT_DIR/docs/clearpath" ]]; then
  "$PLUGIN_ROOT/scripts/artifact-lint.sh" "$PROJECT_DIR" >/tmp/clearpath_artifact_lint.$$ 2>&1 && pass "artifact lint pass for project" || warning "artifact lint has findings for project; run scripts/artifact-lint.sh"
  rm -f /tmp/clearpath_artifact_lint.$$ || true
fi

printf '\nClearpath doctor completed with %d failure(s), %d warning(s).\n' "$fail" "$warn"
exit "$fail"
