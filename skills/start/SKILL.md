---
description: Start a new product from scratch using the full Clearpath delivery loop.
---
# /clearpath:start

For normal usage, `/clearpath:go` is the default entrypoint. This
skill is also called internally by the autopilot router after
`/clearpath:init` for new projects.

Use this when the user is building a product from zero.

Workflow:
1. Initialize/recover artifacts.
2. Discuss product intent, users, jobs-to-be-done, constraints, and non-goals.
3. Write `PRODUCT.md`, `CHANGE.md`, `SPEC.md`, and acceptance criteria for the initial MVP.
4. Produce a local HTML + Tailwind prototype under `.clearpath/prototype/` for any UI.
5. Request design approval before production UI implementation.
6. Build a task plan, execute in small subagent-ready tasks, verify with tests/browser QA, run role review, produce a release candidate, then stop at the Release Gate.
7. Update `.clearpath/docs/AUTOPILOT.md` as the phase advances
   (Last route, Current phase, Design approval status,
   Implementation status, Verification status, Release candidate
   status, Open blockers, Next expected action, Last updated).
   The file is continuity metadata, not a governance gate. The
   SessionStart and UserPromptSubmit hooks are read-only and
   never write this file.

Reference lineage:
- GSD Core: phase loop and context discipline.
- Superpowers: spec-first/TDD/review discipline.
- gstack: CEO/design/engineering/QA/release role review.
- Clearpath: enforced approval gates and durable artifact ledger.


## Clearpath invariants

- Do not treat artifacts as automatic context. Read `.clearpath/docs/BOOT.md`, then `CURRENT_CONTEXT.md`, then the active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for symbol/navigation, Codebase-Memory for large-repo knowledge, and Chrome DevTools MCP for browser QA.
- Dispatch a fresh-context subagent for heavy research, planning, execution, review, or QA -- see `docs/SUBAGENT_DISPATCH.md` for concrete thresholds (roughly >15 files/>2,000 lines to read, >8 turns of work, or any review/QA/security lens, which is always fresh-context).
- Do not implement production UI before the user approves the design in chat.
- Record durable product/change state in artifacts, but summarize current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.

