---
description: Post-design-approval autonomy contract. Defines what agents do automatically vs. what requires asking the user, inside an approved plan.
---

# /clearpath:autonomy

For normal usage, `/clearpath:go` is the default entrypoint. This
skill governs the code -> test -> fix -> retest -> release
candidate phase that follows design approval.

This skill defines the post-approval autonomy contract. Once the
design and scope are approved (design gate and `PLAN.md` are
canonical), the contract below governs when the agent acts on its
own and when it must stop and ask the user.

Use this skill:

- When entering the Execute phase after design approval.
- When a subagent is uncertain whether to keep going or ask.
- When the user feels the agent is asking too many trivial questions.

## Automatic (act without asking)

After approval, the agent may, without asking the user:

- implement tasks inside the approved plan,
- write and update tests,
- run lint / typecheck / unit / e2e tests,
- fix test failures,
- re-run verification after a fix,
- update Clearpath artifacts (`CURRENT_CONTEXT.md`, change pack),
- run the code -> test -> fix -> retest loop until green or until a
  real blocker is reached,
- read additional files needed to understand the current task,
- make small refactors that stay inside the approved file list,
- run the project's existing dev / build commands,
- prepare a commit summary and suggest files to stage.

## Source-control finalization (hook-enforced as of v0.4.3)

The agent must not run `git commit`, `git push`, `git tag`,
`git rebase`, `git filter-branch`, `git commit --amend`, or
`git reset --hard` unless the user explicitly asks or the active
workflow grants that permission. As of v0.4.3 this is backed by a
real `PreToolUse` hook: `pre-tool-use-safety-gate.sh` denies these
commands unless `.clearpath/approvals/allow-git-finalize` exists, so
attempting them without the sentinel fails even if the model
misjudges the boundary. `git add` (staging for review) and read-only
git commands (`status`, `diff`, `log`, `show`, a plain `git reset`)
are not blocked — the agent may stage changes and prepare a commit
summary for the user without a sentinel.

## Must stop and ask the user

The agent must stop and ask (or, in autonomous mode, write a `PLAN_DELTA.md`
and stop) when ANY of the following is true:

- The change exceeds the approved scope of `PLAN.md`.
- A product tradeoff is required (e.g., "should this feature be
  enabled by default for new users?").
- The design direction must change (taste, brand, layout, copy
  intent).
- A governance boundary is touched: dependency install, secret
  edit, destructive data, production release, or destructive shell
  (these still require manual approval sentinels).
- Source-control finalization is needed (`git commit`, `git push`,
  tag, rebase, filter-branch, amend, hard reset) — the hook will
  deny it without `allow-git-finalize` anyway.
- Credentials or external service access are missing.
- Tests cannot be made green after a reasonable number of attempts
  (the agent must record the failure mode, not loop forever).
- The repo state contradicts the plan (file missing, branch missing,
  expected module not present).
- A new approval sentinel would be needed (e.g., a new release
  channel).

## Rule of thumb

> Do not ask the user routine implementation questions after
> approval. Ask only when blocked, scope changes, governance
> boundary is touched, source-control finalization is needed, or a
> real product decision is required.

If the question is "which test framework should this file use?" and
the plan already implies one, do not ask — pick the implied one. If
the question is "should this be a feature flag or a config value?",
that is a product decision — ask.

## Reporting when stopping

When the agent stops under the "must ask" rules, it must:

1. Write a `PLAN_DELTA.md` describing the gap, the decision needed,
   and the proposed resolution.
2. Update `CURRENT_CONTEXT.md` with the stop reason.
3. Hand control back to the user with a clear summary of what was
   done, what is blocked, and what decision is required.

## Clearpath invariants

- Do not treat artifacts as automatic context. Read
  `docs/clearpath/BOOT.md`, then `CURRENT_CONTEXT.md`, then the
  active `CHANGE_INDEX.md` before drilling into details.
- Preserve approval gates. This skill does not weaken them.
- The hooks remain authoritative for governance boundaries. This
  skill governs agent behavior, not hook behavior.
