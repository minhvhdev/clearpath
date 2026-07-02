#!/usr/bin/env bash
# Install missing Clearpath prerequisites into user scope.
# Requires explicit user approval via CLEARPATH_DOCTOR_INSTALL_APPROVED=1
set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
REQ="$PLUGIN_ROOT/scripts/clearpath-requirements.json"
HOME_DIR="${HOME:-$(cd ~ && pwd)}"

if [[ "${CLEARPATH_DOCTOR_INSTALL_APPROVED:-}" != "1" ]]; then
  echo "CLEARPATH_DOCTOR_INSTALL_BLOCKED: User approval required."
  echo "Ask the user, then rerun with CLEARPATH_DOCTOR_INSTALL_APPROVED=1"
  exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "CLEARPATH_DOCTOR_INSTALL_FAIL: jq is required to merge MCP settings. Install jq first."
  exit 1
fi

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

skill_present() {
  local id="$1"
  local dirs marker dir path
  dirs="$(jq -r --arg id "$id" '.skills[] | select(.id==$id) | .user_scope_dirs[]' "$REQ")"
  marker="$(jq -r --arg id "$id" '.skills[] | select(.id==$id) | .marker_file' "$REQ")"
  while IFS= read -r d; do
    [[ -z "$d" ]] && continue
    path="$(expand_home "$d")/$marker"
    if [[ -f "$path" ]]; then
      return 0
    fi
  done <<< "$dirs"
  return 1
}

find_skill_source() {
  local name="$1"
  local candidate hit
  for candidate in \
    "$HOME_DIR/.claude/skills/$name" \
    "$HOME_DIR/.cursor/skills/$name" \
    "$HOME_DIR/.cursor/skills-cursor/$name" \
    "$PLUGIN_ROOT/vendor/skills/$name"; do
    if [[ -f "$candidate/SKILL.md" ]]; then
      printf '%s' "$candidate"
      return 0
    fi
  done
  if [[ -d "$HOME_DIR/.cursor/plugins/cache" ]]; then
    while IFS= read -r hit; do
      candidate="$(dirname "$hit")"
      if [[ -f "$candidate/SKILL.md" ]]; then
        printf '%s' "$candidate"
        return 0
      fi
    done < <(find "$HOME_DIR/.cursor/plugins/cache" -type f -name 'SKILL.md' 2>/dev/null | grep -E "/${name}/SKILL.md$" || true)
  fi
  return 1
}

install_skill_to_user_scope() {
  local id="$1"
  local dest name src
  name="$(jq -r --arg id "$id" '.skills[] | select(.id==$id) | .label' "$REQ")"
  dest="$(expand_home ".claude/skills/$name")"
  if skill_present "$id"; then
    echo "SKIP: skill $name already in user scope"
    return 0
  fi
  if ! src="$(find_skill_source "$name")"; then
    echo "FAIL: skill $name not found locally to copy; install it manually into ~/.claude/skills/$name"
    return 1
  fi
  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  cp -a "$src" "$dest"
  echo "INSTALLED: skill $name -> $dest (from $src)"
}

mcp_present_in_user_settings() {
  local id="$1"
  local f expanded
  while IFS= read -r rel; do
    [[ -z "$rel" ]] && continue
    expanded="$(expand_home "$rel")"
    [[ -f "$expanded" ]] || continue
    if jq -e --arg id "$id" '.mcpServers[$id] // .mcp_servers[$id] // empty' "$expanded" >/dev/null 2>&1; then
      return 0
    fi
  done < <(jq -r '.user_mcp_settings_paths[]' "$REQ")
  return 1
}

merge_mcp_to_user_settings() {
  local settings
  settings="$(expand_home ".claude/settings.json")"
  mkdir -p "$(dirname "$settings")"
  if [[ ! -f "$settings" ]]; then
    echo '{}' > "$settings"
  fi
  local tmp merged
  tmp="${TMPDIR:-/tmp}/clearpath-mcp-merge.$$"
  jq -s '.[0] * {mcpServers: ((.[0].mcpServers // {}) + (.[1].mcpServers // {}))}' \
    "$settings" "$PLUGIN_ROOT/.mcp.json" > "$tmp"
  mv "$tmp" "$settings"
  echo "INSTALLED: merged plugin MCP servers into $settings"
}

install_cli_best_effort() {
  local id="$1" cmd hint
  cmd="$(jq -r --arg id "$id" '.cli[] | select(.id==$id) | .command' "$REQ")"
  hint="$(jq -r --arg id "$id" '.cli[] | select(.id==$id) | .install_hint' "$REQ")"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "SKIP: $cmd already available"
    return 0
  fi
  case "$id" in
    uvx)
      if command -v pip3 >/dev/null 2>&1; then
        pip3 install -U uv && echo "INSTALLED: uv via pip3 (provides uvx)" && return 0
      fi
      if command -v pip >/dev/null 2>&1; then
        pip install -U uv && echo "INSTALLED: uv via pip (provides uvx)" && return 0
      fi
      ;;
    codebase-memory-mcp)
      if command -v npm >/dev/null 2>&1; then
        npm install -g codebase-memory-mcp && echo "INSTALLED: codebase-memory-mcp via npm -g" && return 0
      fi
      ;;
  esac
  echo "MANUAL: $cmd missing — $hint"
  return 1
}

FAIL=0

echo "CLEARPATH_DOCTOR_INSTALL: starting (user scope)"

while IFS= read -r skill_id; do
  [[ -z "$skill_id" ]] && continue
  install_skill_to_user_scope "$skill_id" || FAIL=$((FAIL + 1))
done < <(jq -r '.skills[] | select(.required==true) | .id' "$REQ")

if ! mcp_present_in_user_settings "chrome-devtools"; then
  merge_mcp_to_user_settings || FAIL=$((FAIL + 1))
else
  echo "SKIP: user MCP settings already define chrome-devtools"
fi

while IFS= read -r cli_id; do
  [[ -z "$cli_id" ]] && continue
  install_cli_best_effort "$cli_id" || true
done < <(jq -r '.cli[] | select(.required==true) | .id' "$REQ")

if [[ "$FAIL" -gt 0 ]]; then
  echo "CLEARPATH_DOCTOR_INSTALL: completed with $FAIL failure(s)"
  exit 1
fi

echo "CLEARPATH_DOCTOR_INSTALL: completed successfully"
exit 0
