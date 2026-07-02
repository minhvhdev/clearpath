#!/usr/bin/env bash
# session-start-autopilot.sh
# SessionStart hook. Injects Clearpath Autopilot routing context for
# the current project. Read-only. Does not create or modify files.
set -u
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "")"
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

BOOT="$PROJECT_DIR/.clearpath/docs/BOOT.md"
if [[ -f "$BOOT" ]]; then
  echo "CLEARPATH_SESSION_START: Read .clearpath/docs/BOOT.md first. Use ARTIFACT_INDEX.json and CURRENT_CONTEXT.md for progressive retrieval."
fi

cat <<'EOF'
CLEARPATH_AUTOPILOT_INSTRUCTIONS:
- Default user entrypoint is /clearpath:go.
- If the user says "build me X", "add Y", "fix Z" in plain language,
  follow /clearpath:go. Do not require the user to pick a skill.
- For UI work: prototype -> present -> ask user to Approve or Request
  changes in chat.
- After approval, follow /clearpath:autonomy and keep going without
  routine questions.
- Stop only at the design checkpoint, release candidate review, or a
  real blocker.
EOF
exit 0
