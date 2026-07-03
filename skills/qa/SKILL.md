---
description: Run browser-oriented QA using Chrome DevTools MCP. For dedicated web verification (Playwright + DevTools MCP), use /clearpath:verify-web. For Windows native, use /clearpath:verify-windows.
---

# /clearpath:qa


Run Chrome QA for the current platform.

If the app is web UI, see `/clearpath:verify-web` for the role
split between Playwright (regression/E2E) and Chrome DevTools MCP
(live inspect/debug). Use `/clearpath:qa` for the live DevTools MCP
evidence portion.

If the app is Windows native, see `/clearpath:verify-windows` and
do not use Chrome DevTools MCP as the primary solution.

Use Chrome DevTools MCP to inspect the real app when possible.
Capture summary evidence, not raw logs by default:

- Happy path.
- Empty/loading/error states.
- Responsive behavior.
- Console errors.
- Failed network requests.
- Accessibility/performance notes if available.

Write concise evidence to `QA.md` and put raw details under
`evidence/` with an `EVIDENCE_INDEX.md`.

Apply `/clearpath:review-qa-discipline` when turning those signals
into a QA verdict: base conclusions on evidence, call out unverified
areas explicitly, and do not mark pass/fail on stale runs.

When using Chrome DevTools MCP `take_screenshot`, **always** pass
`filePath` pointing into the active change pack's `evidence/`
folder (see `BOOT.md` — Screenshot evidence). Do not rely on the
MCP temp-folder default.


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
