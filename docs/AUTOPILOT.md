# Clearpath Autopilot (v0.4.2)

Clearpath Autopilot is the default UX layer. It is an orchestration
layer on top of the existing skills (`/clearpath:init`,
`/clearpath:start`, `/clearpath:update`, `/clearpath:adopt`,
`/clearpath:design-prototype`, `/clearpath:taste-design`,
`/clearpath:impeccable`, `/clearpath:autonomy`,
`/clearpath:execute`, `/clearpath:verify`,
`/clearpath:verify-web`, `/clearpath:verify-windows`).

The goal is: a user installs Clearpath, opens Claude Code, and says
what they want. They should not have to memorize slash commands.

## What Autopilot does

- On `SessionStart`, runs `scripts/clearpath-detect-mode.sh`,
  detects the project mode, and injects routing context for
  Claude. The hook does not write files.
- On `UserPromptSubmit`, classifies the user prompt into a broad
  intent (`build-new-product`, `implement-change`, `fix-bug`,
  `design-prototype`, `verify-test`, `release-review`,
  `explain-status`, or `unrelated`) and injects routing context
  for Claude. The hook does not block normal prompts and does not
  write files.
- Adds `/clearpath:go` as the manual single entrypoint. When the
  user types `/clearpath:go` (or behaves as if it was invoked),
  the model follows the same routing context.

## What Autopilot does not do

- It does not silently write project files at session start. The
  only files created at session start are existing Clearpath
  artifacts the operator has chosen to keep.
- It does not guarantee the model always picks the perfect route.
  The hook layer injects context; the model decides.
- It does not replace the safety and design approval gates. Those
  hooks remain the hard boundary for protected actions.
- It does not weaken the source-control finalization boundary.
  `git add` / `git commit` / `git push` / tags / history rewrite
  still require explicit user approval.
- It does not weaken the Windows-MCP opt-in boundary.
  CursorTouch/Windows-MCP remains opt-in per project, default-deny
  for PowerShell / Registry / FileSystem / Process.

## Detection modes

`scripts/clearpath-detect-mode.sh` is read-only. It returns one of:

- `existing-clearpath-project` (high): `docs/clearpath/BOOT.md`,
  `docs/clearpath/CURRENT_CONTEXT.md`, or `.clearpath/` exists.
  Route: `/clearpath:update`.
- `adopt-existing-project` (high): code manifest or src tree
  present, no Clearpath artifacts, ≥ 5 tracked files or `src`/`app`/
  `lib` present. Route: `/clearpath:adopt`.
- `new-scaffolded-project` (medium): manifest present but few
  tracked files and no source tree. Route: `/clearpath:init` then
  `/clearpath:start`.
- `new-empty-project` (high or medium): empty directory or no
  recognized manifest. Route: `/clearpath:init` then
  `/clearpath:start`.
- `unknown` (low): detection failed (jq missing, malformed input,
  no detector). Route: `/clearpath:go` and let the user clarify.

## Clarification policy

The autopilot asks only when:

- the product goal is ambiguous enough to risk building the wrong
  thing,
- there are multiple materially different UX/product directions,
- credentials or external access are missing,
- the requested change exceeds current scope,
- a governance boundary is touched.

Otherwise the model proceeds with assumptions and records them in
`ASSUMPTIONS.md` or the active change artifact. This is enforced
by skill wording, not by a hook.

## Design approval checkpoint

When the request involves UI, the autopilot calls
`/clearpath:design-prototype`, which:

1. Produces or refines the prototype direction.
2. Runs `/clearpath:taste-design` to validate art direction and
   anti-generic frontend/product taste.
3. Runs `/clearpath:impeccable` to validate execution precision,
   consistency, implementation readiness, and UI anti-patterns.
4. Writes `UI_CONTRACT.md` and `DESIGN_REVIEW.md`.
5. Stops for user design approval before production UI edits.

The user creates `.clearpath/approvals/design-approved` outside
Claude Code to approve. The design gate enforces this.

## Post-approval autonomy

After design and scope are approved, the autopilot calls
`/clearpath:autonomy` for the code -> test -> fix -> retest ->
release candidate loop. The model stops only at the design
approval checkpoint, the release candidate review, or a real
blocker.

## Platform-specific verification routing

- Web UI: `/clearpath:verify-web` (Playwright for regression/E2E,
  Chrome DevTools MCP for live inspect/debug).
- Windows native / Electron: `/clearpath:verify-windows`
  (CursorTouch/Windows-MCP, opt-in, default-deny dangerous tools).
- Other platforms: `/clearpath:qa` (Chrome DevTools MCP browser QA).

## Output

`docs/clearpath/AUTOPILOT.md` is created or updated only when one
of the workflow skills actually runs. It records:

- Detected mode
- Last route
- Current phase
- Design approval status
- Implementation status
- Verification status
- Release candidate status
- Open blockers
- Next expected action
- Last updated (ISO 8601 timestamp)

The template is at
`templates/project/docs/clearpath/AUTOPILOT.md` for reference.
The file is continuity metadata for the next session, not a gate.

The SessionStart and UserPromptSubmit hooks are read-only and
never write this file. Only the workflow skills
(`/clearpath:go`, `/clearpath:init`, `/clearpath:start`,
`/clearpath:update`, `/clearpath:adopt`) update it, and only when
they actually run.

## Known limitations

- The hook layer injects context; the model is still free to
  classify a request differently. Power users can still invoke
  individual skills directly.
- The prompt classifier is keyword-based. A request phrased in an
  unusual way may be classified as `unrelated` even when it should
  be `implement-change`. The hook then injects only a marker, and
  the model must recognize the request.
- `scripts/clearpath-detect-mode.sh` requires `jq`. If `jq` is
  missing, the script returns exit 2 and the hook falls back to
  `unknown` / `low` confidence.
- The autopilot state file (`docs/clearpath/AUTOPILOT.md`) is not
  auto-created at session start. It is created or updated only by
  the workflow skills (`/clearpath:go`, `/clearpath:init`,
  `/clearpath:start`, `/clearpath:update`, `/clearpath:adopt`)
  when they actually run. The SessionStart and UserPromptSubmit
  hooks are read-only.
- The state file is not auto-tracked. The skill instruction tells
  the model to write it; the plugin does not enforce that the
  file is updated at every step. Operators who want strict
  tracking must layer their own checks.

## Reporting limitations honestly

- Autopilot is an orchestration layer, not a replacement for
  approval gates. The safety and design gates remain the hard
  boundary.
- The classifier is heuristic. Operators should review the first
  routed decision in a new project and override the route if it is
  wrong.
- The session-start hook is read-only. Operators can rely on the
  fact that session start does not silently mutate the project.
