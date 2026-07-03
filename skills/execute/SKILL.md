---
description: Execute the approved plan with small tasks, TDD where available, and no scope drift. Post-approval autonomy contract applies.
---

# /clearpath:execute

For normal usage, `/clearpath:go` is the default entrypoint. This
skill is called by the autopilot router during the post-approval
implementation loop.

Run the Execute phase.

This phase follows the post-approval autonomy contract in
`/clearpath:autonomy`. After the user approves in chat, the agent
may run the code -> test -> fix -> retest loop without asking the
user, except where the contract says it must stop.

Apply `/clearpath:implementation-discipline` throughout the
implementation loop so code changes stay minimal, traceable, and
verified.

Rules:
- Stay inside the approved plan.
- If the plan is wrong, write a `PLAN_DELTA.md` and stop.
- Use TDD when the repo has test infrastructure.
- Do not make silent assumptions; state them or stop and ask.
- Install dependencies, run builds, and deploy when needed to
  complete the approved work.
- Record task progress in the active change pack.

## Clearpath invariants

- Do not treat artifacts as automatic context. Read
  `.clearpath/docs/BOOT.md`, then `CURRENT_CONTEXT.md`, then the
  active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for
  symbol/navigation, Codebase-Memory for large-repo knowledge, and
  Chrome DevTools MCP for browser QA.
- Do not implement production UI before the user approves the design
  in chat.
- Record durable product/change state in artifacts, but summarize
  current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.
