# Project Instructions for Clearpath

Clearpath is active for this project.

At session start:
1. Read `docs/clearpath/BOOT.md`.
2. Read `docs/clearpath/CURRENT_CONTEXT.md`.
3. Use `docs/clearpath/ARTIFACT_INDEX.json` and the active `CHANGE_INDEX.md` before reading any detailed artifact.

Do not import Clearpath artifacts with `@` syntax. Artifacts are durable memory, not automatic context.

Do not read all of `docs/clearpath/**` or `docs/changes/**`. Use progressive retrieval.

Approval sentinels under `.clearpath/approvals/` must be created manually by the user outside Claude Code. Claude tools must not create, edit, or remove them, and the safety gate denies any `Bash` command that mentions approval paths, sentinel filenames, or `*_APPROVAL.*` documents. Only narrow read-only checks (`test -f`, `[ -f ]`, `ls`, `cat`) against the approval directory are allowed.

Production UI changes under `components/`, `app/`, `pages/`, `src/`, `source/`, `mobile/`, `screens/`, `widgets/`, or `lib/widgets/` are blocked by the design gate until the user creates `.clearpath/approvals/design-approved`. The gate now covers `Edit|Write|MultiEdit` and `Bash` writes.

Post-approval autonomy follows `/clearpath:autonomy`. After design and scope are approved, the agent may run the code -> test -> fix -> retest loop without asking, except where the contract says it must stop.

For web verification, use `/clearpath:verify-web` (Playwright for regression/E2E, Chrome DevTools MCP for live inspect/debug). For Windows native verification, use `/clearpath:verify-windows` (CursorTouch/Windows-MCP, opt-in, default-deny for PowerShell/Registry/FileSystem/Process).

For project design reviews, run `/clearpath:taste-design` (product taste, concept, brand, UX direction) and `/clearpath:impeccable` (UI craft, execution polish) before design approval. The `design-critic` agent aggregates both.
