#!/usr/bin/env bash
# Shared Python 3 discovery for Clearpath shell entrypoints.

CLEARPATH_PYTHON_CMD=()
CLEARPATH_PYTHON_LABEL=""
CLEARPATH_PYTHON_VERSION=""
CLEARPATH_PYTHON_ERROR=""

_clearpath_python_first_line() {
  local text="${1//$'\r'/}"
  printf '%s' "${text%%$'\n'*}"
}

_clearpath_python_exists() {
  local exe="$1"
  if [[ "$exe" == */* || "$exe" == *\\* ]]; then
    [[ -x "$exe" ]]
  else
    command -v "$exe" >/dev/null 2>&1
  fi
}

_clearpath_python_join_cmd() {
  local out="" part
  for part in "$@"; do
    out+="${out:+ }$part"
  done
  printf '%s' "$out"
}

clearpath_python_try_candidate() {
  local label="$1"
  shift
  local exe="${1:-}"
  local out major version

  if [[ -z "$exe" ]] || ! _clearpath_python_exists "$exe"; then
    CLEARPATH_PYTHON_ERROR="not found"
    return 1
  fi

  if ! out="$("$@" -c 'import sys; print(sys.version_info.major)' 2>&1)"; then
    CLEARPATH_PYTHON_ERROR="$(_clearpath_python_first_line "$out")"
    return 1
  fi

  out="${out//$'\r'/}"
  major="${out%%$'\n'*}"
  if [[ "$major" != "3" ]]; then
    CLEARPATH_PYTHON_ERROR="expected Python 3, got major version ${major:-unknown}"
    return 1
  fi

  if version="$("$@" --version 2>&1)"; then
    version="$(_clearpath_python_first_line "$version")"
  else
    version="Python 3"
  fi

  CLEARPATH_PYTHON_CMD=("$@")
  CLEARPATH_PYTHON_LABEL="$label"
  CLEARPATH_PYTHON_VERSION="$version"
  CLEARPATH_PYTHON_ERROR=""
  return 0
}

clearpath_find_python() {
  CLEARPATH_PYTHON_CMD=()
  CLEARPATH_PYTHON_LABEL=""
  CLEARPATH_PYTHON_VERSION=""
  CLEARPATH_PYTHON_ERROR=""

  if [[ -n "${CLEARPATH_PYTHON:-}" ]]; then
    clearpath_python_try_candidate "CLEARPATH_PYTHON" "$CLEARPATH_PYTHON"
    return $?
  fi

  clearpath_python_try_candidate "python" python && return 0
  clearpath_python_try_candidate "python3" python3 && return 0
  clearpath_python_try_candidate "py -3" py -3 && return 0
  return 1
}

clearpath_python_describe_candidate() {
  local label="$1"
  shift
  local saved_cmd=("${CLEARPATH_PYTHON_CMD[@]}")
  local saved_label="$CLEARPATH_PYTHON_LABEL"
  local saved_version="$CLEARPATH_PYTHON_VERSION"
  local saved_error="$CLEARPATH_PYTHON_ERROR"
  local error version

  if clearpath_python_try_candidate "$label" "$@"; then
    version="$CLEARPATH_PYTHON_VERSION"
    CLEARPATH_PYTHON_CMD=("${saved_cmd[@]}")
    CLEARPATH_PYTHON_LABEL="$saved_label"
    CLEARPATH_PYTHON_VERSION="$saved_version"
    CLEARPATH_PYTHON_ERROR="$saved_error"
    printf 'found (%s)' "$version"
    return 0
  fi

  error="$CLEARPATH_PYTHON_ERROR"
  CLEARPATH_PYTHON_CMD=("${saved_cmd[@]}")
  CLEARPATH_PYTHON_LABEL="$saved_label"
  CLEARPATH_PYTHON_VERSION="$saved_version"
  CLEARPATH_PYTHON_ERROR="$saved_error"

  if [[ "$error" == "not found" ]]; then
    printf 'not found'
  else
    printf 'found but unusable (%s)' "$error"
  fi
  return 1
}

clearpath_python_print_diagnostics() {
  local selected_display
  printf 'Python runtime:\n'
  if [[ -n "${CLEARPATH_PYTHON:-}" ]]; then
    printf '%s' '- CLEARPATH_PYTHON: '
    clearpath_python_describe_candidate "CLEARPATH_PYTHON" "$CLEARPATH_PYTHON" || true
    printf '\n'
  fi
  printf '%s' '- python: '
  clearpath_python_describe_candidate "python" python || true
  printf '\n'
  printf '%s' '- python3: '
  clearpath_python_describe_candidate "python3" python3 || true
  printf '\n'
  printf '%s' '- py -3: '
  clearpath_python_describe_candidate "py -3" py -3 || true
  printf '\n'

  if clearpath_find_python; then
    selected_display="$(_clearpath_python_join_cmd "${CLEARPATH_PYTHON_CMD[@]}")"
    printf '%s\n' "- selected: $CLEARPATH_PYTHON_LABEL ($selected_display; $CLEARPATH_PYTHON_VERSION)"
  else
    printf '%s\n' '- selected: none'
  fi
}

clearpath_python_not_found_message() {
  cat >&2 <<'EOF'
Clearpath could not find a usable Python 3 runtime from this Claude Code shell.

Tried:
- CLEARPATH_PYTHON
- python
- python3
- py -3

Your machine may have Python installed, but it may not be visible to the shell Claude Code uses.
Try:
  python --version
  python3 --version
  py -3 --version
or set CLEARPATH_PYTHON to the full python executable path.
EOF
}
