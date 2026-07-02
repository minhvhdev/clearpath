# Subagent dispatch policy

Every Clearpath skill says "keep the main session as orchestrator; use
focused subagents for heavy work." This document makes that concrete
instead of leaving it as vague prose, closing the gap where Clearpath
claimed GSD Core's fresh-context discipline without a wired threshold.

This is skill-level guidance for the model, not a hook. No PreToolUse
hook can force a subagent dispatch — dispatch decisions happen before
any tool call exists to gate. Treat this as the operational default;
deviate and say why when a task genuinely does not fit the pattern.

## Dispatch a fresh-context subagent when any of these hold

- **Read volume:** the task will likely require reading more than
  roughly **15 files** or **2,000 lines** total to gather enough
  context. Dispatch a research/architecture subagent (e.g.
  `codebase-architect`) instead of reading them all in the
  orchestrator session.
- **Turn volume:** the task will likely take more than roughly **8
  tool calls / conversational turns** of back-and-forth exploration or
  editing before it's done. Long-running work degrades orchestrator
  context quality even when each individual read is small.
- **Independent parallel work:** two or more files/modules/checks can
  be worked on without shared state (e.g. running `taste-design` and
  gathering QA evidence for unrelated flows). Dispatch them as
  separate subagents rather than doing them serially in one session.
- **Any review, QA, or security lens — always.** `product-strategist`,
  `design-critic`, `security-reviewer`, `qa-release-engineer`'s QA
  half, and `taste-design`/`impeccable` reviews must run as fresh-
  context subagents even for small changes. A reviewer that shares the
  orchestrator's edit history is not an independent check.
- **Adoption/exploration of unfamiliar code** — always dispatch
  `codebase-architect` rather than exploring inline, regardless of
  size, because adoption work has no existing mental model to reuse.

## Do the work directly in the orchestrator session when

- The task is a single, already-scoped file edit with a known plan
  (e.g. "apply this one-line fix to `foo.ts`").
- The task is a small, mechanical artifact update (e.g. updating
  `CURRENT_CONTEXT.md` after a phase completes).
- Dispatching would cost more turns than it saves (e.g. the context
  needed by a subagent is itself larger than just doing the read
  directly).

## What "fresh context" means operationally in Claude Code

Dispatch means literally invoking the named agent (via the Task-style
subagent mechanism) so it starts with its own clean context window and
returns a summary, not just deciding "I will now think about this
differently." If the model does the work inline while narrating "as
the architect agent, I would say...", that is not a fresh-context
dispatch and does not get the isolation benefit — actually invoke the
named subagent.

## Relationship to GSD Core

GSD Core's phase loop runs every phase's heavy work (Discuss research,
Plan decomposition, parallel Execute waves, Verify diagnosis) in
fresh, isolated subagent contexts by default, with context-budget
degradation tiers as the repo grows. Clearpath adopts the same intent
but not GSD's tooling-specific mechanism (GSD's executor/wave model is
built into its own CLI runtime). The thresholds above are Clearpath's
own operational approximation of "when GSD Core would spin up a fresh
executor" for a Claude Code skill/agent context, not a byte-for-byte
port. This is a real behavioral policy the model should follow, not
just naming-level synthesis — but it is still enforced by instruction,
not by a hook, because no hook can observe "how much research is about
to happen" before it happens.
