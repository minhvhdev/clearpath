---
description: Explicit Clearpath goal mode. Skip the normal design approval checkpoint and keep executing autonomously until the stated goal is complete or a real blocker is reached. Use only when the user explicitly invokes `/clearpath:goal` or clearly asks to skip approval and run straight through.
---

# /clearpath:goal

This is the explicit one-shot Clearpath mode for users who want the
agent to run end-to-end without stopping for the normal
**Approve/Request changes** checkpoint.

Use this skill only when the user explicitly opts in by typing
`/clearpath:goal` or by clearly asking to skip approval and let the
agent run straight through to the goal.

## Contract

- Treat the user's request as the goal specification.
- Behave like `/clearpath:go`, but remove the normal design approval
  wait state.
- Keep going until the goal is complete, a real blocker is reached, or
  a material scope/product decision is required.
- Do not stop for routine check-ins, intermediate approvals, or design
  sign-off.

## Workflow

1. Read `.clearpath/docs/BOOT.md`, `CURRENT_CONTEXT.md`, and the active
   `CHANGE_INDEX.md` progressively as usual.
2. Detect the project mode:
   - new project -> `/clearpath:init` then `/clearpath:start`
   - existing Clearpath project -> `/clearpath:update`
   - adopt-existing -> `/clearpath:adopt`
3. Create or continue the active change pack.
4. If UI work is involved, still use `/clearpath:design-prototype` and
   the required design skills for quality, but do not stop to ask for
   approval after presenting the prototype. Use the prototype as an
   internal design/implementation contract and continue.
5. Enter `/clearpath:autonomy` as soon as the path is clear and run
   mandatory `/clearpath:test-driven-development` (RED → verify fail →
   GREEN → verify pass → refactor) until done.
6. Verify, review, and package the result as a release candidate when
   appropriate.

## When to stop anyway

Even in goal mode, stop and ask when:

- the request is too ambiguous to define the correct outcome,
- credentials or external access are missing,
- the required solution would materially expand scope,
- a product/design tradeoff must be chosen by the user,
- tests cannot be made green after a reasonable number of attempts,
- destructive release/deploy action still needs explicit user intent.

## Required behavior for UI work

- Do not skip quality work. Use the same prototype, design, and review
  steps Clearpath normally uses.
- The difference is only that the agent does **not** wait for the user
  to reply **Approve** before continuing.
- Record in the change pack that goal mode was explicitly requested by
  the user and that approval gating was intentionally bypassed for this
  run.

## Relationship to other skills

- `/clearpath:go` is the default safe autopilot path.
- `/clearpath:goal` is the explicit fast path that bypasses the normal
  design approval checkpoint.
- `/clearpath:autonomy` still governs the implementation loop once work
  is underway.

## Clearpath invariants

- Do not treat artifacts as automatic context. Read
  `.clearpath/docs/BOOT.md`, then `CURRENT_CONTEXT.md`, then the active
  `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for
  symbol/navigation, Codebase-Memory for large-repo knowledge, and
  Chrome DevTools MCP for browser QA.
- Record durable product/change state in artifacts, but summarize
  current state in `CURRENT_CONTEXT.md`, `CHANGE_INDEX.md`, and
  `AUTOPILOT.md`.
