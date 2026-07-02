---
description: Package verified work into a release candidate.
---
# /clearpath:release-candidate

Create `RELEASE_CANDIDATE.md`.

Include:
- Summary and scope.
- Files changed.
- Commands/checks run.
- QA status and evidence pointers.
- Known limitations.
- Migration/deploy notes.
- Rollback plan.
- Release notes.

Present the release candidate to the user. Deploy when the user asks
or when finishing an approved end-to-end delivery.

## Clearpath invariants

- Do not treat artifacts as automatic context. Read `.clearpath/docs/BOOT.md`, then `CURRENT_CONTEXT.md`, then the active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for symbol/navigation, Codebase-Memory for large-repo knowledge, and Chrome DevTools MCP for browser QA.
- Record durable product/change state in artifacts, but summarize current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.
