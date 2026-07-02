---
id: clearpath-boot
type: boot-index
status: active
canonical: true
---
# Clearpath Boot Index

Read this file first. It is the startup index for Clearpath state.

## Reading Rule
Do not read all Clearpath artifacts. Read `CURRENT_CONTEXT.md`, then use `ARTIFACT_INDEX.json` and active `CHANGE_INDEX.md` to retrieve only what the current phase requires.

<!-- CLEARPATH_INDEX_START -->
## Generated Current Pointers
- Current phase: unknown
- Active change: none
- Artifact index: docs/clearpath/ARTIFACT_INDEX.json
- Current context: docs/clearpath/CURRENT_CONTEXT.md
<!-- CLEARPATH_INDEX_END -->

## Workflow Modes
- `new-product`: building from scratch.
- `existing-clearpath`: continuing a project that already uses Clearpath.
- `adopt-existing`: continuing a product that has never used Clearpath.

## Required MCP Layer
- Serena: symbol navigation and reference lookup.
- Codebase-Memory: large-repo indexing and knowledge graph.
- Chrome DevTools: browser QA and runtime evidence.
- CursorTouch/Windows-MCP: Windows native UI testing (opt-in per
  project; default-deny PowerShell/Registry/FileSystem/Process).

## Verification Routing
- Web UI: see `/clearpath:verify-web` for the Playwright (regression
  /E2E) and Chrome DevTools MCP (live inspect/debug) split.
- Windows native UI: see `/clearpath:verify-windows` for
  CursorTouch/Windows-MCP usage and the safety boundary.
- Other platforms: use `/clearpath:qa` Chrome DevTools MCP browser
  QA.

## Approval Sentinels
The user may manually create files under `.clearpath/approvals/` to authorize gated operations. Claude tools are blocked from creating or editing them.

- `design-approved`: allows production UI edits after design approval.
- `allow-dependency-install`: allows dependency install commands.
- `allow-production-release`: allows production/infrastructure deploy commands.
- `allow-destructive-data`: allows destructive DB/data commands.
- `allow-secret-edit`: allows env/secret edits.
- `allow-destructive-shell`: allows destructive shell cleanup.
