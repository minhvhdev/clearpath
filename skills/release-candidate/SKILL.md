---
description: Package verified work into a release candidate without deploying production.
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

Stop at the Release Gate. Do not run production deploy commands unless the user manually creates `.clearpath/approvals/allow-production-release`.


## Clearpath invariants

- Do not treat artifacts as automatic context. Read `docs/clearpath/BOOT.md`, then `CURRENT_CONTEXT.md`, then the active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for symbol/navigation, Codebase-Memory for large-repo knowledge, and Chrome DevTools MCP for browser QA.
- Keep the main session as orchestrator. Use focused subagents for heavy research, planning, execution, review, and QA.
- Do not implement production UI before design approval exists.
- Do not install dependencies, edit secrets, run destructive data commands, or deploy production without manual user approval outside Claude Code.
- Record durable product/change state in artifacts, but summarize current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.

