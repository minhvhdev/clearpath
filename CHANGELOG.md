# Changelog

## Unreleased

## 0.4.7 - Cursor fallback + Claude hook fix

### Fixed

- **Chrome DevTools screenshot payloads**: added default screenshot
  guardrails to `.mcp.json` (`jpeg`, quality 70, max `1600x3000`) so
  oversized `take_screenshot` images are less likely to exceed strict
  provider request-body limits.
- **Cursor Clearpath fallback**: added always-applied Cursor rule files
  under `.cursor/rules/clearpath.mdc` (repo and project template) so
  new chats still receive Clearpath workflow guidance when IDE hook
  context is not delivered reliably.
- **Cursor Autopilot routing fallback**: added
  `.cursor/rules/clearpath-autopilot.mdc` (repo and project template)
  to mirror the `UserPromptSubmit` routing behavior through always-on
  rules for a more Claude Code-like automatic experience.
- **Claude Code plugin loading**: removed the explicit
  `hooks/hooks.json` manifest entry from `.claude-plugin/plugin.json`
  because Claude Code already auto-loads the standard hooks file,
  avoiding duplicate-hook load failures.

## 0.4.6 - Windows hook stability + doctor opt-in hints

### Added

- **Doctor Windows hint**: `clearpath-doctor` now warns about the
  optional `windows-mcp` project opt-in on Windows hosts and points to
  `templates/project/.mcp.windows-mcp.example.json` without treating
  it as a required prerequisite.

### Fixed

- **Cursor on Windows hooks**: Cursor hook entrypoints now launch
  through `hooks/run-hook.cmd` so extensionless hook scripts no longer
  trigger the Windows "Open with" dialog.
- **SessionStart hook hang on Windows**: hook-time scripts now read
  stdin only when data is immediately available, avoiding indefinite
  waits from non-TTY handles that never reach EOF.

## 0.4.5 - Cursor support + distilled guardrails

### Added

- **Cursor support**: added `.cursor-plugin/plugin.json`, Cursor hook
  wrappers, and install docs for running Clearpath as a local Cursor
  plugin.
- **Distilled guardrails**: added
  `/clearpath:implementation-discipline` and
  `/clearpath:review-qa-discipline` to keep execution scoped and
  verdicts evidence-based without duplicating broader generic guidance.
- **Screenshot evidence workflow**: documented workspace-backed
  screenshot capture for prototype review and QA evidence.

### Simplified workflow (breaking)
- **Removed** `.clearpath/approvals/` sentinel file model.
- **Design approval is now in chat**: prototype → present → user
  replies Approve or Request changes → `/clearpath:autonomy` continues.
- Updated skills, agents, templates, autopilot hooks, README, and
  INSTALL to match the simplified workflow.

### Required skills + doctor install

- **Removed** plugin-local `/clearpath:taste-design` and
  `/clearpath:impeccable` stubs.
- **Mandatory** user-scope skills: `design-taste-frontend`,
  `impeccable` (wired in `design-prototype`, `doctor`).
- **`clearpath-doctor`** now checks skills, MCP, and CLI; emits
  `CLEARPATH_DOCTOR_NEEDS_USER_APPROVAL` when install is needed.
- **`clearpath-doctor-install`** installs to user scope after
  `CLEARPATH_DOCTOR_INSTALL_APPROVED=1`.

### Artifact layout + prototype rules

- All Clearpath artifacts now live under `.clearpath/docs/` (project
  state) and `.clearpath/docs/changes/<id>/` (change packs).
- UI prototypes live under `.clearpath/prototype/` as **HTML + Tailwind
  CSS** (Tailwind CDN).

- Added Claude Code marketplace manifest at `.claude-plugin/marketplace.json`.
- Added GitHub marketplace install instructions in `README.md` and
  `docs/INSTALL.md`.

## 0.4.4 - Doctor Windows + Plugin MCP

### Fixed

- **`clearpath-doctor`** on Windows/Git Bash: strip CRLF from `jq`
  output so CLI checks (`jq`, `git`, `node`, `npx`, `uvx`) no longer
  false-fail with trailing `\r`.
- **MCP checks**: treat servers declared in the plugin `.mcp.json`
  manifest as satisfied (matches Claude Code plugin MCP wiring); skip
  unnecessary user-settings merge in **`clearpath-doctor-install`**
  when plugin already provides the server.

## 0.4.3 - Approval Sentinel Hardening + Autonomy Gate

Security-critical patch fixing a confirmed approval-sentinel bypass,
plus the fixes from a full deep audit of the plugin against its
stated GSD Core / Superpowers / gstack synthesis. This release also
finally aligns the plugin manifest version with the CHANGELOG (the
`0.4.2` entries below were never reflected in
`.claude-plugin/plugin.json`, which still read `0.4.1`).

- **P0 SECURITY FIX**: `pre-tool-use-safety-gate.sh` and
  `pre-tool-use-design-approval-gate.sh` had a confirmed, live-tested
  approval-sentinel bypass. The previous boundary regex treated `/` as
  a "safe" character and required a literal trailing slash after
  `.clearpath/approvals`, so splitting the path across a shell
  variable (`D=.clearpath/approvals; touch "$D/allow-..."`) or a bare
  `cd .clearpath/approvals && touch design-approved` bypassed the gate
  entirely — confirmed by directly invoking both hook scripts and
  observing the sentinel file get created. `design-approved`
  additionally had no dedicated name-pattern at all (only `allow-*`
  names were recognized), making it the most exposed sentinel. Fixed:
  the directory pattern no longer requires a trailing slash, every
  known sentinel basename (including `design-approved`) is matched
  independently of the directory path, and the boundary character set
  excludes `/` so path indirection no longer helps. Regression tests
  for `cd`-relative, variable-split, two-variable-split, `../`
  traversal, and dot-slash obfuscation bypass patterns added to
  `tests/hook-smoke-test.sh`.
- **New hard gate**: source-control finalization (`git commit`,
  `git push`, `git tag`, `git rebase`, `git filter-branch`,
  `git commit --amend`, `git reset --hard`, `git push --force`) now
  requires a new `.clearpath/approvals/allow-git-finalize` sentinel in
  `pre-tool-use-safety-gate.sh`. Previously this boundary existed only
  as skill prose (`skills/autonomy/SKILL.md`) with zero hook backing —
  a deep audit confirmed grep found no git-related pattern in either
  hook script. `git add` and read-only git commands (`status`, `diff`,
  `log`, `show`, plain `reset`) remain unblocked so the agent can
  still stage changes for user review without a sentinel.
- Fixed `scripts/clearpath-detect-mode.sh`: `has_any()`'s `*.sln`/
  `*.csproj` entries were dead code — `[[ -e "$dir/*.sln" ]]` checks
  for a file literally named `*.sln`, it does not glob-expand. C#/.NET
  repos were invisible to the adopt-vs-new detector. `has_any()` now
  expands glob patterns with `nullglob` when the argument contains
  `*`/`?`.
- Fixed `scripts/user-prompt-autopilot.sh`'s intent classifier: prompts
  using review/audit/inspection language (including the plugin's own
  README example, "Review this existing codebase and prepare it for
  Clearpath.") classified as `unrelated` and got no routing context.
  Added a `review|audit|assess|inspect|analyze|look at|check out|take
  a look|walk through` pattern mapped to `implement-change`.
- `skills/adopt/SKILL.md` and `agents/codebase-architect.md` now spell
  out the MCP fallback policy operationally (previously it existed
  only in `docs/CLEARPATH_PRODUCT_DIRECTION.md`, which those files
  never referenced): warn-and-ask or explicit limited-mode for large
  repos without Serena/Codebase-Memory, quiet fallback only for small
  repos. `scripts/clearpath-doctor.sh` now escalates missing
  `uvx`/`codebase-memory-mcp` from a warning to a hard failure when the
  target project looks like a large (>= 200 tracked files)
  adopt-existing-project candidate.
- New `templates/project/.mcp.windows-mcp.example.json` and a new
  "Windows-MCP / CursorTouch (opt-in boundary)" section in
  `docs/SECURITY_HARDENING.md`: previously `docs/INSTALL.md` pointed
  to `SECURITY_HARDENING.md` for the Windows-MCP rationale, but that
  section did not exist, and no example opt-in `.mcp.json` snippet
  existed despite `skills/verify-windows/SKILL.md` promising one.
- `skills/review/SKILL.md` now binds each of the six `REVIEW.md`
  lenses to a named Clearpath agent (`product-strategist`,
  `design-critic`, `codebase-architect`, `qa-release-engineer`,
  `security-reviewer`) instead of listing lenses with no dispatch
  contract. `templates/change/REVIEW.md` sections now carry an
  `agent:` comment.
- `agents/qa-release-engineer.md`: added `Write`/`Edit` tools (it was
  writing `QA.md`/`RELEASE_CANDIDATE.md` via `Bash`-only access
  before), added an explicit rationale for combining gstack's QA and
  release roles into one agent, and added a boundary statement so it
  no longer self-certifies security risk that belongs to
  `security-reviewer`. `agents/security-reviewer.md` gained the
  matching boundary statement.
- New `docs/SUBAGENT_DISPATCH.md` gives the previously-vague "keep the
  main session as orchestrator, use focused subagents for heavy work"
  instruction (repeated near-verbatim across ~18 skill files) concrete
  thresholds: read volume, turn volume, parallelizability, and
  "review/QA/security lenses are always fresh-context." Every skill
  file's invariant line now references it instead of the generic
  sentence. This does not add hook enforcement (no hook can observe a
  dispatch decision before it happens) but replaces vague prose with
  an operational default the model can actually apply consistently.
- `.serena/` (a maintainer-local Serena config for working on this
  repo, not a shipped plugin artifact) is no longer tracked in git;
  added to `.gitignore`.
- Plugin manifest version bumped from `0.4.1` to `0.4.3` to match the
  CHANGELOG, which had already reached three `0.4.2` entries without
  the manifest ever being updated.

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
- `skills/design-.clearpath/prototype/SKILL.md` no longer claims the two
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
`.clearpath/docs/AUTOPILOT.md` continuity file that v0.4.2
documented but did not implement.

- New template `templates/project/.clearpath/docs/AUTOPILOT.md`
  ships the field list (Detected mode, Last route, Current phase,
  Design approval status, Implementation status, Verification
  status, Release candidate status, Open blockers, Next expected
  action, Last updated).
- `skills/go/SKILL.md`, `skills/init/SKILL.md`,
  `skills/start/SKILL.md`, `skills/update/SKILL.md`, and
  `skills/adopt/SKILL.md` each gain a step that tells the model
  to create or update `.clearpath/docs/AUTOPILOT.md` when the
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
  `templates/project/.clearpath/docs/BOOT.md` updated to reference
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
  approval, deny on `components/`, allow on `.clearpath/prototype/`, allow
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
- P0: `skills/design-.clearpath/prototype/SKILL.md` now orchestrates
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
  `templates/project/.clearpath/docs/BOOT.md` updated to reference
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
