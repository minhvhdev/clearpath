---
description: Start a new product from scratch using the full Clearpath delivery loop.
---
# /clearpath:start


Use this when the user is building a product from zero.

Workflow:
1. Initialize/recover artifacts.
2. Discuss product intent, users, jobs-to-be-done, constraints, and non-goals.
3. Write `PRODUCT.md`, `CHANGE.md`, `SPEC.md`, and acceptance criteria for the initial MVP.
4. Produce a local prototype/design direction for any UI.
5. Request design approval before production UI implementation.
6. Build a task plan, execute in small subagent-ready tasks, verify with tests/browser QA, run role review, produce a release candidate, then stop at the Release Gate.

Reference lineage:
- GSD Core: phase loop and context discipline.
- Superpowers: spec-first/TDD/review discipline.
- gstack: CEO/design/engineering/QA/release role review.
- Clearpath: enforced approval gates and durable artifact ledger.


## Clearpath invariants

- Do not treat artifacts as automatic context. Read `docs/clearpath/BOOT.md`, then `CURRENT_CONTEXT.md`, then the active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for symbol/navigation, Codebase-Memory for large-repo knowledge, and Chrome DevTools MCP for browser QA.
- Keep the main session as orchestrator. Use focused subagents for heavy research, planning, execution, review, and QA.
- Do not implement production UI before design approval exists.
- Do not install dependencies, edit secrets, run destructive data commands, or deploy production without manual user approval outside Claude Code.
- Record durable product/change state in artifacts, but summarize current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.

