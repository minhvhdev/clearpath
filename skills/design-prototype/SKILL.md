---
description: Produce prototype, run taste-design and impeccable reviews, write UI_CONTRACT and DESIGN_REVIEW, then stop for user design approval before production UI edits.
---

# /clearpath:design-prototype


Run the Design phase for UI changes.

This skill orchestrates two non-overlapping review skills. It does not
perform their work itself.

- `/clearpath:taste-design` — product taste, concept, brand, UX
  direction. Run first.
- `/clearpath:impeccable` — UI craft, execution polish, micro-detail.
  Run second, after taste-design direction is settled.

The two skills have non-overlapping checklists. Do not duplicate
their work. The `design-critic` agent then aggregates the two reviews
into the final design verdict.

## Required order

1. Create the prototype or design delta under `prototype/` (HTML,
   Vue, Svelte, Figma export, or a written screen-by-screen
   description).
2. Run `/clearpath:taste-design` and write `TASTE_REVIEW.md`. Resolve
   critical direction issues before continuing.
3. Run `/clearpath:impeccable` and write `IMPECCABLE_REVIEW.md`.
   Resolve critical craft issues before continuing.
4. Produce `UI_CONTRACT.md` describing hierarchy, layout, states,
   responsive behavior, accessibility, and copy constraints.
5. Produce `DESIGN_REVIEW.md` aggregating taste-design + impeccable
   verdicts. The `design-critic` agent is the final aggregator; it
   does not redo their work.
6. Stop before production UI edits. Ask the user to approve manually
   by creating `.clearpath/approvals/design-approved`. Claude tools
   are blocked from creating approval sentinels.

## Outputs

- `prototype/` files or design delta.
- `TASTE_REVIEW.md` from taste-design skill.
- `IMPECCABLE_REVIEW.md` from impeccable skill.
- `UI_CONTRACT.md` describing hierarchy, layout, states, responsive
  behavior, accessibility, and copy constraints.
- `DESIGN_REVIEW.md` aggregating both reviews, written or reviewed by
  the `design-critic` agent.

## Clearpath invariants

- Do not treat artifacts as automatic context. Read
  `docs/clearpath/BOOT.md`, then `CURRENT_CONTEXT.md`, then the
  active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for
  symbol/navigation, Codebase-Memory for large-repo knowledge, and
  Chrome DevTools MCP for browser QA.
- Keep the main session as orchestrator. Use focused subagents for
  the taste-design and impeccable reviews, and for the design-critic
  aggregation.
- Do not implement production UI before design approval exists.
- Do not install dependencies, edit secrets, run destructive data
  commands, or deploy production without manual user approval outside
  Claude Code.
- Record durable product/change state in artifacts, but summarize
  current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.
