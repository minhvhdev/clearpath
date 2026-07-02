---
description: Continue development on a project that already uses Clearpath artifacts.
---
# /clearpath:update

For normal usage, `/clearpath:go` is the default entrypoint. This
skill is also called internally by the autopilot router when the
detected mode is `existing-clearpath-project`.

Use this when `.clearpath/docs/BOOT.md` or other Clearpath artifacts already exist.

Workflow:
1. Read `BOOT.md` and `CURRENT_CONTEXT.md` only.
2. Use `ARTIFACT_INDEX.json` and the active `CHANGE_INDEX.md` to find the smallest relevant artifact set.
3. Parse the new change request and decide whether it is product, UI, architecture, bug, refactor, QA, or release work.
4. Create or update a change pack under `.clearpath/docs/changes/<change-id>/`.
5. Use Serena/Codebase-Memory only for relevant code areas.
6. Follow the unified delivery loop from Discuss/Spec through Release Candidate.
7. Update summaries and indexes after each phase.
8. Update `.clearpath/docs/AUTOPILOT.md` with the active change id,
   current phase, design approval status, implementation status,
   verification status, release candidate status, open blockers,
   next expected action, and last-updated timestamp. The file is
   continuity metadata, not a governance gate. The SessionStart
   and UserPromptSubmit hooks are read-only and never write this
   file.


## Clearpath invariants

- Do not treat artifacts as automatic context. Read `.clearpath/docs/BOOT.md`, then `CURRENT_CONTEXT.md`, then the active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for symbol/navigation, Codebase-Memory for large-repo knowledge, and Chrome DevTools MCP for browser QA.
- Dispatch a fresh-context subagent for heavy research, planning, execution, review, or QA -- see `docs/SUBAGENT_DISPATCH.md` for concrete thresholds (roughly >15 files/>2,000 lines to read, >8 turns of work, or any review/QA/security lens, which is always fresh-context).
- Do not implement production UI before the user approves the design in chat.
- Record durable product/change state in artifacts, but summarize current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.

