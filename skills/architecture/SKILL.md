---
description: Analyze codebase impact and architecture before non-trivial backend/system changes.
---
# /clearpath:architecture


Run Architecture Review.

Use Codebase-Memory for large repo discovery and Serena for symbols/references. Produce:
- `IMPACT_ANALYSIS.md`.
- Affected modules and files.
- Interfaces/contracts impacted.
- Data, auth, permission, and deployment risks.
- Test strategy.

Do not implement until impact is evidence-backed.


## Clearpath invariants

- Do not treat artifacts as automatic context. Read `docs/clearpath/BOOT.md`, then `CURRENT_CONTEXT.md`, then the active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for symbol/navigation, Codebase-Memory for large-repo knowledge, and Chrome DevTools MCP for browser QA.
- Keep the main session as orchestrator. Use focused subagents for heavy research, planning, execution, review, and QA.
- Do not implement production UI before design approval exists.
- Do not install dependencies, edit secrets, run destructive data commands, or deploy production without manual user approval outside Claude Code.
- Record durable product/change state in artifacts, but summarize current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.

