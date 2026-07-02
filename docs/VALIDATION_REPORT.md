# Clearpath Validation Report

This report is regenerated per release. If a check was not run, it
must say `NOT RUN` and the reason. Do not infer a PASS for a check
that was skipped.

## Latest patch

- Patch: `v0.4.3 Approval Sentinel Hardening + Autonomy Gate`
- Scope:
  - **P0 security fix**: closed a confirmed, live-tested
    approval-sentinel bypass (path indirection via shell variables,
    `cd`-relative references, `../` traversal, and dot-slash
    obfuscation) in both `pre-tool-use-safety-gate.sh` and
    `pre-tool-use-design-approval-gate.sh`.
  - New hard gate: source-control finalization (`git commit`/`push`/
    `tag`/`rebase`/`filter-branch`/`--amend`/`reset --hard`) now
    requires a new `allow-git-finalize` sentinel. `git add` and
    read-only git commands remain unblocked.
  - Fixed `*.sln`/`*.csproj` dead-code glob bug in
    `clearpath-detect-mode.sh`.
  - Fixed the UserPromptSubmit intent classifier missing
    review/audit/inspection language (including the plugin's own
    README example).
  - Wired the MCP fallback policy into `skills/adopt/SKILL.md` and
    `agents/codebase-architect.md`; `clearpath-doctor.sh` now
    hard-fails missing Serena/Codebase-Memory prerequisites for large
    adopt-existing-project targets instead of only warning.
  - Added `templates/project/.mcp.windows-mcp.example.json` and a
    Windows-MCP section in `docs/SECURITY_HARDENING.md`.
  - Bound the six `REVIEW.md` lenses to named agents in
    `skills/review/SKILL.md`.
  - Gave `qa-release-engineer` `Write`/`Edit` tools and an explicit
    QA+release conflation rationale; added an explicit boundary
    between `qa-release-engineer` and `security-reviewer`.
  - Added `docs/SUBAGENT_DISPATCH.md` with concrete fresh-context
    dispatch thresholds, referenced from every skill's invariant line.
  - Untracked `.serena/` from git.
  - Plugin manifest version bumped from `0.4.1` to `0.4.3` (it had
    never been updated across the three prior `0.4.2` CHANGELOG
    entries).
  - See `CHANGELOG.md` for full detail on every change in this patch.

## Unreleased marketplace preparation

- Added Claude Code marketplace manifest at
  `.claude-plugin/marketplace.json`.
- Added GitHub marketplace install instructions in `README.md` and
  `docs/INSTALL.md`.
- No governance hook changes.
- No MCP config changes.

## Commands run

```bash
bash tests/plugin-structure-test.sh
bash tests/hook-smoke-test.sh
bash tests/autopilot-detect-mode-test.sh
./bin/clearpath-doctor
claude plugin validate . --strict
```

## Result

- Plugin structure test: PASS
- Hook smoke test: PASS
- Autopilot detect-mode test: PASS
- Doctor hard failures: PASS (0 failures)
- `claude plugin validate . --strict`: PASS

## Hook coverage tested

Safety gate denies (through v0.4.3):

- malformed JSON
- approval sentinel `Write` to `.clearpath/approvals/design-approved`
- design approval doc edit
- `.env` edit
- `dd ... of=.clearpath/approvals/...`
- `install -m 644 /dev/null .clearpath/approvals/...`
- `: > .clearpath/approvals/...`
- `echo > .clearpath/approvals/...`
- `awk BEGIN{... > ".clearpath/approvals/..."}`
- `python3 -c "open('.clearpath/approvals/...','w')..."`
- **v0.4.3**: `cd .clearpath/approvals && touch design-approved`
  (and `allow-production-release`) — confirmed live bypass of the
  pre-v0.4.3 gate, now denied
- **v0.4.3**: `D=.clearpath/approvals; touch "$D/allow-production-release"`
  and `D=.clearpath/approvals; echo x > "$D/design-approved"`
  (variable-split path) — confirmed live bypass, now denied
- **v0.4.3**: `DIR=".clearpath"; SUB="approvals"; touch "$DIR/$SUB/design-approved"`
  (two-variable split) — now denied
- **v0.4.3**: `touch .clearpath/./approvals/design-approved`
  (dot-slash obfuscation) — now denied
- **v0.4.3**: `cd some/nested/dir && touch ../../../.clearpath/approvals/design-approved`
  (`../` traversal) — now denied
- `npm install`, `npm ci`, `uv sync`
- `yarn dlx`, `pnpm dlx`, `bunx`, `deno run -A`
- `make install`, `find -delete`, `python3 -c "shutil.rmtree(...)"`
- `/usr/bin/pip3 install`, `/usr/local/bin/npm install`
- `npx -y some-package`
- `curl https://... | sh`
- `rm -rf /tmp/...`
- `psql -c "truncate table users"`
- `vercel deploy --prod`
- **v0.4.3 (new gate)**: `git commit`, `git push`, `git push --force`,
  `git tag`, `git rebase`, `git commit --amend`, `git reset --hard`,
  `git filter-branch` — all denied without `allow-git-finalize`

Safety gate allows:

- `npm test`
- non-secret source edit
- `npm ci` after manual `allow-dependency-install` sentinel
- `test -f .clearpath/approvals/design-approved`
- `[ -f .clearpath/approvals/design-approved ]`
- `ls .clearpath/approvals`
- `cat .clearpath/approvals/design-approved`
- **v0.4.3**: `git add`, `git status`, `git diff`, `git log`, a plain
  `git reset` (not `--hard`) — none require `allow-git-finalize`
- **v0.4.3**: `git commit`, `git push` after manual
  `allow-git-finalize` sentinel

Design gate denies before manual design approval (through v0.4.3):

- `Edit|Write|MultiEdit` and `Bash` to `pages/index.js`,
  `src/components/Button.js`, `app/layout.ts`, `src/app/page.tsx`,
  `styles/globals.css`
- `Bash` writes (cat redirect, tee, printf, echo, cp) to
  `components/Button.tsx`, `app/page.tsx`,
  `mobile/screens/HomeScreen.tsx`, `lib/widgets/home_widget.dart`,
  `source/App.vue`
- self-write of `.clearpath/approvals/design-approved`
- **v0.4.3**: `cd .clearpath/approvals && touch design-approved`,
  `D=.clearpath/approvals; echo x > "$D/design-approved"`, and
  `mkdir -p sub && cd sub && touch ../.clearpath/approvals/design-approved`
  — all confirmed live bypasses of the pre-v0.4.3 gate, now denied

Design gate allows:

- `prototype/index.html`
- `docs/examples/sample.css`
- `src/lib/api.ts`
- `prototype/App.vue` via Bash
- `docs/examples/note.md` via Bash
- production UI files (Edit, Write, Bash) after manual
  `.clearpath/approvals/design-approved` sentinel

## Results

- `bash tests/plugin-structure-test.sh`: **PASS**
- `bash tests/hook-smoke-test.sh`: **PASS (84/84 cases, counted via
  `grep -c '^PASS'` on the actual run output)** — includes the
  pre-v0.4.3 baseline plus new v0.4.3 cases covering the
  approval-sentinel-bypass regression (`cd`-relative, variable-split,
  two-variable-split, dot-slash, `../` traversal — across both hooks)
  and the new git-finalize gate (deny commit/push/push --force/tag/
  rebase/amend/hard-reset/filter-branch without the sentinel; allow
  add/status/diff/log/plain-reset always; allow commit/push after the
  sentinel is created).
- `bash tests/autopilot-detect-mode-test.sh`: **PASS (10/10)** — the
  original 8 cases plus a `.sln` glob-detection regression case and a
  README-adopt-example classifier regression case.
- `bash scripts/clearpath-doctor.sh` (run against the plugin repo
  itself): **PASS (0 failures, 5 warnings)** — warnings are
  `node`/`npx`/`uvx`/`codebase-memory-mcp`/`claude` CLI not on PATH in
  the validation sandbox, which is environmental, not a plugin
  failure. Doctor's new large-adopt hard-fail escalation was verified
  separately against synthetic 250-file and 1-file test repos (see
  CHANGELOG for detail); it correctly failed only the large one.
- `claude plugin validate . --strict`: **PASS**

Run date: 2026-07-02. v0.4.3 Approval Sentinel Hardening + Autonomy
Gate run. Every new behavior described in this report was verified by
directly invoking the hook scripts (with a real `jq` binary) and
observing the JSON `permissionDecision` output, not by static reading
of the script source alone.

## Notes

- Hooks remain regex guardrails, not a security sandbox. The v0.4.3
  fix closes one specific, confirmed bypass class (path indirection);
  it does not claim to be exhaustive against all possible obfuscation.
- `codebase-memory-mcp`/`uvx`/`node`/`npx`/`claude` warnings are
  environmental and not plugin-structure failures in a sandbox without
  those tools installed.
- Windows-MCP is still absent from the plugin's own `.mcp.json` by
  design (opt-in per project); v0.4.3 adds the example config and
  documentation that were previously missing, but does not add
  Windows-MCP to the default MCP layer.
- The source-control finalization boundary is now hook-enforced for
  the destructive/finalizing git actions (`commit`/`push`/`tag`/
  `rebase`/`filter-branch`/`amend`/`hard reset`). `git add` remains
  intentionally unblocked so the agent can stage changes for user
  review without needing a sentinel for that step.
- Subagent dispatch thresholds (`docs/SUBAGENT_DISPATCH.md`) are
  skill-level instructions, not hook-enforced — no hook can observe a
  dispatch decision before it happens. This is stated explicitly in
  that document rather than left implicit.

## Known environment warnings

- `codebase-memory-mcp`, `uvx`, `node`, `npx`, and `claude` CLI were
  not installed on PATH in the validation sandbox used to run the
  `.sh` test suite (a WSL bash environment). `claude plugin validate`
  was run separately from a Windows shell where the `claude` CLI is
  installed, and passed.
