#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR="${1:-${CLAUDE_PROJECT_DIR:-$(pwd)}}"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
mkdir -p "$PROJECT_DIR/docs/clearpath" "$PROJECT_DIR/docs/changes" "$PROJECT_DIR/.clearpath/approvals"

copy_if_missing() {
  local src="$1" dst="$2"
  if [[ ! -f "$dst" ]]; then
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "created $dst"
  else
    echo "exists  $dst"
  fi
}

copy_if_missing "$PLUGIN_ROOT/templates/project/docs/clearpath/BOOT.md" "$PROJECT_DIR/docs/clearpath/BOOT.md"
copy_if_missing "$PLUGIN_ROOT/templates/project/docs/clearpath/CURRENT_CONTEXT.md" "$PROJECT_DIR/docs/clearpath/CURRENT_CONTEXT.md"
copy_if_missing "$PLUGIN_ROOT/templates/project/docs/clearpath/STATE.md" "$PROJECT_DIR/docs/clearpath/STATE.md"
copy_if_missing "$PLUGIN_ROOT/templates/project/docs/clearpath/PRODUCT.md" "$PROJECT_DIR/docs/clearpath/PRODUCT.md"
copy_if_missing "$PLUGIN_ROOT/templates/project/docs/clearpath/DECISIONS.md" "$PROJECT_DIR/docs/clearpath/DECISIONS.md"
copy_if_missing "$PLUGIN_ROOT/templates/project/docs/clearpath/PROJECT_INDEX.json" "$PROJECT_DIR/docs/clearpath/PROJECT_INDEX.json"
copy_if_missing "$PLUGIN_ROOT/templates/project/docs/clearpath/ARTIFACT_INDEX.json" "$PROJECT_DIR/docs/clearpath/ARTIFACT_INDEX.json"
copy_if_missing "$PLUGIN_ROOT/templates/project/docs/clearpath/policy.json" "$PROJECT_DIR/docs/clearpath/policy.json"
if [[ ! -f "$PROJECT_DIR/CLAUDE.md" ]]; then
  cp "$PLUGIN_ROOT/templates/project/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
  echo "created $PROJECT_DIR/CLAUDE.md"
else
  echo "exists  $PROJECT_DIR/CLAUDE.md"
fi
python3 "$PLUGIN_ROOT/scripts/clearpath-index.py" "$PROJECT_DIR" >/dev/null 2>&1 || true
cat <<EOF

Clearpath project artifacts initialized.
Next:
  1. Review docs/clearpath/BOOT.md
  2. Start Claude Code at the project root with this plugin enabled
  3. Use /clearpath:start, /clearpath:update, or /clearpath:adopt
EOF
