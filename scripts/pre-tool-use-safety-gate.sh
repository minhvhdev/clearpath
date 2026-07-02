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

allow_sentinel() {
  local name="$1"
  [[ -f "$PROJECT_DIR/.clearpath/approvals/$name" ]]
}

if ! command -v jq >/dev/null 2>&1; then
  deny "Clearpath safety gate requires jq. Install jq or disable the plugin explicitly; tool call blocked fail-closed."
fi

if ! jq -e . >/dev/null 2>&1 <<< "$INPUT"; then
  deny "Clearpath safety gate received malformed hook JSON; tool call blocked fail-closed."
fi

TOOL_NAME="$(jq -r '.tool_name // empty' <<< "$INPUT")"
COMMAND="$(jq -r '.tool_input.command // empty' <<< "$INPUT")"
FILE_PATH="$(jq -r '.tool_input.file_path // .tool_input.path // .tool_input.notebook_path // empty' <<< "$INPUT")"

# Normalize leading ./ for path checks.
NORM_PATH="${FILE_PATH#./}"
LOWER_COMMAND="$(printf '%s' "$COMMAND" | tr '[:upper:]' '[:lower:]')"

# Fail-closed: any approval sentinel path or sentinel-name token.
# Approval sentinels: anything under .clearpath/approvals/ or the explicit
# sentinel basenames the safety gate reads. Creating, modifying, or
# deleting these is never allowed from Claude tools.
# Token boundary: anything non-alphanumeric that is not a dot, dash,
# underscore, or slash. Captures spaces, ;, &, |, =, <, >, etc.
APPROVAL_PATH_RE='(^|[^[:alnum:]._/-])(\.clearpath/approvals/|\./\.clearpath/approvals/)'
APPROVAL_NAME_RE='allow-(production-release|secret-edit|design-implementation|destructive-shell|destructive-data|dependency-install)|allow-?(prod[-_]?release|secret|design|destructive|dependency)'
APPROVAL_DOC_RE='(design|dependency|release|data)_approval\.(json|md|txt)'

is_approval_path() {
  local p="${1#./}"
  [[ "$p" =~ (^|/)\.clearpath/approvals/ ]] && return 0
  [[ "$p" =~ (^|/)(DESIGN|DEPENDENCY|RELEASE|DATA)_APPROVAL\.(json|md|txt)$ ]] && return 0
  return 1
}

is_secret_path() {
  local p="${1#./}"
  [[ "$p" =~ (^|/)(\.env($|\.)|\.npmrc$|\.pypirc$|\.netrc$|id_rsa$|id_ed25519$|secrets?\.(json|ya?ml|toml|env)$|secret\.(json|ya?ml|toml|env)$) ]]
}

command_mentions_approval() {
  # Return 0 (true) if the lower-cased command string touches any
  # approval sentinel path or sentinel name. This is the fail-closed
  # baseline; the narrow allow checks below are the only exception.
  local cmd="$1"
  if grep -Eiq "$APPROVAL_PATH_RE" <<< "$cmd"; then return 0; fi
  if grep -Eiq "$APPROVAL_DOC_RE" <<< "$cmd"; then return 0; fi
  if grep -Eiq "(^|[;&|[:space:]])$APPROVAL_NAME_RE" <<< "$cmd"; then return 0; fi
  return 1
}

is_safe_approval_read() {
  # Narrow allow-list: read-only checks against the approvals dir.
  # No redirection, no piping into writing commands, no command
  # substitution, no command lists joined by ; & |.
  local cmd="$1"
  # Disallow any chain/sink operator.
  if [[ "$cmd" =~ (;|\&\&|\|\||\||\$\(|\`) ]]; then return 1; fi
  # Disallow redirects of any kind.
  if [[ "$cmd" =~ [\<\>][\>\&]? ]] && ! [[ "$cmd" =~ ^[[:space:]]*(\[|test)[[:space:]]+-f[[:space:]]+\.clearpath/approvals/[^[:space:]]+[[:space:]]*\][[:space:]]*$ ]]; then
    return 1
  fi
  if [[ "$cmd" =~ \>[[:space:]]*\.clearpath/approvals/ ]]; then return 1; fi
  if [[ "$cmd" =~ \<\<[[:space:]]*\.clearpath/approvals/ ]]; then return 1; fi
  # Allowed patterns:
  #   test -f .clearpath/approvals/<single>
  #   [ -f .clearpath/approvals/<single> ]
  #   ls .clearpath/approvals[/...]
  #   cat .clearpath/approvals/<single>
  if [[ "$cmd" =~ ^[[:space:]]*test[[:space:]]+-f[[:space:]]+\.clearpath/approvals/[^[:space:]]+[[:space:]]*$ ]]; then return 0; fi
  if [[ "$cmd" =~ ^[[:space:]]*\[[[:space:]]+-f[[:space:]]+\.clearpath/approvals/[^[:space:]]+[[:space:]]+\][[:space:]]*$ ]]; then return 0; fi
  if [[ "$cmd" =~ ^[[:space:]]*ls[[:space:]]+\.clearpath/approvals([[:space:]]+[^[:space:]]+)?[[:space:]]*$ ]]; then return 0; fi
  if [[ "$cmd" =~ ^[[:space:]]*cat[[:space:]]+\.clearpath/approvals/[^[:space:]]+[[:space:]]*$ ]]; then return 0; fi
  return 1
}

if [[ "$TOOL_NAME" =~ ^(Edit|Write|MultiEdit)$ ]]; then
  if is_approval_path "$NORM_PATH"; then
    deny "Clearpath approval files cannot be created or edited by Claude tools. Claude cannot create or modify approval sentinels. User must create/remove approval files manually."
  fi
  if is_secret_path "$NORM_PATH" && ! allow_sentinel "allow-secret-edit"; then
    deny "Clearpath safety gate: editing env/secret credential files requires manual user approval outside Claude Code."
  fi
fi

if [[ "$TOOL_NAME" == "Bash" ]]; then
  # Approval sentinel fail-closed: any reference to .clearpath/approvals,
  # any APPROVAL document, or any explicit sentinel name => deny, unless
  # the command is a narrow read-only check.
  if command_mentions_approval "$LOWER_COMMAND"; then
    if ! is_safe_approval_read "$LOWER_COMMAND"; then
      deny "Clearpath approval sentinels cannot be created, modified, or removed by Claude Bash commands. Claude cannot create or modify approval sentinels. User must approve manually outside Claude Code."
    fi
  fi

  if grep -Eiq '(^|[;&|[:space:]])rm[[:space:]]+-[^;&|\n]*r[^;&|\n]*f|(^|[;&|[:space:]])sudo[[:space:]]+rm[[:space:]]+-|chmod[[:space:]]+-r[[:space:]]+777|chown[[:space:]]+-r' <<< "$LOWER_COMMAND"; then
    if ! allow_sentinel "allow-destructive-shell"; then
      deny "Clearpath safety gate: destructive shell command blocked. Manual approval sentinel required."
    fi
  fi

  # Destructive file-tree removal via find -delete or python shutil.rmtree.
  if grep -Eiq '(^|[;&|[:space:]])find[[:space:]]+[^;&|\n]*-delete|(^|[;&|[:space:]])find[[:space:]]+[^;&|\n]*-exec[[:space:]]+rm' <<< "$LOWER_COMMAND"; then
    if ! allow_sentinel "allow-destructive-shell"; then
      deny "Clearpath safety gate: destructive find command blocked. Manual approval sentinel required."
    fi
  fi
  if grep -Eiq 'python3?[[:space:]]+([[:graph:]]+[[:space:]]+)?-c[[:space:]]+["'\'']?[^"'\'']*shutil[[:space:]]*\.[[:space:]]*rmtree' <<< "$LOWER_COMMAND"; then
    if ! allow_sentinel "allow-destructive-shell"; then
      deny "Clearpath safety gate: destructive python shutil.rmtree blocked. Manual approval sentinel required."
    fi
  fi
  if grep -Eiq '(^|[;&|[:space:]])make[[:space:]]+(install|uninstall|clean|install-[^;&|\n]*)([;&|[:space:]]|$)' <<< "$LOWER_COMMAND"; then
    if ! allow_sentinel "allow-destructive-shell"; then
      deny "Clearpath safety gate: make install/clean blocked. Manual approval sentinel required."
    fi
  fi

  if grep -Eiq '(^|[;&|[:space:]])curl[[:space:]][^|;&]*[|][[:space:]]*(sh|bash)|(^|[;&|[:space:]])wget[[:space:]][^|;&]*[|][[:space:]]*(sh|bash)' <<< "$LOWER_COMMAND"; then
    deny "Clearpath safety gate: piping remote scripts into sh/bash is blocked. Inspect the script and run manually if you accept the risk."
  fi

  # Dependency install / implicit package execution.
  # Optional absolute path prefix so /usr/bin/pip3 install is also gated.
  # e.g. /usr/bin/pip3, /usr/local/bin/npm, /opt/homebrew/bin/deno.
  if grep -Eiq '(^|[;&|[:space:]])(/[[:graph:]]+/)*(npm|pnpm|yarn|bun|bunx|pip3?|pipenv|poetry|uv|cargo|go|playwright|npx|deno|node|make)([[:space:]]+dlx)?[[:space:]]+(install|i|add|ci|upgrade|update|remove|rm|uninstall|pip[[:space:]]+install|sync|get|dlx)([[:space:]]|$)' <<< "$LOWER_COMMAND"; then
    if ! allow_sentinel "allow-dependency-install"; then
      deny "Clearpath dependency gate: dependency installation or implicit package execution requires manual user approval outside Claude Code."
    fi
  fi
  # Explicit dlx / run -A forms, including /usr/bin/deno run -A.
  if grep -Eiq '(^|[;&|[:space:]])(/[[:graph:]]+/)*(yarn[[:space:]]+dlx|pnpm[[:space:]]+dlx|bunx|npx[[:space:]]+-y|deno[[:space:]]+run[[:space:]]+(-a|--allow-all))' <<< "$LOWER_COMMAND"; then
    if ! allow_sentinel "allow-dependency-install"; then
      deny "Clearpath dependency gate: implicit package execution requires manual user approval outside Claude Code."
    fi
  fi

  if grep -Eiq '(drop[[:space:]]+database|drop[[:space:]]+schema|truncate[[:space:]]+table|delete[[:space:]]+from|prisma[[:space:]]+migrate[[:space:]]+reset|rails[[:space:]]+db:drop|sequelize[[:space:]]+db:drop)' <<< "$LOWER_COMMAND"; then
    if ! allow_sentinel "allow-destructive-data"; then
      deny "Clearpath data gate: destructive database/data operation requires manual user approval outside Claude Code."
    fi
  fi

  if grep -Eiq '(^|[;&|[:space:]])(vercel[^\n]*--prod|netlify[^\n]*(--prod|deploy[[:space:]]+--prod)|fly[[:space:]]+deploy|railway[[:space:]]+up|gcloud[[:space:]]+app[[:space:]]+deploy|firebase[[:space:]]+deploy|aws[[:space:]]+.*deploy|kubectl[[:space:]]+(apply|delete|rollout)|helm[[:space:]]+(install|upgrade|delete))([;&|[:space:]]|$)' <<< "$LOWER_COMMAND"; then
    if ! allow_sentinel "allow-production-release"; then
      deny "Clearpath release gate: production or infrastructure deploy command requires explicit manual release approval outside Claude Code."
    fi
  fi

  if grep -Eiq '(^|[;&|[:space:]])(cat|sed|awk|grep|rg|printf|echo|tee|cp|mv|rm|chmod|chown).*(\.env($|\.)|\.npmrc|\.pypirc|\.netrc|id_rsa|id_ed25519|secret|secrets)' <<< "$LOWER_COMMAND"; then
    if ! allow_sentinel "allow-secret-edit"; then
      deny "Clearpath secret gate: command touches env/secret material and requires manual user approval outside Claude Code."
    fi
  fi
fi

exit 0
