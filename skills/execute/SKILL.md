---
description: Execute the approved plan with small tasks, TDD where available, and no scope drift. Post-approval autonomy contract applies.
---

# /clearpath:execute


Run the Execute phase.

This phase follows the post-approval autonomy contract in
`/clearpath:autonomy`. After design and scope are approved, the
agent may run the code -> test -> fix -> retest loop without asking
the user, except where the contract says it must stop.

Rules:
- Stay inside the approved plan.
- If the plan is wrong, write a `PLAN_DELTA.md` and stop.
- Use TDD when the repo has test infrastructure.
- Do not install dependencies without manual approval.
- Do not deploy production.
- Record task progress in the active change pack.
- For governance boundaries (dependency install, secret edit,
  destructive data, production release, destructive shell), the
  autonomy contract says: stop and ask. The hooks will deny anyway.
- Do not run `git add`, `git commit`, `git push`, create tags, or
  rewrite history unless the user explicitly asks or the active
  workflow grants that permission. You may prepare a commit
  summary and suggest files to stage.


## Clearpath invariants

- Do not treat artifacts as automatic context. Read
  `docs/clearpath/BOOT.md`, then `CURRENT_CONTEXT.md`, then the
  active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for
  symbol/navigation, Codebase-Memory for large-repo knowledge, and
  Chrome DevTools MCP for browser QA.
- Keep the main session as orchestrator. Use focused subagents for
  heavy research, planning, execution, review, and QA.
- Do not implement production UI before design approval exists.
- Do not install dependencies, edit secrets, run destructive data
  commands, or deploy production without manual user approval
  outside Claude Code.
- Record durable product/change state in artifacts, but summarize
  current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.
