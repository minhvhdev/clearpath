#!/usr/bin/env bash
# python-discovery-test.sh
# Verifies Clearpath chooses a usable Python 3 from the current Claude Code shell.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local label="$1" file="$2" needle="$3"
  if grep -Fq -- "$needle" "$file"; then
    echo "PASS: $label"
  else
    echo "FAIL: $label missing: $needle" >&2
    echo "--- output ---" >&2
    cat "$file" >&2
    echo "--------------" >&2
    exit 1
  fi
}

make_fake_python() {
  local path="$1" label="$2"
  cat > "$path" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
label="__LABEL__"
: "${FAKE_PYTHON_LOG:?FAKE_PYTHON_LOG required}"
printf '%s\n' "$label $*" >> "$FAKE_PYTHON_LOG"
case "${1:-}" in
  -c)
    if [[ "${2:-}" == *'sys.version_info.major'* ]]; then
      printf '3\n'
      exit 0
    fi
    printf 'fake python only supports version probe\n' >&2
    exit 42
    ;;
  --version)
    printf 'Python 3.12.0\n'
    exit 0
    ;;
  *.py)
    printf '{"ok": true, "fake_python": "%s"}\n' "$label"
    exit 0
    ;;
  *)
    printf 'unsupported fake python invocation: %s\n' "$*" >&2
    exit 42
    ;;
esac
SH
  perl -0pi -e "s/__LABEL__/$label/g" "$path"
  chmod +x "$path"
}

make_failing_launcher() {
  local path="$1" label="$2"
  cat > "$path" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
label="__LABEL__"
if [[ -n "${FAKE_PYTHON_LOG:-}" ]]; then
  printf '%s\n' "$label $*" >> "$FAKE_PYTHON_LOG"
fi
printf 'Python launcher not available: Python was not found from fake %s\n' "$label" >&2
exit 49
SH
  perl -0pi -e "s/__LABEL__/$label/g" "$path"
  chmod +x "$path"
}

# 1. Discovery uses python when python is available. python3 exists but is unusable.
CASE1="$WORK/case1"
mkdir -p "$CASE1/bin" "$CASE1/project"
make_fake_python "$CASE1/bin/python" "python"
make_failing_launcher "$CASE1/bin/python3" "python3"
make_failing_launcher "$CASE1/bin/py" "py"
: > "$CASE1/log"
FAKE_PYTHON_LOG="$CASE1/log" PATH="$CASE1/bin:$PATH" "$ROOT/bin/clearpath-index" "$CASE1/project" > "$CASE1/out" 2>&1 \
  || fail "clearpath-index should use python before python3/py"
assert_contains "clearpath-index selected python" "$CASE1/log" "python "
if grep -Eq '^(python3|py) ' "$CASE1/log"; then
  echo "--- python log ---" >&2
  cat "$CASE1/log" >&2
  fail "clearpath-index tried python3 or py after python worked"
fi

# 2. CLEARPATH_PYTHON override works even when PATH python candidates fail.
CASE2="$WORK/case2"
mkdir -p "$CASE2/bin" "$CASE2/project"
make_fake_python "$CASE2/override-python" "override"
make_failing_launcher "$CASE2/bin/python" "python"
make_failing_launcher "$CASE2/bin/python3" "python3"
make_failing_launcher "$CASE2/bin/py" "py"
: > "$CASE2/log"
FAKE_PYTHON_LOG="$CASE2/log" CLEARPATH_PYTHON="$CASE2/override-python" PATH="$CASE2/bin:$PATH" "$ROOT/bin/clearpath-index" "$CASE2/project" > "$CASE2/out" 2>&1 \
  || fail "clearpath-index should use CLEARPATH_PYTHON override"
assert_contains "CLEARPATH_PYTHON override selected" "$CASE2/log" "override "
if grep -Eq '^(python|python3|py) ' "$CASE2/log"; then
  echo "--- python log ---" >&2
  cat "$CASE2/log" >&2
  fail "clearpath-index tried PATH candidates despite CLEARPATH_PYTHON override"
fi

# 3. Invalid CLEARPATH_PYTHON fails clearly, not with the vague Windows Store launcher message only.
CASE3="$WORK/case3"
mkdir -p "$CASE3/bin" "$CASE3/project"
make_fake_python "$CASE3/bin/python" "python"
: > "$CASE3/log"
if FAKE_PYTHON_LOG="$CASE3/log" CLEARPATH_PYTHON="$CASE3/missing-python" PATH="$CASE3/bin:$PATH" "$ROOT/bin/clearpath-index" "$CASE3/project" > "$CASE3/out" 2>&1; then
  fail "invalid CLEARPATH_PYTHON should fail"
fi
assert_contains "invalid override reports Clearpath runtime error" "$CASE3/out" "Clearpath could not find a usable Python 3 runtime from this Claude Code shell."
assert_contains "invalid override suggests CLEARPATH_PYTHON" "$CASE3/out" "set CLEARPATH_PYTHON to the full python executable path"

# 3b. Invalid CLEARPATH_PYTHON also fails clearly during init instead of claiming success.
CASE3B="$WORK/case3b"
mkdir -p "$CASE3B/bin" "$CASE3B/project"
make_fake_python "$CASE3B/bin/python" "python"
: > "$CASE3B/log"
if FAKE_PYTHON_LOG="$CASE3B/log" CLEARPATH_PYTHON="$CASE3B/missing-python" PATH="$CASE3B/bin:$PATH" "$ROOT/bin/clearpath-init" "$CASE3B/project" > "$CASE3B/out" 2>&1; then
  fail "invalid CLEARPATH_PYTHON should fail during init"
fi
assert_contains "invalid init override reports Clearpath runtime error" "$CASE3B/out" "Clearpath could not find a usable Python 3 runtime from this Claude Code shell."
assert_contains "invalid init override suggests CLEARPATH_PYTHON" "$CASE3B/out" "set CLEARPATH_PYTHON to the full python executable path"

# 4. Doctor reports project-not-initialized separately from plugin/Python failure.
CASE4="$WORK/case4"
mkdir -p "$CASE4/bin" "$CASE4/project/.clearpath/docs"
make_fake_python "$CASE4/bin/python" "python"
make_failing_launcher "$CASE4/bin/python3" "python3"
make_failing_launcher "$CASE4/bin/py" "py"
printf 'active_change_id: none\ncurrent_phase: unknown\n' > "$CASE4/project/.clearpath/docs/STATE.md"
: > "$CASE4/log"
FAKE_PYTHON_LOG="$CASE4/log" PATH="$CASE4/bin:$PATH" "$ROOT/scripts/clearpath-doctor.sh" "$CASE4/project" > "$CASE4/out" 2>&1 \
  || fail "doctor should not fail only because project artifacts are not initialized"
assert_contains "doctor prints Python diagnostics" "$CASE4/out" "Python runtime:"
assert_contains "doctor marks python found" "$CASE4/out" "- python: found"
assert_contains "doctor selects python" "$CASE4/out" "- selected: python"
assert_contains "doctor separates uninitialized project" "$CASE4/out" "Project initialization: NOT INITIALIZED"
assert_contains "doctor gives init next step" "$CASE4/out" "Next step: run /clearpath:init"
if grep -Fq 'Python launcher not available' "$CASE4/out" && ! grep -Fq 'Python runtime:' "$CASE4/out"; then
  fail "doctor emitted launcher error without Clearpath Python diagnostics"
fi

echo "PASS: python discovery test"
