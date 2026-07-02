# Clearpath

Clearpath is an approval-gated Claude Code product delivery plugin.

It combines:

- **GSD Core-style context engineering**: phase loop, fresh-context work, state artifacts.
- **Superpowers-style development discipline**: spec-first, plan-first, TDD/review when available.
- **gstack-style role review**: product/CEO, design, engineering, QA, security, release.
- **Clearpath governance**: safety gate, design approval gate, release/dependency/data/secret boundaries, and a Context Ledger for artifact memory.

## Install / test locally

From the parent directory of this plugin:

```bash
claude --plugin-dir ./clearpath-plugin
```

Inside Claude Code, use namespaced skills such as:

```text
/clearpath:init
/clearpath:start
/clearpath:update
/clearpath:adopt
/clearpath:doctor
/clearpath:design-prototype
/clearpath:taste-design
/clearpath:impeccable
/clearpath:execute
/clearpath:verify
/clearpath:verify-web
/clearpath:verify-windows
/clearpath:autonomy
```

## Structure

```text
clearpath-plugin/
├── .claude-plugin/plugin.json
├── .mcp.json
├── skills/
├── agents/
├── hooks/hooks.json
├── scripts/
├── bin/
├── tests/
├── templates/
└── docs/
```

Only `.claude-plugin/plugin.json` lives inside `.claude-plugin/`. All components live at the plugin root.

## Required local prerequisites

Hard requirements:

- Claude Code
- Bash-compatible shell
- `jq`
- Git recommended for real projects

MCP layer expected by Clearpath workflows:

- Chrome DevTools MCP via `npx -y chrome-devtools-mcp@latest`
- Serena via `uvx --from git+https://github.com/oraios/serena ... --context=claude-code --project-from-cwd`
- Codebase-Memory MCP via `codebase-memory-mcp` on PATH

Run:

```bash
./bin/clearpath-doctor
```

## Approval model

Claude tools are blocked from creating or editing `.clearpath/approvals/*` and from running `Bash` commands that mention approval paths, sentinel filenames, or `*_APPROVAL.*` documents. The user must create approval sentinels manually outside Claude Code.

Common sentinels:

```text
.clearpath/approvals/design-approved
.clearpath/approvals/allow-dependency-install
.clearpath/approvals/allow-production-release
.clearpath/approvals/allow-destructive-data
.clearpath/approvals/allow-secret-edit
.clearpath/approvals/allow-destructive-shell
```

## Governance (v0.4.1)

Clearpath v0.4.1 is a governance hardening release. The hook gates
are still guardrails, not a security sandbox; they block specific
bypass classes (sentinel writes, dependency install via
`yarn dlx`/`pnpm dlx`/`bunx`/`deno run -A`/absolute-path `pip3`/
`npm install`, `find -delete`, `python3 shutil.rmtree`, and Bash
writes to production UI files including `components/`, `app/`,
`pages/`, `src/`, `source/`, `mobile/`, `screens/`, `widgets/`,
`lib/widgets/`). For the full list and how the gate fails closed, see
[docs/SECURITY_HARDENING.md](docs/SECURITY_HARDENING.md).

`policy.json` is reference-only; the scripts are the runtime
enforcement. Do not rely on editing `policy.json` to change behavior.

### v0.4.1 P0 workflow hardening

In addition to the governance hooks, v0.4.1 adds real workflow
skills for the design and verification phases:

- Design review splits into two non-overlapping skills:
  `/clearpath:taste-design` (product taste, concept, brand, UX
  direction) and `/clearpath:impeccable` (UI craft, execution
  polish). The `design-critic` agent aggregates both. The
  `design-prototype` skill orchestrates them in that order and
  stops for user design approval before production UI edits.
- Post-approval autonomy is codified in `/clearpath:autonomy`. After
  design and scope are approved, the implementation engineer may
  run the code -> test -> fix -> retest loop without asking, except
  where the contract says it must stop (scope change, governance
  boundary, missing credentials, unrecoverable test failure).
  Source-control finalization (`git add`, `git commit`, `git push`,
  tags, history rewrite) is **not** automatic; it requires explicit
  user approval or a workflow permission.
- Web verification splits two roles in `/clearpath:verify-web`:
  Playwright for regression/E2E tests, Chrome DevTools MCP for
  live inspect/debug. The two are not interchangeable.
- Windows native verification is a separate skill,
  `/clearpath:verify-windows`, that uses CursorTouch/Windows-MCP
  for user-like UI testing. Windows-MCP is opt-in per project and
  defaults to deny for PowerShell, Registry, FileSystem, and
  Process tools.

Hooks are guardrails, not a security sandbox. The optional
`templates/project/.claude/settings.json` is a recommended defense-
in-depth permissions layer (schema-clean, not auto-applied; the
operator or init flow must copy it into the target project); the
hooks remain authoritative. See
[docs/SECURITY_HARDENING.md](docs/SECURITY_HARDENING.md) for the
rationale.

## Validation

```bash
./tests/plugin-structure-test.sh
./tests/hook-smoke-test.sh
./bin/clearpath-doctor
claude plugin validate . --strict
```

`claude plugin validate` requires the Claude Code CLI and must be run
in your local environment. The hook gates are guardrails, not a
security sandbox — see [docs/SECURITY_HARDENING.md](docs/SECURITY_HARDENING.md)
for defense-in-depth recommendations.
