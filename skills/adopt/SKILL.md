---
description: Adopt Clearpath for an existing product that has never used Clearpath, especially a large repo.
---
# /clearpath:adopt

For normal usage, `/clearpath:go` is the default entrypoint. This
skill is also called internally by the autopilot router when the
detected mode is `adopt-existing-project`.

Use this when a product/repo already exists but has no Clearpath artifacts.

Workflow:
1. Do not read the whole repo.
2. Inventory the repo: package scripts, README, existing agent manifests, CI, deploy config, top-level directories.
3. Check MCP availability before deciding how to explore (see "MCP availability and fallback" below). Start Codebase-Memory indexing for large repos and use Serena for symbol/reference navigation.
4. Create `PROJECT_INDEX.json`, module cards for relevant domains only, and an adoption `CHANGE_INDEX.md`.
5. Adopt enough to safely perform the current requested change, not to document the whole company.
6. Continue through Spec, Plan, Execute, Verify, Review, and Release Candidate.
7. Update `.clearpath/docs/AUTOPILOT.md` with Detected mode
   (`adopt-existing-project`), Last route
   (`/clearpath:adopt`), Current phase, Open blockers, Next
   expected action, and Last updated (ISO 8601). The file is
   continuity metadata, not a governance gate. The SessionStart
   and UserPromptSubmit hooks are read-only and never write this
   file.

## MCP availability and fallback

Before exploring an unfamiliar repo, check whether Serena and
Codebase-Memory MCP tools actually respond (a tool-list or a trivial
call). Do not assume "if available" silently means "fall back to
reading everything with Read/Grep" without telling the user.

- **Serena available:** Use symbol/reference navigation (e.g.
  find-symbol / symbol-overview style tools) instead of opening whole
  files. Read full file contents only for the specific symbols/regions
  identified as relevant.
- **Serena unavailable, small repo (roughly < 200 tracked files):**
  Fall back to `Grep`/`Read` on a targeted subset. This is acceptable;
  note the fallback in `PROJECT_INDEX.json` under a `tooling_notes`
  field so the next session knows Serena was not used.
- **Serena unavailable, large repo (roughly >= 200 tracked files):**
  **Stop before broad exploration.** Tell the user Serena is required
  for safe large-repo adoption (`uvx --from git+https://github.com/oraios/serena serena start-mcp-server ...` must be reachable), ask them to install/enable it, or explicitly confirm they accept a slower, less complete, Read/Grep-only adoption pass. Record whichever the user chooses in `PROJECT_INDEX.json`. Do not silently proceed to read the whole repo.
- **Codebase-Memory available:** Use it to build/query the large-repo
  knowledge index before falling back to manual file-by-file reading.
- **Codebase-Memory unavailable, small/new repo:** Continue without
  it; note the gap.
- **Codebase-Memory unavailable, large/legacy/monorepo:** Same stop
  rule as Serena above — warn and ask, or run an explicitly-labeled
  limited-mode adoption pass. Never present a limited-mode adoption as
  equivalent in confidence to an MCP-indexed one.
- **Chrome DevTools MCP unavailable:** UI work may continue, but
  browser QA cannot be marked passed in `QA.md` — record it as
  `NOT RUN: Chrome DevTools MCP unavailable`.

Run `scripts/clearpath-doctor.sh` (or `/clearpath:doctor`) before a
large-repo adopt pass; it now fails (not just warns) when Serena or
Codebase-Memory prerequisites are missing and the target project looks
large (see the script for the exact heuristic).


## Clearpath invariants

- Do not treat artifacts as automatic context. Read `.clearpath/docs/BOOT.md`, then `CURRENT_CONTEXT.md`, then the active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for symbol/navigation, Codebase-Memory for large-repo knowledge, and Chrome DevTools MCP for browser QA.
- Dispatch a fresh-context subagent for heavy research, planning, execution, review, or QA -- see `docs/SUBAGENT_DISPATCH.md` for concrete thresholds (roughly >15 files/>2,000 lines to read, >8 turns of work, or any review/QA/security lens, which is always fresh-context). Adoption/exploration of unfamiliar code always dispatches `codebase-architect`.
- Do not implement production UI before the user approves the design in chat.
- Record durable product/change state in artifacts, but summarize current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.

