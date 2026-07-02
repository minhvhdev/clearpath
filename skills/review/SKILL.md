---
description: Run product, design, engineering, QA, security, and release role review.
---
# /clearpath:review


Run Review using gstack-style roles. Each lens below is bound to a
named Clearpath agent — dispatch that agent (as a focused subagent)
rather than writing the section yourself in the orchestrator session.
If an agent is skipped for a section, say so explicitly in that
section instead of leaving it blank or writing `TBD`.

| Review lens | `REVIEW.md` section | Dispatch to |
|---|---|---|
| Product/CEO | `## Product Review` | `product-strategist` agent — outcome, scope, user value, non-goals. |
| Design | `## Design Review` | `design-critic` agent — verify the approved `UI_CONTRACT.md`/`DESIGN_REVIEW.md` verdict still holds; confirm `design-taste-frontend` and `impeccable` outputs were applied; do not re-run full skill flows unless drift is found. |
| Engineering | `## Engineering Review` | `codebase-architect` agent for architecture/interface fit, plus `implementation-engineer`'s own summary of what changed and why. Simplicity and maintainability judgment stays with `codebase-architect`. |
| QA | `## QA Review` | `qa-release-engineer` agent — evidence and regression confidence from `QA.md`. |
| Security | `## Security Review` | `security-reviewer` agent — auth/data/secrets/dependency/deploy risk. Always dispatch this one by name; do not let `qa-release-engineer` self-certify security risk. |
| Release | `## Release Review` | `qa-release-engineer` agent — rollback plan, known limitations, release readiness (this is the release-packaging half of that agent's scope, distinct from its QA-evidence half above). |

Save to `REVIEW.md` and create `FIX_PLAN.md` if needed.


## Clearpath invariants

- Do not treat artifacts as automatic context. Read `.clearpath/docs/BOOT.md`, then `CURRENT_CONTEXT.md`, then the active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for symbol/navigation, Codebase-Memory for large-repo knowledge, and Chrome DevTools MCP for browser QA.
- Dispatch a fresh-context subagent for heavy research, planning, execution, review, or QA -- see `docs/SUBAGENT_DISPATCH.md` for concrete thresholds (roughly >15 files/>2,000 lines to read, >8 turns of work, or any review/QA/security lens, which is always fresh-context).
- Do not implement production UI before the user approves the design in chat.
- Record durable product/change state in artifacts, but summarize current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.

