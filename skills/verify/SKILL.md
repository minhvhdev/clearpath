---
description: Verify implementation with tests, build, browser QA, and evidence. Routes to verify-web or verify-windows based on platform.
---

# /clearpath:verify


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
  `docs/clearpath/BOOT.md`, then `CURRENT_CONTEXT.md`, then the
  active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for
  symbol/navigation, Codebase-Memory for large-repo knowledge, and
  Chrome DevTools MCP for browser QA.
- Keep the main session as orchestrator. Use focused subagents for
  heavy research, planning, execution, review, and QA.
- Do not implement production UI before design approval exists.
- Do not install dependencies, edit secrets, run destructive data
  commands, or deploy production without manual user approval
  outside Claude Code.
- Record durable product/change state in artifacts, but summarize
  current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.
