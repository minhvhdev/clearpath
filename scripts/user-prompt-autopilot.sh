#!/usr/bin/env bash
# user-prompt-autopilot.sh
# UserPromptSubmit hook. Inspects the user's prompt and injects
# Clearpath Autopilot routing context. Read-only. Does not create
# files and does not block normal prompts.
set -u
INPUT=""
if [[ ! -t 0 ]]; then
  INPUT="$(cat 2>/dev/null || true)"
fi
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
# Resolve the script's own absolute path so the hook works in test
# contexts where CLAUDE_PLUGIN_ROOT is not set.
SELF_PATH="${BASH_SOURCE[0]:-$0}"
if [[ -n "$SELF_PATH" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "$SELF_PATH")" 2>/dev/null && pwd || echo "")"
else
  SCRIPT_DIR=""
fi
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-${SCRIPT_DIR:-$PROJECT_DIR}}"

# Pull the user's prompt out of the hook payload. Tolerant: if jq
# is missing or the payload is malformed, fall back to empty.
PROMPT=""
if [[ -n "$INPUT" ]] && command -v jq >/dev/null 2>&1; then
  PROMPT="$(jq -r '.user_prompt // .prompt // .message // empty' <<< "$INPUT" 2>/dev/null || true)"
fi

# Lowercase copy for keyword matching.
LC_PROMPT=""
if [[ -n "$PROMPT" ]]; then
  LC_PROMPT="$(printf '%s' "$PROMPT" | tr '[:upper:]' '[:lower:]')"
fi

# Intent classifier. Returns one of:
#   build-new-product | implement-change | fix-bug | design-prototype
#   verify-test | release-review | explain-status | unrelated
classify() {
  local p="$1"
  if [[ -z "$p" ]]; then
    echo "unrelated"
    return
  fi
  # New-product signals are checked first so "Build me a SaaS
  # landing page" does not get downgraded to implement-change by
  # the generic "build" keyword.
  if grep -Eq '\b(from scratch|new product|new app|new project|new website|new saas|new landing page|mvp|greenfield|new idea|startup idea|build me)\b' <<< "$p"; then
    echo "build-new-product"
    return
  fi
  # design / prototype / ui / screen / mockup
  if grep -Eq '\b(design|prototype|mockup|wireframe|ui|ux|screen|visual|taste|impeccable|brand|tone|interaction model)\b' <<< "$p"; then
    # distinguish pure design-vs-implement when both signals exist
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
  echo "unrelated"
}

INTENT="$(classify "$LC_PROMPT")"

# Run mode detection for context.
DETECT="$PLUGIN_ROOT/clearpath-detect-mode.sh"
# SCRIPT_DIR is the absolute path to this hook script (e.g. /x/scripts).
# The detector lives next to it. If PLUGIN_ROOT was set via
# CLAUDE_PLUGIN_ROOT, the project layout is <plugin>/scripts/<hook>
# and the detector is at $PLUGIN_ROOT/scripts/clearpath-detect-mode.sh.
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

# Build the routing recommendation block.
case "$INTENT" in
  unrelated)
    # Inject nothing beyond a small marker so the hook is observable.
    echo "CLEARPATH_AUTOPILOT_PROMPT_INTENT: unrelated"
    echo "CLEARPATH_AUTOPILOT_MODE: $MODE"
    exit 0
    ;;
esac

# Cap at 10,000 characters per spec.
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
- Clarify only when the product goal is ambiguous enough to risk
  building the wrong thing, when there are multiple materially
  different UX/product directions, when credentials are missing,
  when the request exceeds current scope, or when a governance
  boundary is touched.
- If a UI change is involved, follow /clearpath:design-prototype
  (prototype -> taste-design -> impeccable -> design-critic) and
  stop for user design approval before production UI edits.
- After design/scope approval, follow /clearpath:autonomy: code ->
  test -> fix -> retest -> release candidate. Do not ask routine
  implementation questions.
- Stop only at: design approval checkpoint, release candidate
  review, or real blockage.
- Source-control finalization (git add/commit/push, tags, history
  rewrite) is NOT automatic; require explicit user approval.
- Governance hooks remain the hard boundary. Autopilot orchestrates
  but does not bypass approval gates.
EOF
  case "$INTENT" in
    build-new-product)
      cat <<'EOF'
CLEARPATH_AUTOPILOT_NOTE:
- Intent: build-new-product. Internal route is $ROUTE. If mode is
  new-empty or new-scaffolded, /clearpath:go will run /clearpath:init
  then /clearpath:start. If mode is adopt-existing, /clearpath:go
  will route to /clearpath:adopt and not start product work until
  the repo is inventoried.
EOF
      ;;
    implement-change)
      cat <<'EOF'
CLEARPATH_AUTOPILOT_NOTE:
- Intent: implement-change. Open or continue a change pack under
  docs/changes/<id>/. Follow /clearpath:execute after design approval
  is recorded.
EOF
      ;;
    fix-bug)
      cat <<'EOF'
CLEARPATH_AUTOPILOT_NOTE:
- Intent: fix-bug. Reproduce first, then write a failing test if the
  repo has test infrastructure, then fix and re-run. Record evidence
  in the active change pack.
EOF
      ;;
    design-prototype)
      cat <<'EOF'
CLEARPATH_AUTOPILOT_NOTE:
- Intent: design-prototype. Run /clearpath:design-prototype. The
  orchestrator runs taste-design first, impeccable second, then
  UI_CONTRACT.md and DESIGN_REVIEW.md. Stop for user design
  approval before production UI edits.
EOF
      ;;
    verify-test)
      cat <<'EOF'
CLEARPATH_AUTOPILOT_NOTE:
- Intent: verify-test. Route to /clearpath:verify (web ->
  /clearpath:verify-web for Playwright + Chrome DevTools MCP;
  Windows native -> /clearpath:verify-windows for CursorTouch/
  Windows-MCP with default-deny for PowerShell/Registry/
  FileSystem/Process).
EOF
      ;;
    release-review)
      cat <<'EOF'
CLEARPATH_AUTOPILOT_NOTE:
- Intent: release-review. Production releases still require the
  .clearpath/approvals/allow-production-release sentinel. The
  safety gate denies deploy commands without it.
EOF
      ;;
    explain-status)
      cat <<'EOF'
CLEARPATH_AUTOPILOT_NOTE:
- Intent: explain-status. Read docs/clearpath/CURRENT_CONTEXT.md
  and the active CHANGE_INDEX.md, then summarize.
EOF
      ;;
  esac
} | head -c 10000
exit 0
