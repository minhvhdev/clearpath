---
description: Initialize Clearpath artifacts in the current repository without reading the whole codebase.
---
# /clearpath:init

For normal usage, `/clearpath:go` is the default entrypoint. This
skill is also called internally by the autopilot router when the
detected mode is `new-empty-project` or `new-scaffolded-project`.

Initialize Clearpath project artifacts.

Steps:
1. Explain that initialization creates durable project memory under `docs/clearpath/`, `docs/changes/`, and `.clearpath/approvals/`.
2. Run `clearpath-init` from the project root if the user approves initialization.
3. Read `docs/clearpath/BOOT.md` and `docs/clearpath/CURRENT_CONTEXT.md` after initialization.
4. Select one of the three workflows: new product, existing Clearpath project, or adoption of an existing non-Clearpath product.
5. Create or update `docs/clearpath/AUTOPILOT.md`. This file is
   continuity metadata for the Clearpath Autopilot, not a
   governance gate. Fill these fields: Detected mode, Last route,
   Current phase, Design approval status, Implementation status,
   Verification status, Release candidate status, Open blockers,
   Next expected action, Last updated (ISO 8601 timestamp). The
   SessionStart and UserPromptSubmit hooks are read-only and
   never write this file; only the workflow skills that actually
   run do. The template is at
   `templates/project/docs/clearpath/AUTOPILOT.md` for reference.


## Clearpath invariants

- Do not treat artifacts as automatic context. Read `docs/clearpath/BOOT.md`, then `CURRENT_CONTEXT.md`, then the active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for symbol/navigation, Codebase-Memory for large-repo knowledge, and Chrome DevTools MCP for browser QA.
- Keep the main session as orchestrator. Use focused subagents for heavy research, planning, execution, review, and QA.
- Do not implement production UI before design approval exists.
- Do not install dependencies, edit secrets, run destructive data commands, or deploy production without manual user approval outside Claude Code.
- Record durable product/change state in artifacts, but summarize current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.

