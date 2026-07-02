---
description: Run product, design, engineering, QA, security, and release role review.
---
# /clearpath:review


Run Review using gstack-style roles.

Review lenses:
- Product/CEO: outcome, scope, user value.
- Design: approved UI contract and states.
- Engineering: simplicity, maintainability, architecture fit.
- QA: evidence and regression confidence.
- Security: auth/data/secrets/deploy risk.
- Release: rollback, known limitations, release readiness.

Save to `REVIEW.md` and create `FIX_PLAN.md` if needed.


## Clearpath invariants

- Do not treat artifacts as automatic context. Read `docs/clearpath/BOOT.md`, then `CURRENT_CONTEXT.md`, then the active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for symbol/navigation, Codebase-Memory for large-repo knowledge, and Chrome DevTools MCP for browser QA.
- Keep the main session as orchestrator. Use focused subagents for heavy research, planning, execution, review, and QA.
- Do not implement production UI before design approval exists.
- Do not install dependencies, edit secrets, run destructive data commands, or deploy production without manual user approval outside Claude Code.
- Record durable product/change state in artifacts, but summarize current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.

