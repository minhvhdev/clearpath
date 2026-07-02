---
description: Maintain the Clearpath Context Ledger and progressive artifact retrieval index.
---
# /clearpath:artifact-index


Use this when artifacts are growing or session recovery feels noisy.

Actions:
1. Run `clearpath-index` to refresh `ARTIFACT_INDEX.json`.
2. Ensure `BOOT.md` and `CURRENT_CONTEXT.md` stay compact.
3. Check every active change has `CHANGE_INDEX.md`.
4. Prefer summaries and pointers over copying evidence/source code.
5. Run `clearpath-artifact-lint`.


## Clearpath invariants

- Do not treat artifacts as automatic context. Read `.clearpath/docs/BOOT.md`, then `CURRENT_CONTEXT.md`, then the active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for symbol/navigation, Codebase-Memory for large-repo knowledge, and Chrome DevTools MCP for browser QA.
- Dispatch a fresh-context subagent for heavy research, planning, execution, review, or QA -- see `docs/SUBAGENT_DISPATCH.md` for concrete thresholds (roughly >15 files/>2,000 lines to read, >8 turns of work, or any review/QA/security lens, which is always fresh-context).
- Do not implement production UI before the user approves the design in chat.
- Record durable product/change state in artifacts, but summarize current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.

