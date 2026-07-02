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

- Do not treat artifacts as automatic context. Read `docs/clearpath/BOOT.md`, then `CURRENT_CONTEXT.md`, then the active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for symbol/navigation, Codebase-Memory for large-repo knowledge, and Chrome DevTools MCP for browser QA.
- Keep the main session as orchestrator. Use focused subagents for heavy research, planning, execution, review, and QA.
- Do not implement production UI before design approval exists.
- Do not install dependencies, edit secrets, run destructive data commands, or deploy production without manual user approval outside Claude Code.
- Record durable product/change state in artifacts, but summarize current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.

