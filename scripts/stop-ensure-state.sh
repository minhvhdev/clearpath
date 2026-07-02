#!/usr/bin/env bash
set -u
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
mkdir -p "$PROJECT_DIR/docs/clearpath" "$PROJECT_DIR/.clearpath/approvals" >/dev/null 2>&1 || true
if [[ ! -f "$PROJECT_DIR/docs/clearpath/STATE.md" ]]; then
  cat > "$PROJECT_DIR/docs/clearpath/STATE.md" <<'EOF'
---
type: state
status: draft
canonical: true
---
# Clearpath State

## Current Mode
unknown

## Current Phase
unknown

## Active Change
none

## Next Action
Initialize Clearpath artifacts with `clearpath-init` or `/clearpath:init`.

## Blockers
- Clearpath state has not been initialized.
EOF
fi
# Keep quiet; this Stop hook only ensures STATE.md exists, it does not
# auto-track session phase, active change, or any other state. State
# contents remain the model/user's responsibility. Renamed from
# stop-update-state.sh in v0.4.1 to reflect the ensure-only behavior.
exit 0
