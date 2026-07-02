---
description: Produce HTML+Tailwind prototype using mandatory user-scope skills design-taste-frontend and impeccable, then wait for chat approval before production UI edits.
---

# /clearpath:design-prototype

For normal usage, `/clearpath:go` is the default entrypoint.

Run the Design phase for UI changes.

## Mandatory user-scope skills

Before production UI work, you **must** read and follow these skills
from the user's skill scope (not Clearpath plugin stubs):

1. **`design-taste-frontend`** — run first. Art direction, anti-slop
   taste, brief inference, design read. Apply to the prototype brief
   and HTML direction before building.
2. **`impeccable`** — run second on the prototype HTML. Craft, audit,
   polish, states, accessibility, anti-patterns. Use its setup flow
   (`context.mjs`, register references) when applicable.

If either skill is missing from user scope, **stop** and run
`/clearpath:doctor` — ask the user for permission to install, then
retry. Do not substitute improvised review checklists.

Dispatch fresh-context subagents for each skill when the prototype
spans multiple screens (see `docs/SUBAGENT_DISPATCH.md`).

The `design-critic` agent aggregates outputs and issues a final verdict.

## Prototype rules (mandatory)

- Location: **only** under `.clearpath/prototype/`.
- Format: **HTML + Tailwind CSS** (CDN `https://cdn.tailwindcss.com`).
- No Vue, React, Svelte, or other frameworks in the prototype phase.
- Preview: open `.clearpath/prototype/index.html` in a browser or
  Chrome DevTools MCP.

## Required order

1. Read **`design-taste-frontend`** skill; output a one-line Design Read
   in the change pack (`DESIGN_READ.md` or section in `CHANGE.md`).
2. Build or update `.clearpath/prototype/index.html` (+ optional screens)
   using HTML + Tailwind per both skills.
3. Read and apply **`impeccable`** to the prototype — audit/polish until
   craft-critical issues are resolved. Record summary in
   `IMPECCABLE_REVIEW.md` (or impeccable's native output location).
4. Write `UI_CONTRACT.md` in `.clearpath/docs/changes/<change-id>/`.
5. Run **`design-critic`** → `DESIGN_REVIEW.md` with final verdict.
6. **Present the prototype.** Ask:

   > **Approve** — implement in production code.
   > **Request changes** — describe revisions.

7. Wait for user approval in chat before production UI edits.
8. On approval: `DESIGN_APPROVAL.md` → `/clearpath:autonomy`.

## Required MCP (mandatory)

Use when relevant — if unavailable, run `/clearpath:doctor` first:

- **Chrome DevTools MCP** — preview and inspect prototype
- **Serena** — navigate production code paths for implementation planning
- **Codebase-Memory MCP** — large-repo context

## Outputs

- `.clearpath/prototype/*.html`
- `DESIGN_READ.md`, `IMPECCABLE_REVIEW.md`, `UI_CONTRACT.md`,
  `DESIGN_REVIEW.md`, `DESIGN_APPROVAL.md` in the active change pack.

## Clearpath invariants

- Read `.clearpath/docs/BOOT.md`, then `CURRENT_CONTEXT.md`, then
  `CHANGE_INDEX.md` before drilling into details.
- Do not implement production UI before chat approval.
