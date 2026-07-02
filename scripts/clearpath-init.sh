#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR="${1:-${CLAUDE_PROJECT_DIR:-$(pwd)}}"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
DOCS="$PROJECT_DIR/.clearpath/docs"
CHANGES="$DOCS/changes"
PROTO="$PROJECT_DIR/.clearpath/prototype"
mkdir -p "$DOCS" "$CHANGES" "$PROTO"

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

TEMPLATE_DOCS="$PLUGIN_ROOT/templates/project/.clearpath/docs"
copy_if_missing "$TEMPLATE_DOCS/BOOT.md" "$DOCS/BOOT.md"
copy_if_missing "$TEMPLATE_DOCS/CURRENT_CONTEXT.md" "$DOCS/CURRENT_CONTEXT.md"
copy_if_missing "$TEMPLATE_DOCS/STATE.md" "$DOCS/STATE.md"
copy_if_missing "$TEMPLATE_DOCS/PRODUCT.md" "$DOCS/PRODUCT.md"
copy_if_missing "$TEMPLATE_DOCS/DECISIONS.md" "$DOCS/DECISIONS.md"
copy_if_missing "$TEMPLATE_DOCS/PROJECT_INDEX.json" "$DOCS/PROJECT_INDEX.json"
copy_if_missing "$TEMPLATE_DOCS/ARTIFACT_INDEX.json" "$DOCS/ARTIFACT_INDEX.json"
copy_if_missing "$TEMPLATE_DOCS/policy.json" "$DOCS/policy.json"
copy_if_missing "$TEMPLATE_DOCS/AUTOPILOT.md" "$DOCS/AUTOPILOT.md"
copy_if_missing "$PLUGIN_ROOT/templates/project/.clearpath/prototype/index.html" "$PROTO/index.html"
if [[ ! -f "$PROJECT_DIR/CLAUDE.md" ]]; then
  cp "$PLUGIN_ROOT/templates/project/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
  echo "created $PROJECT_DIR/CLAUDE.md"
else
  echo "exists  $PROJECT_DIR/CLAUDE.md"
fi
# shellcheck source=clearpath-python.sh
source "$PLUGIN_ROOT/scripts/clearpath-python.sh"
if clearpath_find_python; then
  "${CLEARPATH_PYTHON_CMD[@]}" "$PLUGIN_ROOT/scripts/clearpath-index.py" "$PROJECT_DIR" >/dev/null 2>&1 || true
elif [[ -n "${CLEARPATH_PYTHON:-}" ]]; then
  clearpath_python_not_found_message
  exit 49
fi
cat <<EOF

Clearpath project artifacts initialized.
Next:
  1. Review .clearpath/docs/BOOT.md
  2. Start Claude Code at the project root with this plugin enabled
  3. Use /clearpath:start, /clearpath:update, or /clearpath:adopt
EOF
