#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[[ -f "$ROOT/.claude-plugin/plugin.json" ]]
[[ ! -f "$ROOT/plugin.json" ]]
[[ -d "$ROOT/skills" ]]
[[ -d "$ROOT/agents" ]]
[[ -f "$ROOT/.cursor/rules/clearpath.mdc" ]]
[[ -f "$ROOT/.cursor/rules/clearpath-autopilot.mdc" ]]
[[ -f "$ROOT/hooks/hooks.json" ]]
[[ -f "$ROOT/.mcp.json" ]]
[[ -f "$ROOT/templates/project/.cursor/rules/clearpath.mdc" ]]
[[ -f "$ROOT/templates/project/.cursor/rules/clearpath-autopilot.mdc" ]]
if command -v jq >/dev/null 2>&1; then
  jq -e . "$ROOT/.claude-plugin/plugin.json" >/dev/null
  jq -e . "$ROOT/hooks/hooks.json" >/dev/null
  jq -e . "$ROOT/.mcp.json" >/dev/null
fi
for f in "$ROOT"/scripts/*.sh "$ROOT"/tests/*.sh "$ROOT"/bin/*; do
  [[ -f "$f" ]] || continue
  bash -n "$f"
  [[ -x "$f" ]]
done
echo "PASS: plugin structure test"
