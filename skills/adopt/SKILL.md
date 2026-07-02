---
description: Adopt Clearpath for an existing product that has never used Clearpath, especially a large repo.
---
# /clearpath:adopt


Use this when a product/repo already exists but has no Clearpath artifacts.

Workflow:
1. Do not read the whole repo.
2. Inventory the repo: package scripts, README, existing agent manifests, CI, deploy config, top-level directories.
3. Start Codebase-Memory indexing for large repos and use Serena for symbol/reference navigation.
4. Create `PROJECT_INDEX.json`, module cards for relevant domains only, and an adoption `CHANGE_INDEX.md`.
5. Adopt enough to safely perform the current requested change, not to document the whole company.
6. Continue through Spec, Plan, Execute, Verify, Review, and Release Candidate.


## Clearpath invariants

- Do not treat artifacts as automatic context. Read `docs/clearpath/BOOT.md`, then `CURRENT_CONTEXT.md`, then the active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for symbol/navigation, Codebase-Memory for large-repo knowledge, and Chrome DevTools MCP for browser QA.
- Keep the main session as orchestrator. Use focused subagents for heavy research, planning, execution, review, and QA.
- Do not implement production UI before design approval exists.
- Do not install dependencies, edit secrets, run destructive data commands, or deploy production without manual user approval outside Claude Code.
- Record durable product/change state in artifacts, but summarize current state in `CURRENT_CONTEXT.md` and `CHANGE_INDEX.md`.

