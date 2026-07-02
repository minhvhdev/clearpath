---
description: Archive completed phases and compact durable state for future sessions.
---
# /clearpath:archive


Run Archive/Learn.

Actions:
1. Update `STATE.md`, `CURRENT_CONTEXT.md`, `DECISIONS.md`, and `ARTIFACT_INDEX.json`.
2. Mark completed artifacts canonical/superseded/archived.
3. Write `PHASE_ARCHIVE.md` with what changed, why, and next actions.
4. Keep `BOOT.md` and `CURRENT_CONTEXT.md` small.


## Clearpath invariants

- Do not treat artifacts as automatic context. Read `.clearpath/docs/BOOT.md`, then `CURRENT_CONTEXT.md`, then the active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for symbol/navigation, Codebase-Memory for large-repo knowledge, and Chrome DevTools MCP for browser QA.
- Dispatch a fresh-context subagent for heavy research, planning, execution, review, or QA -- see `docs/SUBAGENT_DISPATCH.md` for concrete thresholds (roughly >15 files/>2,000 lines to read, >8 turns of work, or any review/QA/security lens, which is always fresh-context).
- Do not implement production UI before the user approves the design in chat.
- Record durable product/change state in artifacts, but summarize current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.

