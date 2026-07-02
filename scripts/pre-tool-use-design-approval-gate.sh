#!/usr/bin/env bash
set -u

INPUT="$(cat)"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/ }"
  s="${s//$'\r'/ }"
  printf '%s' "$s"
}

deny() {
  local reason
  reason="$(json_escape "$1")"
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason"
  exit 0
}

if ! command -v jq >/dev/null 2>&1; then
  deny "Clearpath design gate requires jq. Install jq or disable the plugin explicitly; tool call blocked fail-closed."
fi

if ! jq -e . >/dev/null 2>&1 <<< "$INPUT"; then
  deny "Clearpath design gate received malformed hook JSON; tool call blocked fail-closed."
fi

TOOL_NAME="$(jq -r '.tool_name // empty' <<< "$INPUT")"
FILE_PATH="$(jq -r '.tool_input.file_path // .tool_input.path // .tool_input.notebook_path // empty' <<< "$INPUT")"
COMMAND="$(jq -r '.tool_input.command // empty' <<< "$INPUT")"
NORM_PATH="${FILE_PATH#./}"

has_design_approval() {
  [[ -f "$PROJECT_DIR/.clearpath/approvals/design-approved" ]]
}

is_approval_path() {
  local p="${1#./}"
  [[ "$p" =~ (^|/)\.clearpath/approvals(/|$) ]] && return 0
  [[ "$p" =~ (^|/)(DESIGN|DEPENDENCY|RELEASE|DATA)_APPROVAL\.(json|md|txt)$ ]] && return 0
  return 1
}

# v0.4.3 fix: mirrors the safety gate's APPROVAL_DIR_RE/APPROVAL_NAME_RE
# fix. The previous inline check required a literal trailing slash
# after `.clearpath/approvals` and had no sentinel-basename fallback,
# so `cd .clearpath/approvals && touch design-approved`,
# `D=.clearpath/approvals; echo x > "$D/design-approved"`, and
# `touch .clearpath/./approvals/design-approved` all bypassed the gate
# (confirmed via live hook-script exploit test).
command_mentions_approval_bash() {
  local cmd="$1"
  if grep -Eiq '(^|[^[:alnum:]_-])\.clearpath/approvals([^[:alnum:]_-]|$)' <<< "$cmd"; then return 0; fi
  if grep -Eiq '(^|[^[:alnum:]_-])(design-approved|allow-production-release|allow-secret-edit|allow-design-implementation|allow-destructive-shell|allow-destructive-data|allow-dependency-install)([^[:alnum:]_-]|$)' <<< "$cmd"; then return 0; fi
  if grep -Eiq '(design|dependency|release|data)_approval\.(json|md|txt)' <<< "$cmd"; then return 0; fi
  return 1
}

is_safe_nonproduction_design_path() {
  local p="${1#./}"
  [[ "$p" =~ ^(prototype|prototypes|mockups|docs|design-docs)/ ]] && return 0
  [[ "$p" =~ (^|/)(README|CHANGELOG|NOTES)\.md$ ]] && return 0
  return 1
}

is_production_ui_path() {
  local p="${1#./}"
  # Canonical UI extensions anywhere in common source roots.
  if [[ "$p" =~ (^|/)(components|app|pages|ui|views|frontend|web|client|styles|src/app|src/pages|src/components|src/ui|src/views|src/client|src/styles|mobile|lib/widgets|screens|widgets|source)/.*\.(tsx|jsx|vue|svelte|css|scss|sass|less|html|mdx)$ ]]; then
    return 0
  fi
  # Mobile / desktop / cross-platform production code paths (.dart, .swift, .kt).
  if [[ "$p" =~ (^|/)(mobile|screens|widgets|lib/widgets|source)/.*\.(dart|swift|kt)$ ]]; then
    return 0
  fi
  # JS/TS are UI-bearing only in strong UI directories; avoid generic src/lib/*.ts false positives.
  if [[ "$p" =~ (^|/)(app|pages|components|ui|views|frontend|web|client|src/app|src/pages|src/components|src/ui|src/views|src/client)/.*\.(ts|js)$ ]]; then
    return 0
  fi
  # Root-level common Next/Vite entry files.
  if [[ "$p" =~ ^(app|pages)/.*\.(ts|js|tsx|jsx|css|scss|mdx)$ ]]; then
    return 0
  fi
  return 1
}

# Extract likely write targets from a Bash command string. Heuristic, not a
# parser: covers the common write patterns the v0.4.0 gate would have
# missed. Each captured path is normalized (leading ./ stripped) before
# production-UI evaluation.
extract_bash_write_targets() {
  local cmd="$1"
  local -a targets=()
  local p

  # Find explicit redirect targets: > path, >> path, < path.
  while IFS= read -r p; do
    [[ -n "$p" ]] || continue
    targets+=("$p")
  done < <(printf '%s' "$cmd" | grep -Eo '(\<\<|\>\>|\>|\<)[[:space:]]*[^[:space:]|&;<>()]+' \
            | sed -E 's/^(\<\<|\>\>|\>|\<)[[:space:]]*//')

  # Find common copy/move destinations: cp SRC... DST, mv SRC... DST
  # (last whitespace-separated token after cp/mv).
  while IFS= read -r p; do
    [[ -n "$p" ]] || continue
    targets+=("$p")
  done < <(printf '%s' "$cmd" | grep -Eoi '(^|[;&|[:space:]])(cp|mv|install)[[:space:]]+[^;&|<>()]+' \
            | sed -E 's/.*[[:space:]]([^[:space:]]+)$/\1/')

  # Find tee targets: tee [path] or tee -a path.
  while IFS= read -r p; do
    [[ -n "$p" ]] || continue
    targets+=("$p")
  done < <(printf '%s' "$cmd" | grep -Eoi '(^|[;&|[:space:]])tee[[:space:]]+(-a[[:space:]]+)?[^[:space:]|&;<>()]+' \
            | sed -E 's/.*tee[[:space:]]+(-a[[:space:]]+)?//')

  # Find Python open('path', 'w'|'a') or writeFileSync('path', ...).
  while IFS= read -r p; do
    [[ -n "$p" ]] || continue
    targets+=("$p")
  done < <(printf '%s' "$cmd" | grep -Eo "open\([[:space:]]*['\"][^'\"]+['\"]" \
            | sed -E "s/open\([[:space:]]*['\"]//; s/['\"]$//")
  while IFS= read -r p; do
    [[ -n "$p" ]] || continue
    targets+=("$p")
  done < <(printf '%s' "$cmd" | grep -Eo "writeFileSync\([[:space:]]*['\"][^'\"]+['\"]" \
            | sed -E "s/writeFileSync\([[:space:]]*['\"]//; s/['\"]$//")

  # Find wrapped Node writes: require('fs').writeFileSync('path', ...),
  # require("fs").writeFileSync("path", ...), and the bare
  # fs.writeFileSync('path', ...) form. Path is the first quoted
  # argument after the opening paren.
  while IFS= read -r p; do
    [[ -n "$p" ]] || continue
    targets+=("$p")
  done < <(printf '%s' "$cmd" | grep -Eo "(require\([[:space:]]*['\"]fs['\"]\)|fs)\.writeFileSync\([[:space:]]*['\"][^'\"]+['\"]" \
            | sed -E "s/.*writeFileSync\([[:space:]]*['\"]//; s/['\"]$//")

  printf '%s\n' "${targets[@]}"
}

if [[ "$TOOL_NAME" =~ ^(Edit|Write|MultiEdit)$ ]]; then
  if is_approval_path "$NORM_PATH"; then
    deny "Clearpath design approval files cannot be created or edited by Claude tools. User must approve manually outside Claude Code."
  fi
  if is_safe_nonproduction_design_path "$NORM_PATH"; then
    exit 0
  fi
  if is_production_ui_path "$NORM_PATH" && ! has_design_approval; then
    deny "Clearpath design gate: production UI changes require user-approved design first. User must create .clearpath/approvals/design-approved manually after approving the prototype/UI contract."
  fi
  exit 0
fi

if [[ "$TOOL_NAME" == "Bash" ]]; then
  # Block any write to approval files via Bash.
  if command_mentions_approval_bash "$COMMAND"; then
    deny "Clearpath design approval files cannot be created or edited by Claude tools. User must approve manually outside Claude Code."
  fi
  # Extract write targets and run the production-UI heuristic on each.
  while IFS= read -r target; do
    [[ -n "$target" ]] || continue
    if is_safe_nonproduction_design_path "$target"; then
      continue
    fi
    if is_production_ui_path "$target" && ! has_design_approval; then
      deny "Clearpath design gate: Bash command targets production UI file '$target' and requires user-approved design first. User must create .clearpath/approvals/design-approved manually after approving the prototype/UI contract."
    fi
  done < <(extract_bash_write_targets "$COMMAND")
  exit 0
fi

exit 0
