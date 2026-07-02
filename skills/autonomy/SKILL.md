---
description: Post-design-approval autonomy contract. After the user approves in chat, the agent implements, tests, fixes, and verifies without routine questions.
---

# /clearpath:autonomy

For normal usage, `/clearpath:go` is the default entrypoint. This
skill governs the code -> test -> fix -> retest -> release
candidate phase that follows design approval in chat.

This skill defines the post-approval autonomy contract. Once the
user approves the design and scope (`DESIGN_APPROVAL.md` and
`PLAN.md` are canonical), the contract below governs when the agent
acts on its own and when it must stop and ask the user.

Use this skill:

- When entering the Execute phase after the user approves in chat.
- When a subagent is uncertain whether to keep going or ask.
- When the user replies "approve" / "go ahead" after a design checkpoint.

## Automatic (act without asking)

After approval, the agent may, without asking the user:

- implement tasks inside the approved plan,
- write and update tests,
- install dependencies when needed for the approved work,
- run lint / typecheck / unit / e2e tests,
- fix test failures,
- re-run verification after a fix,
- update Clearpath artifacts (`CURRENT_CONTEXT.md`, change pack),
- run the code -> test -> fix -> retest loop until green or until a
  real blocker is reached,
- read additional files needed to understand the current task,
- make small refactors that stay inside the approved file list,
- run the project's existing dev / build commands,
- commit, push, and deploy when the user has asked for it or when it
  is the natural next step to finish the approved work.

## Must stop and ask the user

The agent must stop and ask (or write a `PLAN_DELTA.md` and stop)
when ANY of the following is true:

- The change exceeds the approved scope of `PLAN.md`.
- A product tradeoff is required (e.g., "should this feature be
  enabled by default for new users?").
- The design direction must change (taste, brand, layout, copy
  intent) — return to `/clearpath:design-prototype`.
- Credentials or external service access are missing.
- Tests cannot be made green after a reasonable number of attempts
  (record the failure mode, do not loop forever).
- The repo state contradicts the plan (file missing, branch missing,
  expected module not present).

## Rule of thumb

> After the user approves the design, keep going. Ask only when
> blocked, scope changes, or a real product decision is required.

## Reporting when stopping

When the agent stops under the "must ask" rules, it must:

1. Write a `PLAN_DELTA.md` describing the gap, the decision needed,
   and the proposed resolution.
2. Update `CURRENT_CONTEXT.md` with the stop reason.
3. Hand control back to the user with a clear summary of what was
   done, what is blocked, and what decision is required.

## Clearpath invariants

- Do not treat artifacts as automatic context. Read
  `.clearpath/docs/BOOT.md`, then `CURRENT_CONTEXT.md`, then the
  active `CHANGE_INDEX.md` before drilling into details.
- Record durable product/change state in artifacts, but summarize
  current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.
