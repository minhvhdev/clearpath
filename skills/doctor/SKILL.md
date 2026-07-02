---
description: Validate Clearpath wiring, required user-scope skills (design-taste-frontend, impeccable), MCP prerequisites, and artifact health. Ask user permission before auto-installing missing items.
---

# /clearpath:doctor

Run diagnostics and fix missing prerequisites when the user approves.

## Required user-scope skills (mandatory for design work)

- `design-taste-frontend` — art direction, anti-slop taste
- `impeccable` — UI craft, audit, polish, execution quality

These are **not** `/clearpath:taste-design` or `/clearpath:impeccable`. They
are the full skills in the user's skill scope (`~/.claude/skills/`).

## Required MCP servers (mandatory)

- `chrome-devtools` — browser QA
- `serena` — symbol navigation
- `codebase-memory-mcp` — large-repo knowledge graph

## Workflow

1. Run `clearpath-doctor` (or `scripts/clearpath-doctor.sh`).
2. Read the output. If you see `CLEARPATH_DOCTOR_NEEDS_USER_APPROVAL: true`,
   summarize what is missing in plain language for the user.
3. **Ask the user explicitly:**

   > Clearpath is missing N prerequisites (skills / MCP / CLI).
   > May I install them into your **user scope** (`~/.claude/skills/`,
   > `~/.claude/settings.json`, global CLI tools)?
   > Reply **yes** to proceed or **no** to skip.

4. If the user approves, run:

   ```bash
   CLEARPATH_DOCTOR_INSTALL_APPROVED=1 clearpath-doctor-install
   ```

5. Re-run `clearpath-doctor` until required items pass (or report blockers).

6. If install fails (e.g. skills not found locally to copy), tell the user
   exactly what to install manually and where.

## Do not

- Run `clearpath-doctor-install` without explicit user approval.
- Set `CLEARPATH_DOCTOR_INSTALL_APPROVED=1` without the user saying yes.
- Proceed with `/clearpath:design-prototype` if required skills or MCPs
  are still missing after the user declined install — stop and explain.

## Other commands

- `clearpath-index` — refresh artifact index
- `clearpath-artifact-lint` — lint project artifacts
- `claude plugin validate . --strict` — from plugin root when CLI available

## Clearpath invariants

- Read `.clearpath/docs/BOOT.md` when diagnosing a initialized project.
- Record install outcome in `CURRENT_CONTEXT.md` if a workflow is active.
