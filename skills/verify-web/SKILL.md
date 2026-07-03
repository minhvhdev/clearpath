---
description: Web verification workflow. Playwright for regression/E2E tests, Chrome DevTools MCP for live inspect/debug. Distinguishes the two roles explicitly.
---

# /clearpath:verify-web

For normal usage, `/clearpath:go` is the default entrypoint. This
skill is called by the autopilot router when the user request
involves web UI verification.

Web verification splits two roles. They are not interchangeable.

- **Playwright test/CLI** is the official regression/E2E runner.
  Use it for durable tests that run in local and CI. Tests are
  evidence for the release candidate.
- **Chrome DevTools MCP** is the live inspect/debug tool. Use it to
  observe the running app like a real user: DOM, console, network,
  screenshots, runtime behavior, locator and state issues.

Chrome DevTools MCP does not replace Playwright regression tests.
Playwright does not replace live debugging with DevTools MCP. Use
both when validating important web flows.

## Required workflow

1. Confirm the app type is web (browser-rendered). For Electron or
   WebView2 see `/clearpath:verify-windows`.
2. Open/inspect the app with Chrome DevTools MCP when available.
3. Identify the user flow, state, selectors/locators, and any
   console/network issues. Take screenshots when they help — **always**
   pass `filePath` on `take_screenshot` (see `BOOT.md` — Screenshot
   evidence). Save under
   `.clearpath/docs/changes/<change-id>/evidence/<name>.png` and link
   paths in `QA.md`.
4. Write or update Playwright tests under the project convention.
   Default to `tests/e2e/`. Use the existing repo convention if
   one is present.
5. Run the Playwright CLI:
   - `npx playwright test` — full run.
   - `npx playwright test --headed` — when visual debugging helps.
   - `npx playwright test --debug` — only when needed.
   - `npx playwright show-report` — after a run when useful.
6. If Playwright fails, use the trace/report and Chrome DevTools MCP
   together to debug. The DevTools MCP session is the human-eye
   view; the trace is the recorded timeline.
7. Fix the app or the test. Re-run Playwright until it passes or
   until the failure is documented as `NOT RUN` with a reason.
8. Record evidence in `QA.md` (or `VERIFY.md`) and the release
   candidate artifact. Link the Playwright report path.

## Test path convention

- Web E2E tests should live in `tests/e2e/` unless the host repo
  already has a convention.
- Use the existing repo convention if present (e.g., a `playwright/`
  directory, an `e2e/` at root, or a monorepo package). Do not
  impose `tests/e2e/` on a repo that has chosen otherwise.
- If no convention exists and you create `tests/e2e/`, mention it in
  the project's `BOOT.md` or `CONVENTIONS.md` so the next agent
  finds it.

## Roles do not overlap

- DevTools MCP output is not a regression test. A clean DevTools
  session does not mean a flow is regression-safe.
- A passing Playwright test does not mean the app is healthy under
  user-like interaction. A test can pass on a snapshot that no real
  user ever produces.
- For UI changes, run both. For non-UI logic changes, Playwright
  may be the only step needed.

## Reporting

`QA.md` and `VERIFY.md` should record:

- which flows were tested in Playwright (and the report path),
- which flows were inspected in DevTools MCP (and which screenshots
  were captured),
- which runs were `NOT RUN` and why.

## Clearpath invariants

- Do not treat artifacts as automatic context. Read
  `.clearpath/docs/BOOT.md`, then `CURRENT_CONTEXT.md`, then the
  active `CHANGE_INDEX.md` before drilling into details.
- Do not implement production UI before the user approves the design
  in chat.
- Keep the main session as orchestrator. Use focused subagents for
  writing tests and for debugging failing flows.
