# Changelog

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

- P0: new skill `skills/impeccable/SKILL.md` for UI craft and
  execution polish (spacing, alignment, density, micro-interactions,
  accessibility, responsive).
- P0: new skill `skills/taste-design/SKILL.md` for product taste,
  concept, brand, and UX direction. The two skills are
  non-overlapping; the `design-critic` agent aggregates them
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
