#!/usr/bin/env bash
set -u
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
PROJECT_DIR="${1:-${CLAUDE_PROJECT_DIR:-$(pwd)}}"
REQ="$PLUGIN_ROOT/scripts/clearpath-requirements.json"
HOME_DIR="${HOME:-$(cd ~ && pwd)}"
fail=0
warn=0
missing_required=0
pass(){ printf 'PASS: %s\n' "$*"; }
warning(){ printf 'WARN: %s\n' "$*"; warn=$((warn+1)); }
err(){ printf 'FAIL: %s\n' "$*"; fail=$((fail+1)); }
note_missing(){ printf 'MISSING: %s\n' "$*"; missing_required=$((missing_required+1)); }
# shellcheck source=clearpath-shell.sh
source "$(dirname "${BASH_SOURCE[0]}")/clearpath-shell.sh"
# shellcheck source=clearpath-python.sh
source "$PLUGIN_ROOT/scripts/clearpath-python.sh"

expand_home() {
  local p="$1"
  if [[ "$p" == "~/"* ]]; then
    printf '%s/%s' "$HOME_DIR" "${p#~/}"
  elif [[ "$p" == ./* ]]; then
    printf '%s/%s' "$HOME_DIR" "${p#./}"
  else
    printf '%s/%s' "$HOME_DIR" "$p"
  fi
}

[[ -f "$PLUGIN_ROOT/.claude-plugin/plugin.json" ]] && pass "manifest exists" || err "missing .claude-plugin/plugin.json"
[[ ! -f "$PLUGIN_ROOT/plugin.json" ]] && pass "no root plugin.json" || err "root plugin.json should not exist"
[[ -f "$PLUGIN_ROOT/hooks/hooks.json" ]] && pass "hooks/hooks.json exists" || err "missing hooks/hooks.json"
[[ -f "$PLUGIN_ROOT/.mcp.json" ]] && pass ".mcp.json exists" || err "missing .mcp.json"
[[ -f "$REQ" ]] && pass "requirements manifest exists" || err "missing scripts/clearpath-requirements.json"

if command -v jq >/dev/null 2>&1; then
  pass "jq installed"
  jq -e . "$PLUGIN_ROOT/.claude-plugin/plugin.json" >/dev/null && pass "plugin.json parses" || err "plugin.json invalid"
  jq -e . "$PLUGIN_ROOT/hooks/hooks.json" >/dev/null && pass "hooks.json parses" || err "hooks.json invalid"
  jq -e . "$PLUGIN_ROOT/.mcp.json" >/dev/null && pass ".mcp.json parses" || err ".mcp.json invalid"
  jq -e . "$REQ" >/dev/null && pass "requirements.json parses" || err "requirements.json invalid"
else
  err "jq missing (required)"
  note_missing "cli:jq"
fi

if [[ -f "$REQ" ]] && command -v jq >/dev/null 2>&1; then
  while IFS= read -r line; do
    line="$(strip_cr "$line")"
    id="${line%%|*}"
    cmd="${line#*|}"
    if command -v "$cmd" >/dev/null 2>&1; then
      pass "cli $id available ($cmd)"
    else
      hint="$(strip_cr "$(jq -r --arg id "$id" '.cli[] | select(.id==$id) | .install_hint' "$REQ")")"
      err "required cli missing: $id ($cmd)"
      note_missing "cli:$id|$hint"
    fi
  done < <(jq -r '.cli[] | select(.required==true) | "\(.id)|\(.command)"' "$REQ")

  while IFS= read -r skill; do
    skill="$(strip_cr "$skill")"
    [[ -z "$skill" ]] && continue
    found=0
    marker="$(strip_cr "$(jq -r --arg id "$skill" '.skills[] | select(.id==$id) | .marker_file' "$REQ")")"
    while IFS= read -r d; do
      d="$(strip_cr "$d")"
      [[ -z "$d" ]] && continue
      if [[ -f "$(expand_home "$d")/$marker" ]]; then
        found=1
        break
      fi
    done < <(jq -r --arg id "$skill" '.skills[] | select(.id==$id) | .user_scope_dirs[]' "$REQ")
    if [[ "$found" -eq 1 ]]; then
      pass "user-scope skill present: $skill"
    else
      purpose="$(strip_cr "$(jq -r --arg id "$skill" '.skills[] | select(.id==$id) | .purpose' "$REQ")")"
      err "required user-scope skill missing: $skill"
      note_missing "skill:$skill|$purpose"
    fi
  done < <(jq -r '.skills[] | select(.required==true) | .id' "$REQ")

  mcp_user_ok=1
  while IFS= read -r mcp; do
    mcp="$(strip_cr "$mcp")"
    [[ -z "$mcp" ]] && continue
    present=0
    while IFS= read -r rel; do
      rel="$(strip_cr "$rel")"
      [[ -z "$rel" ]] && continue
      path="$(expand_home "$rel")"
      [[ -f "$path" ]] || continue
      if jq -e --arg id "$mcp" '.mcpServers[$id] // empty' "$path" >/dev/null 2>&1; then
        present=1
        break
      fi
    done < <(jq -r '.user_mcp_settings_paths[]' "$REQ")
    if [[ "$present" -eq 1 ]]; then
      pass "user-scope MCP configured: $mcp"
    elif jq -e --arg id "$mcp" '.mcpServers[$id] // empty' "$PLUGIN_ROOT/.mcp.json" >/dev/null 2>&1; then
      pass "MCP configured via plugin manifest: $mcp"
    else
      err "required MCP missing from plugin manifest: $mcp"
      note_missing "mcp:$mcp|missing in plugin .mcp.json"
      mcp_user_ok=0
    fi
  done < <(jq -r '.mcp_servers[] | select(.required==true) | .id' "$REQ")
  [[ "$mcp_user_ok" -eq 1 ]] && pass "all required MCP servers present (user scope or plugin manifest)"
fi

clearpath_python_print_diagnostics
if clearpath_find_python; then
  pass "Python runtime usable: $CLEARPATH_PYTHON_LABEL ($CLEARPATH_PYTHON_VERSION)"
else
  err "Python runtime missing or unusable"
  clearpath_python_not_found_message
fi

PROJECT_INITIALIZED=1
MISSING_ARTIFACTS=()
for rel in .clearpath/docs/BOOT.md .clearpath/docs/CURRENT_CONTEXT.md .clearpath/docs/STATE.md .clearpath/docs/ARTIFACT_INDEX.json; do
  if [[ ! -f "$PROJECT_DIR/$rel" ]]; then
    PROJECT_INITIALIZED=0
    MISSING_ARTIFACTS+=("$rel")
  fi
done

if [[ "$PROJECT_INITIALIZED" -eq 1 ]]; then
  pass "Project initialization: INITIALIZED"
else
  printf '\nProject initialization: NOT INITIALIZED\n'
  for rel in "${MISSING_ARTIFACTS[@]}"; do
    printf '%s\n' "$rel missing"
  done
  printf '%s\n' 'Next step: run /clearpath:init'
fi

for f in "$PLUGIN_ROOT"/scripts/*.sh "$PLUGIN_ROOT"/bin/*; do
  [[ -f "$f" ]] || continue
  bash -n "$f" && pass "bash syntax ok: ${f#$PLUGIN_ROOT/}" || err "bash syntax failed: ${f#$PLUGIN_ROOT/}"
  [[ -x "$f" ]] && pass "executable: ${f#$PLUGIN_ROOT/}" || err "not executable: ${f#$PLUGIN_ROOT/}"
done

if [[ -x "$PLUGIN_ROOT/tests/hook-smoke-test.sh" ]]; then
  hook_log="${TMPDIR:-/tmp}/clearpath_hook_smoke.$$"
  "$PLUGIN_ROOT/tests/hook-smoke-test.sh" >"$hook_log" 2>&1 && pass "hook smoke tests pass" || { err "hook smoke tests failed"; cat "$hook_log"; }
  rm -f "$hook_log" || true
else
  err "missing executable tests/hook-smoke-test.sh"
fi

if [[ "$PROJECT_INITIALIZED" -eq 1 ]]; then
  lint_log="${TMPDIR:-/tmp}/clearpath_artifact_lint.$$"
  "$PLUGIN_ROOT/scripts/artifact-lint.sh" "$PROJECT_DIR" >"$lint_log" 2>&1 && pass "artifact lint pass for project" || warning "artifact lint has findings for project; run scripts/artifact-lint.sh"
  rm -f "$lint_log" || true
fi

printf '\nClearpath doctor completed with %d failure(s), %d warning(s).\n' "$fail" "$warn"

if [[ "$missing_required" -gt 0 ]]; then
  printf '\nCLEARPATH_DOCTOR_NEEDS_USER_APPROVAL: true\n'
  printf 'CLEARPATH_DOCTOR_MISSING_COUNT: %d\n' "$missing_required"
  printf 'CLEARPATH_DOCTOR_INSTALL_HINT: Ask the user for permission, then run:\n'
  printf '  CLEARPATH_DOCTOR_INSTALL_APPROVED=1 clearpath-doctor-install\n'
  printf 'Or invoke /clearpath:doctor and let the agent run that command after approval.\n'
fi

exit "$fail"
