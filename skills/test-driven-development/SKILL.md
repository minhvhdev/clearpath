---
description: Mandatory Superpowers-style TDD during Execute. Red-green-refactor with verified failing tests before any production code.
---

# /clearpath:test-driven-development

Mandatory test-driven development for Clearpath implementation work.

Adapted from [Superpowers test-driven-development](https://github.com/obra/superpowers-skills/blob/main/skills/testing/test-driven-development/SKILL.md)
and wired into `/clearpath:execute`, `/clearpath:autonomy`, and
`/clearpath:implementation-discipline`.

## When this skill applies

**Always during Execute** (after design approval or explicit goal mode)
for:

- new features
- bug fixes
- behavior changes
- refactors that change production code

**Does not apply to:**

- HTML+Tailwind prototypes under `.clearpath/prototype/` (design phase)
- artifact-only edits (spec, plan, docs)
- throwaway spikes the user explicitly exempts

**Exceptions (must stop and ask the user):**

- throwaway prototypes outside Clearpath design flow
- generated code the user asked to keep as-is
- configuration-only changes with no testable behavior

Thinking "skip TDD just this once"? Stop. That is rationalization.

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Write production code before the test? **Delete it. Start over.**

**No exceptions:**

- Do not keep it as "reference"
- Do not "adapt" it while writing tests
- Do not look at it
- Delete means delete

Implement fresh from tests.

## Red-Green-Refactor

### RED — Write failing test

Write **one** minimal test showing what should happen.

Requirements:

- one behavior per test
- clear name describing behavior
- test real code (mocks only when unavoidable)

### Verify RED — Watch it fail

**MANDATORY. Never skip.**

Run the targeted test with the project's test command.

Confirm:

- test **fails** (not errors)
- failure message is expected
- fails because the feature/bug is missing (not typos)

**Test passes immediately?** You are testing existing behavior. Fix the
test.

**Test errors?** Fix the error, re-run until it fails correctly.

### GREEN — Minimal code

Write the **simplest** code to pass the test.

Do not add features, refactor unrelated code, or "improve" beyond what
the test requires.

### Verify GREEN — Watch it pass

**MANDATORY.**

Run the test again. Confirm:

- test passes
- other tests still pass
- output is clean (no new errors or warnings)

**Test fails?** Fix code, not the test.

**Other tests fail?** Fix now.

### REFACTOR — Clean up

After green only:

- remove duplication
- improve names
- extract helpers

Keep tests green. Do not add behavior.

### Repeat

Next failing test for the next behavior.

## No test infrastructure yet

If the repo has no test runner:

1. Add the **minimum** test harness for the stack (one config file, one
   smoke test).
2. Follow the same RED → Verify RED → GREEN → Verify GREEN cycle for
   that harness.
3. Then continue feature work with strict TDD.

If a test harness truly cannot be added, stop per `/clearpath:autonomy`
and write `PLAN_DELTA.md` — do not write production code silently.

## Bug fixes

Never fix a bug without a failing test that reproduces it first.

1. RED: write test reproducing the bug
2. Verify RED: confirm it fails for the right reason
3. GREEN: minimal fix
4. Verify GREEN: test passes; regression suite still green

## Red flags — stop and start over

- production code written before a failing test
- test added after implementation
- test passes on first run without an expected failure
- cannot explain why the test failed
- "I'll add tests later"
- "keep as reference" or "adapt existing code"
- rationalizing "just this once"

**All of these mean: delete the production code and restart with TDD.**

## Verification checklist

Before marking a task or change complete:

- [ ] every new function/method/behavior has a test
- [ ] watched each test fail before implementing
- [ ] each test failed for the expected reason (missing feature, not typo)
- [ ] wrote minimal code to pass each test
- [ ] all tests pass
- [ ] output pristine (no new errors or warnings)
- [ ] tests use real code (mocks only if unavoidable)

Cannot check all boxes? You skipped TDD. Start over.

## Integration with Clearpath

- Apply during `/clearpath:execute` and `/clearpath:autonomy`.
- Works with `/clearpath:implementation-discipline`: minimal changes,
  no silent assumptions, verify before calling work done.
- `/clearpath:verify` must cite TDD evidence (which tests failed first,
  which commands were run) in `QA.md` when implementation code changed.
- Design approval still gates production UI; TDD gates production
  **code** after approval.

## Final rule

```
Production code → a test existed and failed first
Otherwise → not TDD
```

No exceptions without explicit user permission recorded in the change
pack.
