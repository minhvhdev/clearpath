#!/usr/bin/env bash
set -u
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${CURSOR_PROJECT_DIR:-$(pwd)}}"
mkdir -p "$PROJECT_DIR/.clearpath/docs" "$PROJECT_DIR/.clearpath/prototype" >/dev/null 2>&1 || true
if [[ ! -f "$PROJECT_DIR/.clearpath/docs/STATE.md" ]]; then
  cat > "$PROJECT_DIR/.clearpath/docs/STATE.md" <<'EOF'
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
exit 0
