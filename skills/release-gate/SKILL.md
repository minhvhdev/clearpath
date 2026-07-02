---
description: Handle release decisions and deploy when the user requests it.
---
# /clearpath:release-gate

Run the Release Gate.

Clarify desired action:
- hold for manual review,
- create PR,
- deploy staging,
- deploy production.

Record the decision in `RELEASE_DECISION.md` and proceed when the
user confirms.

## Clearpath invariants

- Do not treat artifacts as automatic context. Read `.clearpath/docs/BOOT.md`, then `CURRENT_CONTEXT.md`, then the active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for symbol/navigation, Codebase-Memory for large-repo knowledge, and Chrome DevTools MCP for browser QA.
- Record durable product/change state in artifacts, but summarize current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.
