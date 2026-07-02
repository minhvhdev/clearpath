---
description: Review product taste, concept, brand fit, and UX direction. taste-design is about whether the prototype expresses the right product promise.
---

# /clearpath:taste-design

Review the prototype for product taste, brand fit, and UX direction.
Taste-design is about whether the prototype is the right product, not
whether it is built well.

taste-design is about product taste, concept, brand, and UX direction.
impeccable is about execution quality and UI craft.
Do not duplicate the other skill's checklist.

## Scope

Taste-design covers these direction dimensions:

- product positioning
- emotional tone
- brand coherence
- interaction model taste
- clarity of user journey
- information architecture taste
- whether the design feels intentional vs generic
- whether the prototype expresses the product promise

Taste-design does NOT cover:

- spacing, alignment, density, micro-interactions
- typography execution
- component consistency
- responsive behavior at the pixel level
- accessibility contrast and targets
- production-readiness of UI details

Those are impeccable concerns. Defer to
`/clearpath:impeccable`.

## Required input

- Prototype or implemented UI to review.
- `PRODUCT_BRIEF.md` or `UI_CONTRACT.md` if they exist, so the review
  is anchored to the stated product direction and brand.
- A short statement of the user persona and the job-to-be-done.

## Required output

Write `TASTE_REVIEW.md` (or a `## Taste Review` section in
`DESIGN_REVIEW.md`) with these sections:

1. `## Product/design taste verdict` — overall: is this the right
   product for the stated persona and JTBD?
2. `## Conceptual risks` — what could mislead users or fail in
   market.
3. `## Brand/UX coherence notes` — is the tone consistent, is the
   interaction model coherent across the flow.
4. `## Recommended direction changes` — direction-level changes, not
   pixel-level fixes.
5. `## What must be approved by user` — explicit questions the user
   must answer before the prototype can be approved.

## Rules

- Speak in direction, not pixels. "Make the headline 2px taller" is
  impeccable, not taste. "Lead with the value proposition instead of
  the feature list" is taste.
- Cite the screen and the user moment, not the CSS class.
- Reject feedback that overlaps with impeccable. If the issue is
  about craft, defer to impeccable.
- If the prototype has no product brief, ask the user for the
  persona and JTBD before reviewing. Do not invent a brief.
- Do not run code, write tests, or edit production files. This is a
  review skill.

## Clearpath invariants

- Do not treat artifacts as automatic context. Read
  `docs/clearpath/BOOT.md`, then `CURRENT_CONTEXT.md`, then the
  active `CHANGE_INDEX.md` before drilling into details.
- Preserve approval gates. This skill produces critique only; it
  does not write to production UI files.
- Keep the main session as orchestrator. Use focused subagents for
  heavy research when the prototype spans many flows.
