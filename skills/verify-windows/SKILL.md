---
description: Windows native/desktop verification workflow. CursorTouch/Windows-MCP for user-like UI testing. Default-deny stance for PowerShell/Registry/FileSystem/Process.
---

# /clearpath:verify-windows

For normal usage, `/clearpath:go` is the default entrypoint. This
skill is called by the autopilot router when the user request
involves Windows native or Electron/WebView2 verification.

Windows native / desktop verification. Use CursorTouch or
Windows-MCP for user-like UI testing. Do not use Playwright or
Chrome DevTools MCP as the primary solution for Windows native apps.

## Platform distinction

- **Web app / browser UI** -> use `/clearpath:verify-web`
  (Playwright + Chrome DevTools MCP).
- **Electron / WebView2** -> use Chrome DevTools MCP for the
  embedded renderer when CDP/devtools is available; use Windows-MCP
  for shell, window, native dialogs, tray, menu interactions.
- **Windows native desktop app** (Win32, WinUI 3, MAUI desktop,
  WPF, Qt-on-Windows) -> use CursorTouch/Windows-MCP. Playwright
  and Chrome DevTools MCP are not the primary solution unless the
  app exposes a browser or webview runtime.

## Windows-MCP role

Windows-MCP / CursorTouch drives the desktop like a real user:

- launch or focus the app,
- inspect the UI tree via `Snapshot`,
- capture `Screenshot` for visual evidence,
- interact via `Click`, `Type`, `Scroll`, `Move`, `Shortcut`,
- wait for state with `Wait` / `WaitFor`,
- control the app window with `App`,
- read `Clipboard` if a test needs it.

## Safety boundary (default-deny)

Windows-MCP must be opt-in. Do not enable it globally for every
project; it is only relevant for Windows native / Electron desktop
projects.

Default allowed tools (safe user-interaction surface):

- Screenshot
- Snapshot
- Click
- Type
- Scroll
- Move
- Shortcut
- Wait
- WaitFor
- App
- Clipboard

Default deny / opt-in only (do not enable without explicit user
approval):

- PowerShell
- Registry
- FileSystem
- Process

If the project template or `.mcp.json` would spawn Windows-MCP for
every project, do not add it to default MCP. Document it as an
optional MCP and provide an opt-in example in the docs.

The hooks do not currently know about Windows-MCP. The opt-in
boundary is enforced by the project's MCP config and the operator's
review of that config. This is a known limitation; treat Windows-MCP
as opt-in by project.

## Required workflow

1. Confirm the app type: web, Electron/WebView2, or Windows native.
2. For Windows native, confirm Windows-MCP is configured for this
   project and that the dangerous tools (PowerShell, Registry,
   FileSystem, Process) are not enabled.
3. Use `App` to launch or focus the target app.
4. Use `Snapshot` to inspect the UI tree.
5. Use `Screenshot` for visual evidence.
6. Interact using `Click`, `Type`, `Shortcut`, `Scroll`.
7. Use `Wait` / `WaitFor` for the expected UI state.
8. Record QA evidence and any limitations.
9. Do not use PowerShell, Registry, FileSystem, or Process tools
   unless the user has explicitly approved them for this test.

## Reporting

`QA.md` and `VERIFY.md` should record:

- which Windows-MCP tools were used,
- which flows were tested and which screenshots were captured,
- which tools were denied because they are not opted in,
- any `NOT RUN` reasons.

## Clearpath invariants

- Do not treat artifacts as automatic context. Read
  `.clearpath/docs/BOOT.md`, then `CURRENT_CONTEXT.md`, then the
  active `CHANGE_INDEX.md` before drilling into details.
- Do not implement production UI before the user approves the design
  in chat.
- Windows-MCP is a project opt-in, not a global default.
- Keep the main session as orchestrator. Use focused subagents for
  long debug sessions.
