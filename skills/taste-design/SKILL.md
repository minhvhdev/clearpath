---
description: Review art direction and anti-generic frontend/product taste. taste-design is about whether the prototype feels intentional, differentiated, and aligned with the product promise.
---

# /clearpath:taste-design

Review the prototype for art direction, anti-generic frontend/product
taste, visual identity, product vibe, and brand fit. Taste-design is
about whether the direction feels intentional, differentiated, and
aligned with the product promise.

taste-design judges typography, layout, motion, and density at the
art-direction and product-taste level. impeccable judges the same
surfaces at the execution, consistency, implementation-readiness, and
anti-pattern level. Do not duplicate the other skill's findings.

## Scope

Taste-design covers these direction dimensions:

- visual identity
- product vibe
- art direction
- layout direction
- typography direction
- density and rhythm at the taste/art-direction level
- motion direction
- emotional tone
- brand/product coherence
- whether the UI feels generic, template-like, or premium
- whether the prototype expresses the product promise

Taste-design does NOT cover:

- pixel-level spacing, alignment, or density fixes
- concrete typography values or component measurements
- component consistency and implementation readiness
- responsive behavior at the pixel level
- accessibility contrast and target-size measurements
- implementation-level UI anti-pattern cleanup

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

1. `## Taste verdict` — does this direction feel intentional,
   differentiated, and right for the stated persona and JTBD?
2. `## Generic/slop risks` — where the UI feels template-like,
   AI-sloppy, forgettable, or misaligned with the product promise.
3. `## Art-direction risks` — visual identity, product vibe,
   typography direction, layout direction, density/rhythm, motion
   direction, and emotional tone issues.
4. `## Direction changes before approval` — direction-level changes,
   not pixel-level fixes.
5. `## User approval decisions` — explicit user-facing design choices
   the user must approve before the prototype can be approved.

## Rules

- Speak in art-direction and product-taste terms, not concrete
  implementation values. "The type system feels too generic for a
  premium workflow product" is taste; "set h1 to 48px" is
  impeccable.
- Cite the screen and the user moment, not the CSS class.
- Taste-design asks: does this direction feel intentional,
  differentiated, and right for the product; does it avoid generic
  SaaS/template/AI-slop; is the visual identity strong enough; does
  the interface express the product promise?
- Reject feedback that overlaps with impeccable at the execution
  level. If the issue is measurable craft, consistency,
  implementation readiness, or UI anti-pattern cleanup, defer to
  impeccable.
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
