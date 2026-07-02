---
description: Verify implementation with tests, build, browser QA, and evidence. Routes to verify-web or verify-windows based on platform.
---

# /clearpath:verify

For normal usage, `/clearpath:go` is the default entrypoint. This
skill is called by the autopilot router when the user request is
classified as `verify-test`.

Run Verify.

Checks:
- Existing lint/typecheck/test/build commands.
- Targeted regression.
- For web UI: see `/clearpath:verify-web` (Playwright for
  regression/E2E, Chrome DevTools MCP for live inspect/debug).
- For Windows native UI: see `/clearpath:verify-windows`
  (CursorTouch/Windows-MCP for user-like UI testing).
- For other platforms: use the closest platform-specific skill or
  the `qa` skill's Chrome DevTools MCP browser QA.
- Acceptance criteria mapping.
- Security review if risk is present.

Write `QA.md`. Never claim passed without evidence; write "not run"
with reason when a check cannot run. Re-run after a fix; do not
declare done on a stale run.


## Clearpath invariants

- Do not treat artifacts as automatic context. Read
  `.clearpath/docs/BOOT.md`, then `CURRENT_CONTEXT.md`, then the
  active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for
  symbol/navigation, Codebase-Memory for large-repo knowledge, and
  Chrome DevTools MCP for browser QA.
- Dispatch a fresh-context subagent for heavy research, planning,
  execution, review, or QA -- see `docs/SUBAGENT_DISPATCH.md` for
  concrete thresholds (roughly >15 files/>2,000 lines to read, >8
  turns of work, or any review/QA/security lens, which is always
  fresh-context).
- Do not implement production UI before the user approves the design in chat.
- Record durable product/change state in artifacts, but summarize
  current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.
