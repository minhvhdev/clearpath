---
description: Create an implementation plan with small verifiable tasks and context packs.
---
# /clearpath:plan


Run the Plan phase.

Plan requirements:
- Small task list.
- Expected files and modules.
- Verification step per task (include TDD cycle: failing test → verify
  fail → minimal code → verify pass per `/clearpath:test-driven-development`).
- Risks and approval needs.
- Subagent context packs for heavy or parallel work.

Save to `PLAN.md` and update `CHANGE_INDEX.md`.


## Clearpath invariants

- Do not treat artifacts as automatic context. Read `.clearpath/docs/BOOT.md`, then `CURRENT_CONTEXT.md`, then the active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for symbol/navigation, Codebase-Memory for large-repo knowledge, and Chrome DevTools MCP for browser QA.
- Dispatch a fresh-context subagent for heavy research, planning, execution, review, or QA -- see `docs/SUBAGENT_DISPATCH.md` for concrete thresholds (roughly >15 files/>2,000 lines to read, >8 turns of work, or any review/QA/security lens, which is always fresh-context).
- Do not implement production UI before the user approves the design in chat.
- Record durable product/change state in artifacts, but summarize current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.

