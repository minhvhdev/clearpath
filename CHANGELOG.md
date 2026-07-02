# Changelog

## 0.4.2 - Design Skill Alignment

Small wording alignment before final review. No behavior change.
No hooks, scripts, approval sentinels, source-control boundary,
Windows-MCP boundary, or autopilot hook behavior change.

- `skills/taste-design/SKILL.md` reworded to art direction,
  anti-generic frontend/product taste, visual identity, product
  vibe, and high-level typography/layout/motion/density judgment.
- `skills/impeccable/SKILL.md` reworded to precise UI execution
  critique, implementation-quality polish, states, accessibility,
  responsive behavior, and implementation-level UI anti-patterns.
- Boundary made altitude-based: both skills may inspect typography,
  layout, motion, and density; taste-design judges them at
  art-direction/product-taste level, impeccable judges them at
  execution, consistency, implementation-readiness, and anti-pattern
  level.
- `skills/design-prototype/SKILL.md` no longer claims the two
  reviews are non-overlapping; instead it describes them as
  complementary at different altitudes and explains the order.
- `agents/design-critic.md` and `agents/ux-designer.md` updated
  with the aligned delegate wording and explicit conflict
  aggregation behavior.
- `docs/AUTOPILOT.md` updated with the design checkpoint mental
  model for both skills.
- `docs/CLEARPATH_PRODUCT_DIRECTION.md` updated Workflow A to run
  taste-design then impeccable, and the skills section now names
  the aligned roles.
- `README.md` updated to describe the two skills as complementary
  direction vs. execution.
- `CHANGELOG.md` 0.4.1 historical bullets reworded to match the
  aligned roles.

## 0.4.2 - Autopilot State Patch

Small follow-up to v0.4.2 Autopilot UX. Implements the
`docs/clearpath/AUTOPILOT.md` continuity file that v0.4.2
documented but did not implement.

- New template `templates/project/docs/clearpath/AUTOPILOT.md`
  ships the field list (Detected mode, Last route, Current phase,
  Design approval status, Implementation status, Verification
  status, Release candidate status, Open blockers, Next expected
  action, Last updated).
- `skills/go/SKILL.md`, `skills/init/SKILL.md`,
  `skills/start/SKILL.md`, `skills/update/SKILL.md`, and
  `skills/adopt/SKILL.md` each gain a step that tells the model
  to create or update `docs/clearpath/AUTOPILOT.md` when the
  skill actually drives a workflow step.
- The file is explicitly described as **continuity metadata, not
  a governance gate** in the operator docs and in each skill.
- SessionStart and UserPromptSubmit hooks remain read-only. The
  state file is created/updated only when a workflow skill runs.
- `docs/AUTOPILOT.md` updated to spell out the read-only-hook
  contract, the field list, and the non-tracking caveat
  (the plugin does not enforce the file is updated at every
  step; the skill instructions do).

## 0.4.2 - Autopilot UX

Adds a default-UX layer on top of the existing skills. The user no
longer needs to remember slash commands for normal use.

- New skill `skills/go/SKILL.md` (`/clearpath:go`): the default
  Clearpath Autopilot entrypoint. Reads the detected project mode
  and the user's request, then routes to the correct workflow
  without requiring the user to pick a skill.
- New script `scripts/clearpath-detect-mode.sh`: read-only
  detector that returns one of `existing-clearpath-project`,
  `adopt-existing-project`, `new-scaffolded-project`,
  `new-empty-project`, or `unknown`. Supports `--format text` and
  JSON-on-stdin; emits compact JSON by default.
- New script `scripts/session-start-autopilot.sh`: SessionStart
  hook. Injects routing context for Claude. Does not write files.
- New script `scripts/user-prompt-autopilot.sh`: UserPromptSubmit
  hook. Classifies the prompt and injects routing context. Does
  not block normal prompts and does not write files.
- `hooks/hooks.json` updated: added `UserPromptSubmit` entry and a
  second `SessionStart` entry for the autopilot. PreToolUse
  matchers, Stop hook, and the existing `session-start-load-state`
  hook are unchanged.
- Existing skills (`init`, `start`, `update`, `adopt`,
  `design-prototype`, `autonomy`, `execute`, `verify`,
  `verify-web`, `verify-windows`) gain a one-line note saying they
  are called by the autopilot router and that `/clearpath:go` is
  the default manual entrypoint. Behavior is unchanged.
- `templates/project/CLAUDE.md` and
  `templates/project/docs/clearpath/BOOT.md` updated to reference
  the autopilot context.
- New `docs/AUTOPILOT.md` documents what the autopilot does and
  does not do, the detection modes, the clarification policy, the
  design approval checkpoint, the post-approval autonomy, the
  verification routing, and the known limitations honestly.
- New `tests/autopilot-detect-mode-test.sh` covers four
  scenarios: empty dir, scaffolded dir, Clearpath project, and
  adopt-existing project.

Governance hardening from v0.4.1 is unchanged. The safety and
design gates, the approval sentinel model, the source-control
finalization boundary, and the Windows-MCP opt-in boundary are
preserved.

## 0.4.1 - Pre-Commit Hardening

Small hardening patch on top of v0.4.1 P0 workflow hardening.

- Source-control autonomy boundary: the post-approval autonomy
  contract no longer auto-allows `git add`, `git commit`, `git push`,
  tags, or history rewrite. The agent may prepare a commit summary
  and suggest files to stage, but finalizing source-control
  changes requires explicit user approval or workflow permission.
  `skills/autonomy/SKILL.md`, `skills/execute/SKILL.md`, and
  `agents/implementation-engineer.md` updated.
- Schema-clean `templates/project/.claude/settings.json`: the
  inline `_comment` field was removed from the JSON; operator-
  facing explanation moved to `docs/SECURITY_HARDENING.md`,
  `docs/INSTALL.md`, and `README.md`. The file is intentionally
  schema-clean and is not auto-applied.
- Node `writeFileSync` regression coverage: the design gate now
  detects wrapped Node writes
  (`require('fs').writeFileSync('app/page.tsx', '')`,
  `require("fs").writeFileSync(...)`, bare `fs.writeFileSync(...)`)
  in `scripts/pre-tool-use-design-approval-gate.sh`. Four new
  regression cases in `tests/hook-smoke-test.sh` (deny without
  approval, deny on `components/`, allow on `prototype/`, allow
  after design approval).
- Hook detection surface for `cat >`, `tee`, `cp`/`mv`/`install`,
  `python open(..., "w")`, and the literal `writeFileSync(...)`
  form is unchanged. The wrapped Node write cases are additive.

## 0.4.1 - P0 Workflow Hardening

Workflow hardening release on top of the v0.4.1 governance gates.
Hooks and test coverage are unchanged; the change is in skills,
agents, and docs that operators can use.

- P0: new skill `skills/impeccable/SKILL.md` for precise UI
  execution critique and implementation-quality polish: consistency,
  implementation readiness, accessibility, responsive behavior,
  states, micro-interactions, and implementation-level anti-patterns.
- P0: new skill `skills/taste-design/SKILL.md` for art direction,
  anti-generic frontend/product taste, visual identity, concept,
  brand, UX direction, and high-level typography/layout/motion/
  density judgment. The two skills share visual vocabulary but split
  by altitude: taste-design judges direction and product taste;
  impeccable judges execution, consistency, implementation readiness,
  and anti-patterns. The `design-critic` agent aggregates them
  rather than duplicating their checklists.
- P0: `skills/design-prototype/SKILL.md` now orchestrates
  taste-design first, impeccable second, then `UI_CONTRACT.md` and
  `DESIGN_REVIEW.md`, then stops for user design approval.
- P0: `agents/ux-designer.md` produces the prototype and contract;
  delegates reviews to the two skills and to the `design-critic`
  agent.
- P0: new skill `skills/autonomy/SKILL.md` defines the
  post-design-approval autonomy contract (automatic vs. must-stop).
  `skills/execute/SKILL.md`, `skills/verify/SKILL.md`,
  `agents/implementation-engineer.md`, and
  `agents/qa-release-engineer.md` reference it.
- P0: new skill `skills/verify-web/SKILL.md` for web verification,
  with explicit Playwright vs. Chrome DevTools MCP role split and
  `tests/e2e/` convention.
- P0: new skill `skills/verify-windows/SKILL.md` for Windows native
  / Electron/WebView2 verification using CursorTouch/Windows-MCP.
  Opt-in per project, default-deny for PowerShell, Registry,
  FileSystem, and Process tools.
- P0: `skills/qa/SKILL.md` and `skills/verify/SKILL.md` route to
  the platform-specific verification skill.
- P0: new `templates/project/.claude/settings.json` is a
  recommended defense-in-depth permissions example (deny writes to
  approval sentinels). Hooks remain authoritative.
- Docs: `README.md`, `docs/INSTALL.md`,
  `templates/project/CLAUDE.md`, and
  `templates/project/docs/clearpath/BOOT.md` updated to reference
  the new skills.

## 0.4.1 - Governance Hardening

Governance hardening release. No new features; existing gates are
tightened against specific bypass classes and the operator docs now
match the runtime.

- P0: approval sentinel protection is now fail-closed by path and
  sentinel name in `pre-tool-use-safety-gate.sh`. Any `Bash` command
  that mentions `.clearpath/approvals/`, an explicit sentinel
  filename, or `*_APPROVAL.*` is denied by default; only narrow
  read-only checks (`test -f`, `[ -f ]`, `ls`, `cat`) are allowed.
- P0: design approval gate now denies `Bash` writes to production
  UI files. Redirects, `tee`, `cp`/`mv`/`install` destinations, and
  `python open(...)` / `node writeFileSync(...)` are extracted and
  evaluated against the production-UI path heuristic.
- P0: production UI path heuristic expanded to include
  `components/`, `app/`, `pages/`, `src/`, `source/`, `mobile/`,
  `screens/`, `widgets/`, `lib/widgets/` for `.tsx`, `.jsx`, `.vue`,
  `.svelte`, `.css`, `.scss`, `.dart`, `.swift`, `.kt` extensions.
- P0: dependency install detection expanded with absolute-path
  normalization (`/usr/bin/pip3`, `/usr/local/bin/npm`, ...) and
  new forms: `yarn dlx`, `pnpm dlx`, `bunx`, `deno run -A`,
  `make install`, `find -delete`, `python3 -c "shutil.rmtree(...)"`.
- P1: agents frontmatter now declares valid `tools:` boundaries
  matching each agent's scope (read-only, artifact-edit, code-edit,
  QA).
- P1: `stop-update-state.sh` renamed to `stop-ensure-state.sh` and
  hook reference updated. Comment now reflects the ensure-only
  behavior.
- P1: `policy.json` is now documented as reference-only. No hook
  reads it at runtime; enforcement lives in the scripts.
- P1: new `docs/SECURITY_HARDENING.md` describes the guardrail-vs-
  sandbox boundary, defense-in-depth recommendations, and
  reporting limitations honestly.
- Regression: `tests/hook-smoke-test.sh` covers all new bypasses
  and the design gate Bash writes for `components/`, `app/`,
  `mobile/screens/`, `lib/widgets/`, and `source/`.

## 0.4.0

- Converted Clearpath into a complete plugin source tree.
- Added full unified workflow skills.
- Added nine specialized agents.
- Added strict safety and design approval hooks.
- Added self-approval protection for approval sentinels.
- Added Context Ledger templates, indexer, artifact linter, and doctor.
- Added required MCP config for Chrome DevTools, Serena, and Codebase-Memory.
