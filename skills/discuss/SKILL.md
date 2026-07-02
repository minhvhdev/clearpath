---
description: Turn vague user intent into a bounded product/change discussion.
---
# /clearpath:discuss


Run the Discuss phase.

Outputs:
- Product/change summary.
- Target user and job-to-be-done.
- Constraints and non-goals.
- Risks and unknowns.
- Scope decision needed from user, if any.

Save the result into the active `CHANGE.md` and update `CHANGE_INDEX.md`.


## Clearpath invariants

- Do not treat artifacts as automatic context. Read `docs/clearpath/BOOT.md`, then `CURRENT_CONTEXT.md`, then the active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for symbol/navigation, Codebase-Memory for large-repo knowledge, and Chrome DevTools MCP for browser QA.
- Keep the main session as orchestrator. Use focused subagents for heavy research, planning, execution, review, and QA.
- Do not implement production UI before design approval exists.
- Do not install dependencies, edit secrets, run destructive data commands, or deploy production without manual user approval outside Claude Code.
- Record durable product/change state in artifacts, but summarize current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.

