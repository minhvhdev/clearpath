---
description: Distilled guardrails for Clearpath review and QA verdicts. Use when assessing changes, evidence, regressions, and release readiness.
---

# /clearpath:review-qa-discipline

Verdict guardrails for review, QA, and release readiness in Clearpath.

Apply it during `/clearpath:review`, `/clearpath:qa`, `/clearpath:verify`,
and QA/release subagent work.

## Guardrails

- Lead with real bugs, regressions, and release risks before style or
  preference feedback.
- Base conclusions on evidence. Cite the failing check, repro path,
  artifact, screenshot, log signal, or missing verification.
- Match severity to impact. Do not escalate a guess into a blocker.
- Separate facts from suggestions. "Could improve" is not the same as
  "must fix before release."
- Be explicit about test gaps and residual risk. If something was not
  verified, say so plainly.
- Never mark work as passed on stale evidence. Re-run or say "not run."

## Review stance

- Prefer reproducible findings over speculative concerns.
- Prefer concise verdicts over long issue inventories.
- Prefer release-significant risks over cosmetic nits.
- Prefer a clear "pass with risks" or "not ready because X" over vague
  uncertainty.

## When to stop

Stop and ask for follow-up when:

- a verdict depends on missing evidence,
- a severity call needs product judgment,
- or the available signals conflict and cannot be resolved reliably.
