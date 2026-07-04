#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

PROJECT="$WORK/project"
mkdir -p "$PROJECT"

FAKE_PY="$WORK/python"
cat > "$FAKE_PY" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
case "${1:-}" in
  -c)
    printf '3\n'
    ;;
  *.py)
    printf '{"ok": true}\n'
    ;;
  --version)
    printf 'Python 3.12.0\n'
    ;;
  *)
    printf 'unsupported fake python invocation: %s\n' "$*" >&2
    exit 42
    ;;
esac
SH
chmod +x "$FAKE_PY"

CLEARPATH_PYTHON="$FAKE_PY" bash "$ROOT/scripts/clearpath-init.sh" "$PROJECT" > "$WORK/out"

for path in \
  "$PROJECT/CLAUDE.md" \
  "$PROJECT/.cursorrules" \
  "$PROJECT/.cursor/rules/clearpath.mdc" \
  "$PROJECT/.cursor/rules/clearpath-autopilot.mdc"; do
  [[ -f "$path" ]] || {
    echo "FAIL: missing $path" >&2
    cat "$WORK/out" >&2
    exit 1
  }
done

echo "PASS: clearpath init backfills Cursor rules"
