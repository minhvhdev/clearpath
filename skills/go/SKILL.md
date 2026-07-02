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
   prototype / design reviews / user approves in chat / execute /
   verify / release candidate.
6. Write or update `.clearpath/docs/AUTOPILOT.md` whenever the
   route changes or a workflow step starts.
7. Stop for user input only at:
   - the design checkpoint (present prototype, wait for Approve or
     Request changes),
   - release candidate review if the user wants one,
   - real blockers (scope change, missing credentials, unrecoverable
     test failure).

## Clarification policy

Do not ask routine questions. Ask only when:

- the product goal is ambiguous enough to risk building the wrong
  thing,
- there are multiple materially different UX/product directions,
- credentials or external access are missing,
- the requested change exceeds current scope.

If the user request is enough to start discovery or design, proceed
with assumptions and record them in `ASSUMPTIONS.md` or the active
change artifact.

## Design and verification

- Before UI work, ensure prerequisites via `/clearpath:doctor`. Required
  user-scope skills: `design-taste-frontend`, `impeccable`. Required
  MCP: chrome-devtools, serena, codebase-memory-mcp.
- If the work involves UI, follow `/clearpath:design-prototype`:
  mandatory skills → HTML+Tailwind prototype → present → wait for
  **Approve** or **Request changes** in chat.
- If the user replies with approval, follow `/clearpath:autonomy`
  immediately — implement, test, fix, verify, and continue without
  routine questions.
- For verification, route by platform: web ->
  `/clearpath:verify-web`; Windows native ->
  `/clearpath:verify-windows`; otherwise use `/clearpath:qa` with
  Chrome DevTools MCP.

## Relationship to the autopilot hooks

`/clearpath:go` is the *manual* entrypoint. The autopilot hooks
inject context that tells the model to behave as if `/clearpath:go`
was invoked.

## Clearpath invariants

- Do not treat artifacts as automatic context. Read
  `.clearpath/docs/BOOT.md`, then `CURRENT_CONTEXT.md`, then the
  active `CHANGE_INDEX.md` before drilling into details.
- Use the three required MCP capabilities when relevant: Serena for
  symbol/navigation, Codebase-Memory for large-repo knowledge, and
  Chrome DevTools MCP for browser QA.
- Do not implement production UI before the user approves the design
  in chat.
- Record durable product/change state in artifacts, but summarize
  current state in `CURRENT_CONTEXT.md`, `CHANGE_INDEX.md`, and
  `AUTOPILOT.md`.
