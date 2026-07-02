---
description: Default Clearpath Autopilot entrypoint. Reads the detected project mode and the user's request, then routes to the correct workflow without requiring the user to pick a skill.
---

# /clearpath:go

The default Clearpath Autopilot entrypoint. Use this if the user
explicitly types `/clearpath:go`, or behave as if it was invoked when
the SessionStart/UserPromptSubmit autopilot hooks inject context.

## What this skill does

1. Read the Clearpath Autopilot context injected by the hooks. If
   the hooks are not active in this session, run
   `scripts/clearpath-detect-mode.sh` once to learn the project mode.
2. Confirm the project mode:
   - `new-empty-project` or `new-scaffolded-project`: route to
     `/clearpath:init`, then `/clearpath:start`.
   - `existing-clearpath-project`: route to `/clearpath:update`.
   - `adopt-existing-project`: route to `/clearpath:adopt`.
3. Understand the user's request.
4. Decide whether clarification is needed (see "Clarification
   policy" below). If not, proceed and record assumptions in
   `ASSUMPTIONS.md` or the active change pack.
5. Drive the standard flow: discover / discuss / spec / plan /
   prototype / design reviews / user design approval / execute /
   verify / release candidate.
6. Write or update `docs/clearpath/AUTOPILOT.md` whenever the
   route changes or a workflow step starts. The file uses these
   fields (in order): Detected mode, Last route, Current phase,
   Design approval status, Implementation status, Verification
   status, Release candidate status, Open blockers, Next expected
   action, Last updated (ISO 8601). The SessionStart and
   UserPromptSubmit hooks are read-only and never write this file;
   only the workflow skills that actually drive a step do. The
   file is continuity metadata, not a governance gate.
7. Stop for user review at:
   - design approval (before production UI edits),
   - release candidate review,
   - any real blocker (scope change, governance boundary, missing
     credentials, unrecoverable test failure).

## Clarification policy

Do not ask routine questions. Ask only when:

- the product goal is ambiguous enough to risk building the wrong
  thing,
- there are multiple materially different UX/product directions,
- credentials or external access are missing,
- the requested change exceeds current scope,
- a governance boundary is touched (dependency install, secret
  edit, destructive data, production release, destructive shell).

If the user request is enough to start discovery or design, proceed
with assumptions and record them in `ASSUMPTIONS.md` or the active
change artifact. Do not gate progress on minor questions.

## Design and verification

- If the work involves UI, follow `/clearpath:design-prototype`:
  prototype -> `/clearpath:taste-design` -> `/clearpath:impeccable`
  -> `UI_CONTRACT.md` -> `DESIGN_REVIEW.md` -> stop for user design
  approval before production UI edits.
- After approval, follow `/clearpath:autonomy` for the
  code -> test -> fix -> retest -> release candidate loop.
- For verification, route by platform: web ->
  `/clearpath:verify-web`; Windows native ->
  `/clearpath:verify-windows`; otherwise use `/clearpath:qa` with
  Chrome DevTools MCP.

## Relationship to the autopilot hooks

`/clearpath:go` is the *manual* entrypoint. The autopilot hooks
(`scripts/session-start-autopilot.sh` and
`scripts/user-prompt-autopilot.sh`) inject context that tells the
model to behave as if `/clearpath:go` was invoked. This skill
documents the behavior the model should follow in that case.

The hooks do not silently write project files. The only files
written at session start are existing Clearpath artifacts that the
operator has chosen to keep. New state lives in
`docs/clearpath/AUTOPILOT.md` and is created by `/clearpath:go`,
`/clearpath:init`, `/clearpath:start`, `/clearpath:update`, or
`/clearpath:adopt` only when they actually run.

## Clearpath invariants

- Do not treat artifacts as automatic context. Read
  `docs/clearpath/BOOT.md`, then `CURRENT_CONTEXT.md`, then the
  active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for
  symbol/navigation, Codebase-Memory for large-repo knowledge, and
  Chrome DevTools MCP for browser QA.
- Dispatch a fresh-context subagent for heavy research, planning,
  execution, review, or QA -- see `docs/SUBAGENT_DISPATCH.md` for
  concrete thresholds (roughly >15 files/>2,000 lines to read, >8
  turns of work, or any review/QA/security lens, which is always
  fresh-context).
- Do not implement production UI before design approval exists.
- Do not install dependencies, edit secrets, run destructive data
  commands, or deploy production without manual user approval
  outside Claude Code.
- Source-control finalization is not automatic. It requires explicit
  user approval or a workflow permission.
- Record durable product/change state in artifacts, but summarize
  current state in `CURRENT_CONTEXT.md`, `CHANGE_INDEX.md`, and
  `AUTOPILOT.md`.
