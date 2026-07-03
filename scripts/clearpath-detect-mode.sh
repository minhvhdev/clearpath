#!/usr/bin/env bash
# clearpath-detect-mode.sh
# Read-only project mode detector for the Clearpath Autopilot.
#
# Reads a project directory and emits a small JSON object describing
# the detected mode, confidence, and recommended routing. The script
# is safe to call from hooks and from the command line. It does not
# create, modify, or delete any file.
#
# Usage:
#   scripts/clearpath-detect-mode.sh                       # cwd
#   CLAUDE_PROJECT_DIR=/path scripts/clearpath-detect-mode.sh
#   echo '{"project_dir":"/path"}' | scripts/clearpath-detect-mode.sh
#   scripts/clearpath-detect-mode.sh --format text         # human-readable
#
# Exit codes:
#   0 - detection ran (even if confidence is low)
#   1 - configuration error
#   2 - jq missing (fail-closed; autopilot requires jq)
set -u

FORMAT="json"
if [[ "${1:-}" == "--format" ]]; then
  FORMAT="${2:-json}"
fi

INPUT=""
if [[ ! -t 0 ]]; then
  INPUT="$(cat 2>/dev/null || true)"
fi
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${CURSOR_PROJECT_DIR:-$(pwd)}}"
if [[ -n "$INPUT" ]]; then
  if command -v jq >/dev/null 2>&1; then
    pd="$(jq -r '.project_dir // empty' <<< "$INPUT" 2>/dev/null || true)"
    if [[ -n "$pd" ]]; then
      PROJECT_DIR="$pd"
    fi
  fi
fi

if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "clearpath-detect-mode: project dir not found: $PROJECT_DIR" >&2
  exit 1
fi

# has_any <dir> <file-or-glob...>
# Supports literal filenames (checked with -e) and glob patterns
# containing `*`/`?` (expanded with nullglob so a non-matching glob
# never falls through as a literal filename check, which previously
# made "*.sln"/"*.csproj" dead code: `[[ -e "$dir/*.sln" ]]` tests for
# a file literally named "*.sln", not a glob expansion).
has_any() {
  local dir="$1"
  shift
  local f
  for f in "$@"; do
    if [[ "$f" == *[*?]* ]]; then
      local -a matches=()
      shopt -s nullglob
      matches=("$dir"/$f)
      shopt -u nullglob
      if [[ ${#matches[@]} -gt 0 ]]; then
        return 0
      fi
    elif [[ -e "$dir/$f" ]]; then
      return 0
    fi
  done
  return 1
}

# Count tracked files in .git (best-effort, no network).
git_tracked_count() {
  local dir="$1"
  if [[ -d "$dir/.git" ]] && command -v git >/dev/null 2>&1; then
    (cd "$dir" && git ls-files 2>/dev/null | wc -l) | tr -d ' '
  else
    echo 0
  fi
}

REASONS=()
ADD_REASON() { REASONS+=("$1"); }

# Existing Clearpath artifacts signal is the strongest.
if has_any "$PROJECT_DIR" ".clearpath/docs/BOOT.md" ".clearpath/docs/CURRENT_CONTEXT.md" ".clearpath/docs" ".clearpath/docs/BOOT.md" ".clearpath/docs/CURRENT_CONTEXT.md"; then
  MODE="existing-clearpath-project"
  CONFIDENCE="high"
  RECOMMENDED="/clearpath:update"
  INTERNAL_ROUTE="/clearpath:update"
  NEXT="Project already has Clearpath artifacts. Read .clearpath/docs/BOOT.md and CURRENT_CONTEXT.md first, then follow the active change pack. Use /clearpath:update for the next request."
  ADD_REASON "Clearpath artifacts present"
  emit_json() {
    jq -nc \
      --arg mode "$MODE" \
      --arg conf "$CONFIDENCE" \
      --arg entry "/clearpath:go" \
      --arg route "$INTERNAL_ROUTE" \
      --arg next "$NEXT" \
      --argjson reasons "$(printf '%s\n' "${REASONS[@]}" | jq -R . | jq -s .)" \
      '{
        clearpath_autopilot: true,
        detected_mode: $mode,
        confidence: $conf,
        recommended_entrypoint: $entry,
        recommended_internal_route: $route,
        reason: $reasons,
        next_behavior: $next
      }'
  }
  emit_text() {
    printf 'mode=%s confidence=%s route=%s\n' "$MODE" "$CONFIDENCE" "$INTERNAL_ROUTE"
  }
else
  # Adopt: any code manifest or src tree, no Clearpath yet.
  ADOPT_HIT=0
  if has_any "$PROJECT_DIR" "package.json" "pnpm-lock.yaml" "yarn.lock" \
                          "requirements.txt" "pyproject.toml" "Pipfile" \
                          "Cargo.toml" "go.mod" "pom.xml" "build.gradle" \
                          "build.gradle.kts" "composer.json" "Gemfile" \
                          "mix.exs" "*.sln" "*.csproj"; then
    ADOPT_HIT=1
    ADD_REASON "code manifest present"
  fi
  if has_any "$PROJECT_DIR" "src" "app" "lib" "pkg" "internal" "cmd" "bin"; then
    ADOPT_HIT=1
    ADD_REASON "source tree present"
  fi
  if [[ -d "$PROJECT_DIR/.git" ]]; then
    ADOPT_HIT=1
    ADD_REASON "git repo present"
  fi

  if [[ "$ADOPT_HIT" -eq 1 ]]; then
    TRACKED="$(git_tracked_count "$PROJECT_DIR")"
    # Heuristic: scaffolded projects usually have < ~10 tracked files
    # or no tracked source. Adopt only if the project looks "real".
    if [[ "$TRACKED" -ge 5 ]] || has_any "$PROJECT_DIR" "src" "app" "lib"; then
      MODE="adopt-existing-project"
      CONFIDENCE="high"
      RECOMMENDED="/clearpath:adopt"
      INTERNAL_ROUTE="/clearpath:adopt"
      NEXT="Project has code but no Clearpath artifacts. Use adopt workflow. Do not read the whole repo. Use Serena and codebase-memory if available. Do not start implementation before PRODUCT_INDEX.json exists."
      emit_json() {
        jq -nc \
          --arg mode "$MODE" \
          --arg conf "$CONFIDENCE" \
          --arg entry "/clearpath:go" \
          --arg route "$INTERNAL_ROUTE" \
          --arg next "$NEXT" \
          --argjson reasons "$(printf '%s\n' "${REASONS[@]}" | jq -R . | jq -s .)" \
          '{
            clearpath_autopilot: true,
            detected_mode: $mode,
            confidence: $conf,
            recommended_entrypoint: $entry,
            recommended_internal_route: $route,
            reason: $reasons,
            next_behavior: $next
          }'
      }
      emit_text() {
        printf 'mode=%s confidence=%s route=%s\n' "$MODE" "$CONFIDENCE" "$INTERNAL_ROUTE"
      }
    else
      MODE="new-scaffolded-project"
      CONFIDENCE="medium"
      RECOMMENDED="/clearpath:go"
      INTERNAL_ROUTE="/clearpath:init"
      NEXT="Project has a manifest but is effectively empty. Run /clearpath:init to create Clearpath artifacts, then /clearpath:start to begin the product workflow."
      emit_json() {
        jq -nc \
          --arg mode "$MODE" \
          --arg conf "$CONFIDENCE" \
          --arg entry "/clearpath:go" \
          --arg route "$INTERNAL_ROUTE" \
          --arg next "$NEXT" \
          --argjson reasons "$(printf '%s\n' "${REASONS[@]}" | jq -R . | jq -s .)" \
          '{
            clearpath_autopilot: true,
            detected_mode: $mode,
            confidence: $conf,
            recommended_entrypoint: $entry,
            recommended_internal_route: $route,
            reason: $reasons,
            next_behavior: $next
          }'
      }
      emit_text() {
        printf 'mode=%s confidence=%s route=%s\n' "$MODE" "$CONFIDENCE" "$INTERNAL_ROUTE"
      }
    fi
  else
    # Empty directory.
    FILE_COUNT=$(find "$PROJECT_DIR" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l | tr -d ' ')
    if [[ "${FILE_COUNT:-0}" -le 1 ]]; then
      MODE="new-empty-project"
      CONFIDENCE="high"
      RECOMMENDED="/clearpath:go"
      INTERNAL_ROUTE="/clearpath:init"
      NEXT="Project is empty. Run /clearpath:init to create Clearpath artifacts, then /clearpath:start to begin the product workflow."
      ADD_REASON "directory is empty or has only one entry"
    else
      MODE="new-empty-project"
      CONFIDENCE="medium"
      RECOMMENDED="/clearpath:go"
      INTERNAL_ROUTE="/clearpath:init"
      NEXT="Project has no Clearpath artifacts and no recognized code manifest. Treat as new. Run /clearpath:init then /clearpath:start."
      ADD_REASON "no clearpath artifacts and no code manifest"
    fi
    emit_json() {
      jq -nc \
        --arg mode "$MODE" \
        --arg conf "$CONFIDENCE" \
        --arg entry "/clearpath:go" \
        --arg route "$INTERNAL_ROUTE" \
        --arg next "$NEXT" \
        --argjson reasons "$(printf '%s\n' "${REASONS[@]}" | jq -R . | jq -s .)" \
        '{
          clearpath_autopilot: true,
          detected_mode: $mode,
          confidence: $conf,
          recommended_entrypoint: $entry,
          recommended_internal_route: $route,
          reason: $reasons,
          next_behavior: $next
        }'
    }
    emit_text() {
      printf 'mode=%s confidence=%s route=%s\n' "$MODE" "$CONFIDENCE" "$INTERNAL_ROUTE"
    }
  fi
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "clearpath-detect-mode: jq is required" >&2
  exit 2
fi

if [[ "$FORMAT" == "text" ]]; then
  emit_text
else
  emit_json
fi
exit 0
