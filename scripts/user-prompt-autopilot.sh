#!/usr/bin/env bash
# user-prompt-autopilot.sh
# UserPromptSubmit hook. Inspects the user's prompt and injects
# Clearpath Autopilot routing context. Read-only. Does not create
# files and does not block normal prompts.
set -u

# shellcheck source=clearpath-shell.sh
source "$(dirname "${BASH_SOURCE[0]}")/clearpath-shell.sh"

INPUT="$(read_optional_stdin || true)"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${CURSOR_PROJECT_DIR:-$(pwd)}}"
SELF_PATH="${BASH_SOURCE[0]:-$0}"
if [[ -n "$SELF_PATH" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "$SELF_PATH")" 2>/dev/null && pwd || echo "")"
else
  SCRIPT_DIR=""
fi
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-${CURSOR_PLUGIN_ROOT:-$(cd "${SCRIPT_DIR}/.." 2>/dev/null && pwd || echo "$PROJECT_DIR")}}"

PROMPT=""
if [[ -n "$INPUT" ]] && command -v jq >/dev/null 2>&1; then
  PROMPT="$(jq -r '.user_prompt // .prompt // .message // empty' <<< "$INPUT" 2>/dev/null || true)"
fi

LC_PROMPT=""
if [[ -n "$PROMPT" ]]; then
  LC_PROMPT="$(printf '%s' "$PROMPT" | tr '[:upper:]' '[:lower:]')"
fi

classify() {
  local p="$1"
  if [[ -z "$p" ]]; then
    echo "unrelated"
    return
  fi
  if grep -Eq '\b(approve|approved|lgtm|looks good|ship it|go ahead|proceed|yes build it)\b' <<< "$p"; then
    echo "design-approved-continue"
    return
  fi
  if grep -Eq '\b(change|revise|revision|redo|try again|not quite|instead)\b' <<< "$p"; then
    echo "design-revision"
    return
  fi
  if grep -Eq '\b(from scratch|new product|new app|new project|new website|new saas|new landing page|mvp|greenfield|new idea|startup idea|build me)\b' <<< "$p"; then
    echo "build-new-product"
    return
  fi
  if grep -Eq '\b(design|prototype|mockup|wireframe|ui|ux|screen|visual|taste|impeccable|brand|tone|interaction model)\b' <<< "$p"; then
    if grep -Eq '\b(implement|build|add|create code|ship)\b' <<< "$p"; then
      echo "implement-change"
    else
      echo "design-prototype"
    fi
    return
  fi
  if grep -Eq '\b(fix|bug|broken|crash|error|exception|stack ?trace|regression|defect|patch|hotfix)\b' <<< "$p"; then
    echo "fix-bug"
    return
  fi
  if grep -Eq '\b(verify|test|qa|playwright|e2e|smoke|regression test|unit test|integration test|coverage)\b' <<< "$p"; then
    echo "verify-test"
    return
  fi
  if grep -Eq '\b(release|deploy|production|cut release|tag|publish|rollout|rc[ -]?candidate|go live)\b' <<< "$p"; then
    echo "release-review"
    return
  fi
  if grep -Eq '\b(implement|build|add|change|update|refactor|migrate|port|integrate|new feature|settings page|billing|onboarding|dashboard|admin|auth|login|signup|landing page)\b' <<< "$p"; then
    echo "implement-change"
    return
  fi
  if grep -Eq '\b(explain|what is|how does|status|progress|where are we|summary|recap|overview)\b' <<< "$p"; then
    echo "explain-status"
    return
  fi
  if grep -Eq '\b(review|audit|assess|inspect|analyze|analyse|look at|check out|take a look|walk through)\b' <<< "$p"; then
    echo "implement-change"
    return
  fi
  echo "unrelated"
}

INTENT="$(classify "$LC_PROMPT")"

DETECT="$PLUGIN_ROOT/clearpath-detect-mode.sh"
if [[ -n "${CLAUDE_PLUGIN_ROOT:-}" && ! -x "$DETECT" ]]; then
  DETECT="$PLUGIN_ROOT/scripts/clearpath-detect-mode.sh"
fi
MODE="unknown"
CONF="low"
ROUTE="/clearpath:go"
if [[ -x "$DETECT" ]]; then
  OUT="$("$DETECT" --format json 2>/dev/null || true)"
  if [[ -n "$OUT" ]] && command -v jq >/dev/null 2>&1; then
    MODE="$(jq -r '.detected_mode // "unknown"' <<< "$OUT" 2>/dev/null)"
    CONF="$(jq -r '.confidence // "low"' <<< "$OUT" 2>/dev/null)"
    ROUTE="$(jq -r '.recommended_internal_route // "/clearpath:go"' <<< "$OUT" 2>/dev/null)"
  fi
fi

case "$INTENT" in
  unrelated)
    echo "CLEARPATH_AUTOPILOT_PROMPT_INTENT: unrelated"
    echo "CLEARPATH_AUTOPILOT_MODE: $MODE"
    exit 0
    ;;
esac

{
  echo "CLEARPATH_AUTOPILOT_PROMPT_INTENT: $INTENT"
  echo "CLEARPATH_AUTOPILOT_MODE: $MODE"
  echo "CLEARPATH_AUTOPILOT_CONFIDENCE: $CONF"
  echo "CLEARPATH_AUTOPILOT_INTERNAL_ROUTE: $ROUTE"
  echo "CLEARPATH_AUTOPILOT_DEFAULT_ENTRY: /clearpath:go"
  cat <<'EOF'
CLEARPATH_AUTOPILOT_ROUTING:
- Treat this prompt as a product/development request. Use /clearpath:go behavior.
- Do not require the user to manually pick init/update/adopt.
- Clarify only when the product goal is ambiguous, credentials are
  missing, or the request exceeds current scope.
- If a UI change is involved, follow /clearpath:design-prototype:
  build prototype -> present it -> ask user to Approve or Request
  changes in chat.
- When the user approves in chat, immediately follow /clearpath:autonomy
  with mandatory /clearpath:test-driven-development: RED (failing test)
  -> verify fail -> GREEN (minimal code) -> verify pass -> refactor ->
  release candidate without asking routine questions.
- Stop only at the design checkpoint, release candidate review, or
  a real blocker.
EOF
  case "$INTENT" in
    design-approved-continue)
      cat <<'EOF'
CLEARPATH_AUTOPILOT_NOTE:
- Intent: design-approved-continue. The user approved the design.
  Record DESIGN_APPROVAL.md if needed and continue with /clearpath:autonomy
  immediately. Do not ask routine implementation questions.
EOF
      ;;
    design-revision)
      cat <<'EOF'
CLEARPATH_AUTOPILOT_NOTE:
- Intent: design-revision. Revise the prototype per user feedback,
  re-present it, and ask for Approve or Request changes again.
EOF
      ;;
    build-new-product)
      cat <<'EOF'
CLEARPATH_AUTOPILOT_NOTE:
- Intent: build-new-product. If mode is new-empty or new-scaffolded,
  run /clearpath:init then /clearpath:start. If adopt-existing, run
  /clearpath:adopt first.
EOF
      ;;
    implement-change)
      cat <<'EOF'
CLEARPATH_AUTOPILOT_NOTE:
- Intent: implement-change. Open or continue a change pack under
  .clearpath/docs/changes/<id>/. For UI work, run design-prototype first.
  For production code, apply mandatory /clearpath:test-driven-development.
EOF
      ;;
    fix-bug)
      cat <<'EOF'
CLEARPATH_AUTOPILOT_NOTE:
- Intent: fix-bug. Reproduce, write a failing test first (mandatory
  /clearpath:test-driven-development), verify RED, fix with minimal
  code, verify GREEN, and re-run verification.
EOF
      ;;
    design-prototype)
      cat <<'EOF'
CLEARPATH_AUTOPILOT_NOTE:
- Intent: design-prototype. Run /clearpath:design-prototype, present
  the result, and wait for Approve or Request changes in chat.
EOF
      ;;
    verify-test)
      cat <<'EOF'
CLEARPATH_AUTOPILOT_NOTE:
- Intent: verify-test. Route to /clearpath:verify or platform-specific
  verify-web / verify-windows.
EOF
      ;;
    release-review)
      cat <<'EOF'
CLEARPATH_AUTOPILOT_NOTE:
- Intent: release-review. Package RELEASE_CANDIDATE.md and proceed
  when the user confirms.
EOF
      ;;
    explain-status)
      cat <<'EOF'
CLEARPATH_AUTOPILOT_NOTE:
- Intent: explain-status. Read CURRENT_CONTEXT.md and active
  CHANGE_INDEX.md, then summarize.
EOF
      ;;
  esac
} | head -c 10000

exit 0
