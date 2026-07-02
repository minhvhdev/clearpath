---
description: Review UI craft and execution polish (spacing, alignment, density, micro-interactions, accessibility, responsive). Impeccable is about execution quality and UI craft.
---

# /clearpath:impeccable

Review the UI for execution polish and craft detail. Impeccable is
about how the prototype is built, not what the product is.

impeccable is about execution quality and UI craft.
taste-design is about product taste, concept, brand, and UX direction.
Do not duplicate the other skill's checklist.

## Scope

Impeccable covers these craft dimensions:

- visual hierarchy
- spacing rhythm
- alignment
- typography execution
- density
- component consistency
- micro-interactions
- empty / loading / error states
- responsive behavior
- accessibility basics
- production readiness of UI details

Impeccable does NOT cover:

- product positioning
- emotional tone
- brand coherence
- interaction model taste
- clarity of user journey
- information architecture taste
- whether the design feels intentional

Those are taste-design concerns. Defer to
`/clearpath:taste-design`.

## Required input

- Prototype or production UI under `prototype/`, or a list of UI
  files to review.
- `UI_CONTRACT.md` if it exists, so the review is anchored to the
  stated hierarchy, layout, states, and accessibility claims.

## Required output

Write `IMPECCABLE_REVIEW.md` (or a `## Impeccable Review` section in
`DESIGN_REVIEW.md`) with these sections:

1. `## Pass/fail summary` — one-line verdict per craft dimension.
2. `## Critical polish issues` — items that block design approval.
3. `## UI details to fix before implementation` — concrete fixes with
   file path and expected change.
4. `## Acceptance criteria for visual quality` — measurable checks
   (e.g., "body text 16px / 24px line-height on screens < 768px",
   "every primary action has a hover and disabled state",
   "color contrast ratio >= 4.5:1 for body text").

## Rules

- Use evidence: cite the file, the element, the line. No vague taste
  comments.
- Reject vague feedback like "improve spacing" — say what spacing,
  where, and to what value.
- Reject feedback that overlaps with taste-design. If the issue is
  about the concept or product direction, defer to taste-design.
- Do not propose copy or brand-voice changes. Those are taste-design.
- Do not run code, write tests, or edit production files. This is a
  review skill.

## Clearpath invariants

- Do not treat artifacts as automatic context. Read
  `docs/clearpath/BOOT.md`, then `CURRENT_CONTEXT.md`, then the
  active `CHANGE_INDEX.md` before drilling into details.
- Preserve approval gates. This skill produces critique only; it
  does not write to production UI files.
- Keep the main session as orchestrator. Use focused subagents for
  heavy research when the prototype is large.
