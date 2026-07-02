---
description: Execute the approved plan with small tasks, TDD where available, and no scope drift. Post-approval autonomy contract applies.
---

# /clearpath:execute

For normal usage, `/clearpath:go` is the default entrypoint. This
skill is called by the autopilot router during the post-approval
implementation loop.

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
- Do not run `git commit`, `git push`, `git tag`, `git rebase`,
  `git filter-branch`, `git commit --amend`, or `git reset --hard`
  unless the user explicitly asks or the active workflow grants that
  permission; the safety gate denies these without the
  `allow-git-finalize` sentinel as of v0.4.3. `git add` and read-only
  git commands are not blocked — you may stage changes and prepare a
  commit summary for the user without a sentinel.


## Clearpath invariants

- Do not treat artifacts as automatic context. Read
  `docs/clearpath/BOOT.md`, then `CURRENT_CONTEXT.md`, then the
  active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for
  symbol/navigation, Codebase-Memory for large-repo knowledge, and
  Chrome DevTools MCP for browser QA.
- Dispatch a fresh-context subagent for heavy research, planning,
  execution, review, or QA -- see `docs/SUBAGENT_DISPATCH.md` for
  concrete thresholds (roughly >15 files/>2,000 lines to read, >8
  turns of work, or any review/QA/security lens, which is always
  fresh-context).
- Do not implement production UI before design approval exists.
- Do not install dependencies, edit secrets, run destructive data
  commands, or deploy production without manual user approval
  outside Claude Code.
- Record durable product/change state in artifacts, but summarize
  current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.
