---
description: Distilled execution guardrails for Clearpath implementation work. Use during execute/autonomy to avoid silent assumptions, scope creep, and unverified "done".
---

# /clearpath:implementation-discipline

Execution guardrails for approved code changes in Clearpath.

Apply during `/clearpath:execute`, `/clearpath:autonomy`, and any
subagent task that writes production code.

Also apply `/clearpath:test-driven-development` whenever production
code changes. The Iron Law applies: no production code without a
verified failing test first. Code written before tests must be deleted
and rewritten test-first.

## Guardrails

- No silent assumptions. If the spec, change pack, or repo state is
  unclear, state the assumption explicitly or stop and ask.
- Make the minimum necessary change. Do not add flexibility,
  abstraction, or cleanup that the approved work does not need.
- Keep edits traceable to the approved request, plan, or bug.
- Respect approval gates. Do not jump past design approval, release
  review, or any other documented stop point.
- Leave unrelated work alone. If you notice adjacent issues, record
  them if useful, but do not silently fix them.
- Verify before calling work done. Use the strongest practical check
  for the change: tests, lint, typecheck, build, QA, or a focused
  manual verification step.

## Execution stance

- Prefer simple solutions over speculative architecture.
- Prefer small scoped edits over broad rewrites.
- Prefer existing patterns over parallel new ones.
- Prefer a short explicit assumption over an unstated one.

## When to stop

Stop and hand control back when:

- the approved scope is no longer enough,
- a product or UX decision is required,
- the repo contradicts the plan,
- or verification cannot be made green in a reasonable loop.

When stopping, name the exact assumption, scope gap, or failing check
that blocked progress.
