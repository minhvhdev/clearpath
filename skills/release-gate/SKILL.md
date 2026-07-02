---
description: Handle explicit release approval and release decision artifacts.
---
# /clearpath:release-gate


Run the Release Gate.

Clarify desired action:
- hold for manual review,
- create PR,
- deploy staging,
- deploy production.

Production/infrastructure deploys require manual approval outside Claude Code. Record the decision in `RELEASE_DECISION.md`; do not treat this artifact as authorization by itself.


## Clearpath invariants

- Do not treat artifacts as automatic context. Read `docs/clearpath/BOOT.md`, then `CURRENT_CONTEXT.md`, then the active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for symbol/navigation, Codebase-Memory for large-repo knowledge, and Chrome DevTools MCP for browser QA.
- Dispatch a fresh-context subagent for heavy research, planning, execution, review, or QA -- see `docs/SUBAGENT_DISPATCH.md` for concrete thresholds (roughly >15 files/>2,000 lines to read, >8 turns of work, or any review/QA/security lens, which is always fresh-context).
- Do not implement production UI before design approval exists.
- Do not install dependencies, edit secrets, run destructive data commands, or deploy production without manual user approval outside Claude Code.
- Record durable product/change state in artifacts, but summarize current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.

