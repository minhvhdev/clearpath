---
description: Review precise UI execution critique and implementation-quality polish. Impeccable is about craft precision, UI anti-pattern cleanup, states, accessibility, responsive behavior, and implementation readiness.
---

# /clearpath:impeccable

Review the UI for design-execution quality, craft precision, and
implementation readiness. Impeccable uses precise frontend design
vocabulary and anti-pattern checks to make the approved direction
production-quality.

impeccable judges typography, layout, motion, and density at the
execution, consistency, implementation-readiness, and anti-pattern
level. taste-design judges the same surfaces at the art-direction and
product-taste level. Do not duplicate the other skill's findings.

## Scope

Impeccable covers these craft dimensions:

- spacing consistency
- alignment
- hierarchy
- typography execution
- component consistency
- empty / loading / error / disabled / focus / hover states
- accessibility basics
- responsive behavior
- interaction details
- micro-interactions
- design-system fit
- implementation-level UI anti-patterns
- production readiness of UI details

Impeccable does NOT cover:

- product positioning
- emotional tone at the art-direction level
- brand or product coherence as direction
- interaction model taste
- clarity of user journey as product direction
- information architecture taste
- whether the concept or art direction feels intentional

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

1. `## Execution-quality verdict` — one-line verdict per craft
   dimension.
2. `## Critical craft defects` — execution issues that block design
   approval or implementation readiness.
3. `## Anti-patterns to remove` — concrete UI anti-pattern cleanup
   with file path, element, and expected change.
4. `## Implementation-readiness checklist` — states, responsive
   behavior, accessibility basics, and design-system fit needed
   before production UI work.
5. `## Measurable UI acceptance criteria` — checks such as "body text
   16px / 24px line-height on screens < 768px", "every primary
   action has hover, focus, disabled, and loading states", and
   "color contrast ratio >= 4.5:1 for body text".

## Rules

- Use evidence: cite the file, the element, the line. No vague taste
  comments.
- Reject vague feedback like "improve spacing" — say what spacing,
  where, and to what value.
- Impeccable asks: is the chosen direction executed precisely; are
  spacing, hierarchy, typography, states, responsiveness, and
  accessibility production-quality; are there implementation-level UI
  anti-patterns; are acceptance criteria measurable enough to build?
- Reject feedback that overlaps with taste-design at the direction
  level. If the issue is concept, art direction, or product promise,
  defer to taste-design.
- Do not propose copy or brand-voice changes unless they are needed
  for UI state clarity. Product voice is taste-design.
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
