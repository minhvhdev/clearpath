#!/usr/bin/env bash
# session-start-autopilot.sh
# SessionStart hook. Injects Clearpath Autopilot routing context for
# the current project. Read-only. Does not create or modify files.
set -u
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "")"
# Resolve the detector: prefer the project's own copy, then the
# plugin's copy, then the script's own directory.
DETECT=""
for cand in \
  "$PROJECT_DIR/scripts/clearpath-detect-mode.sh" \
  "${CLAUDE_PLUGIN_ROOT:+$CLAUDE_PLUGIN_ROOT/scripts/clearpath-detect-mode.sh}" \
  "$SCRIPT_DIR/clearpath-detect-mode.sh"; do
  if [[ -n "$cand" && -x "$cand" ]]; then
    DETECT="$cand"
    break
  fi
done

echo "CLEARPATH_AUTOPILOT: active"
echo "CLEARPATH_AUTOPILOT_DEFAULT_ENTRY: /clearpath:go"

if [[ -x "$DETECT" ]]; then
  OUT="$("$DETECT" --format json 2>/dev/null || true)"
  if [[ -n "$OUT" ]] && command -v jq >/dev/null 2>&1; then
    MODE=$(jq -r '.detected_mode // "unknown"' <<< "$OUT" 2>/dev/null)
    CONF=$(jq -r '.confidence // "low"' <<< "$OUT" 2>/dev/null)
    ROUTE=$(jq -r '.recommended_internal_route // "/clearpath:go"' <<< "$OUT" 2>/dev/null)
    ENTRY=$(jq -r '.recommended_entrypoint // "/clearpath:go"' <<< "$OUT" 2>/dev/null)
    NEXT=$(jq -r '.next_behavior // ""' <<< "$OUT" 2>/dev/null)
    echo "CLEARPATH_AUTOPILOT_MODE: $MODE"
    echo "CLEARPATH_AUTOPILOT_CONFIDENCE: $CONF"
    echo "CLEARPATH_AUTOPILOT_RECOMMENDED_ENTRY: $ENTRY"
    echo "CLEARPATH_AUTOPILOT_INTERNAL_ROUTE: $ROUTE"
    if [[ -n "$NEXT" ]]; then
      echo "CLEARPATH_AUTOPILOT_NEXT: $NEXT"
    fi
  else
    echo "CLEARPATH_AUTOPILOT_MODE: unknown"
    echo "CLEARPATH_AUTOPILOT_CONFIDENCE: low"
  fi
else
  echo "CLEARPATH_AUTOPILOT_MODE: unknown"
  echo "CLEARPATH_AUTOPILOT_CONFIDENCE: low"
fi

# Preserve the existing minimal session-start tip so behavior in
# existing projects does not regress.
BOOT="$PROJECT_DIR/docs/clearpath/BOOT.md"
if [[ -f "$BOOT" ]]; then
  echo "CLEARPATH_SESSION_START: Read docs/clearpath/BOOT.md first. Use ARTIFACT_INDEX.json and CURRENT_CONTEXT.md for progressive retrieval."
fi

cat <<'EOF'
CLEARPATH_AUTOPILOT_INSTRUCTIONS:
- Default user entrypoint is /clearpath:go.
- If the user says "build me X", "add Y", "fix Z", "review W" in plain
  language, treat the request as an implement-change task and follow
  /clearpath:go behavior. Do not require the user to pick a skill.
- Only ask clarifying questions when the product goal is ambiguous
  enough to risk building the wrong thing, when there are multiple
  materially different UX/product directions, when credentials are
  missing, when scope is exceeded, or when a governance boundary is
  touched.
- If a prototype or production UI is involved, follow
  /clearpath:design-prototype: prototype -> taste-design ->
  impeccable -> UI_CONTRACT.md -> DESIGN_REVIEW.md -> stop for user
  design approval.
- After design/scope approval, follow /clearpath:autonomy: code ->
  test -> fix -> retest -> release candidate without asking routine
  questions. Stop only at design approval, release candidate review,
  or real blockage.
- Source-control finalization (git add/commit/push, tags, history
  rewrite) is NOT automatic; it requires explicit user approval.
- Governance hooks remain the hard boundary for protected actions.
  Autopilot is an orchestration layer, not a replacement.
EOF
exit 0
