# Clearpath Security Hardening (v0.4.3)

This document describes the v0.4.1-v0.4.3 governance hardening and how
the plugin enforces its approval boundaries. It is not a security
audit; it is the operator-facing description of what the gates
actually do, and where defense-in-depth must be added on top.

**v0.4.3 fixed a confirmed live bypass** of the approval-sentinel
protection described below: the previous boundary regex in both hook
scripts treated `/` as a "safe" character and required a literal
trailing slash after `.clearpath/approvals`, so splitting a sentinel
path across a shell variable, or a bare `cd .clearpath/approvals &&
touch design-approved`, bypassed the gate entirely. This was verified
by directly invoking the hook scripts and observing the sentinel file
get created. The fix and regression tests are in
`scripts/pre-tool-use-safety-gate.sh`,
`scripts/pre-tool-use-design-approval-gate.sh`, and
`tests/hook-smoke-test.sh`. If you run an older Clearpath version, this
sentinel-bypass gap applies to `v0.4.0` through `v0.4.2` — upgrade to
`v0.4.3` or later.

## What the hooks enforce

The hook scripts in `scripts/` are guardrails, not a security sandbox.
They block common approval-bypass patterns but they are interpreted
shell logic; they do not, by themselves, prevent a determined or
well-resourced actor from running arbitrary commands.

- `pre-tool-use-safety-gate.sh` denies:
  - Writes (via `Edit|Write|MultiEdit`) to any file under
    `.clearpath/approvals/**` or to `*_APPROVAL.*` documents. It also
    denies equivalent `Bash` commands that mention approval paths,
    sentinel names, or approval documents (default-deny; only narrow
    read-only checks like `test -f`, `[ -f ]`, `ls`, and `cat` are
    allowed).
  - Dependency install / implicit execution, including `npm install`,
    `npm ci`, `npm add`, `yarn install`, `yarn add`, `yarn dlx`,
    `pnpm install`, `pnpm add`, `pnpm dlx`, `bun install`, `bun add`,
    `bunx`, `pip3 install`, `pip install`, `pipenv install`,
    `poetry install|add`, `uv sync|add|pip install`, `cargo install`,
    `go get|install`, `playwright install`, `npx -y`, and `deno run -A`
    (also matched when the executable is referenced by an absolute
    path like `/usr/bin/pip3` or `/usr/local/bin/npm`).
  - Destructive shell, including `rm -rf`, `sudo rm`, recursive
    `chmod 777`, recursive `chown`, `find -delete`, `find -exec rm`,
    and `python -c "shutil.rmtree(...)"`.
  - Destructive data, including `drop database|schema`,
    `truncate table`, `delete from`, `prisma migrate reset`, and
    Rails/Sequelize `db:drop`.
  - Production deploys, including `vercel --prod`, `netlify --prod`,
    `fly deploy`, `railway up`, `gcloud app deploy`, `firebase deploy`,
    `aws ... deploy`, `kubectl apply|delete|rollout`, and
    `helm install|upgrade|delete`.
  - Secret touches via `cat|sed|awk|grep|printf|echo|tee|cp|mv|chmod|chown`
    when the path contains `.env`, `.npmrc`, `.pypirc`, `.netrc`,
    `id_rsa`, `id_ed25519`, `secret`, or `secrets`.
  - Remote-script piping (`curl ... | sh`, `wget ... | sh`).
  - Source-control finalization (new in v0.4.3), including
    `git commit`, `git push` (including `--force`/`-f`), `git tag`,
    `git rebase`, `git filter-branch`/`filter-repo`,
    `git commit --amend`, and `git reset --hard`, unless
    `.clearpath/approvals/allow-git-finalize` exists. `git add` and
    read-only git commands (`status`, `diff`, `log`, `show`, a plain
    `git reset`) are not blocked, so the agent can still stage changes
    for the user to review without a sentinel.

- `pre-tool-use-design-approval-gate.sh` denies:
  - `Edit|Write|MultiEdit` and `Bash` writes (redirects, `tee`,
    `cp`/`mv`/`install` destinations, `python open(...)` and
    `node writeFileSync(...)` including the wrapped forms
    `require('fs').writeFileSync(...)`, `require("fs").writeFileSync(...)`,
    and bare `fs.writeFileSync(...)`) targeting production UI
    files under `components/`, `app/`, `pages/`, `src/`,
    `source/`, `mobile/`, `screens/`, `widgets/`, `lib/widgets/`,
    and similar strong-UI directories, when
    `.clearpath/approvals/design-approved` is absent.
  - Writes via `Edit|Write|MultiEdit` or `Bash` to approval files
    themselves (self-write of design-approved).

- `stop-ensure-state.sh` (renamed from `stop-update-state.sh` in
  v0.4.1) only ensures `docs/clearpath/STATE.md` exists. It does not
  auto-track session phase, active change, or any other state.

## What the hooks do NOT enforce

- They are not a sandbox. A Claude tool can still run arbitrary code
  that does not match the deny patterns.
- The dependency / destructive patterns are heuristic. They will not
  catch every bypass, especially ones that chain obscure wrappers or
  use unusual shells.
- Approval sentinel files must be created by the user outside Claude
  Code. The hooks deny any Claude tool that tries to do so, but they
  do not encrypt the sentinel directory or audit user actions.
- `policy.json` is **reference-only**. It is copied into projects
  during `clearpath-init` for documentation, but no hook reads it at
  runtime. Changing `policy.json` does not change hook behavior.

## `policy.json` is reference-only

`templates/project/docs/clearpath/policy.json` describes the project
policy as data: dependency install, production deploy, secret edit,
destructive data, and design gate are all
`manual_approval_required`. This file is documentation; the
enforcement lives in the hook scripts. Do not rely on editing
`policy.json` to change runtime behavior.

## Sandbox and permissions guidance (defense in depth)

The hooks are not sufficient on their own. Operators who need strict
governance should layer additional defenses:

1. **Deny writes to approval sentinels in Claude Code permissions.**
   Where the runtime supports a permissions file, deny `Write`,
   `Edit`, and `MultiEdit` to `.clearpath/approvals/**`, and add
   Bash `deny` patterns for `touch`, `echo >`, `dd of=`, and
   `install ... .clearpath/approvals/...`.

2. **Enable Claude Code sandboxing if available.** Sandboxing
   reduces the blast radius of any tool call that slips past the
   hook regex. Where the environment supports it, enable it for any
   session that uses Clearpath.

3. **Fail closed when sandboxing/permissions are unavailable.** If
   the local Claude Code version does not support sandboxing or
   permission rules, treat that as a known gap: agents can still run
   code; the hooks are the only thing that can deny a tool call. Do
   not claim the kernel or sandbox always blocks writes.

4. **Pin production data sources and credentials outside Claude
   Code.** The hooks deny secret touches, but secrets in the shell
   environment can still be read unless the runtime sandbox blocks
   it. Use a credential store the agent cannot read, not env vars.

5. **Review sentinel changes via the host shell, not the agent.**
   Approval sentinels are governance state; treat them as a
   machine-policy surface and manage them with your normal change
   process.

## Windows-MCP / CursorTouch (opt-in boundary)

Windows-MCP (or CursorTouch) is **not** part of the plugin's default
MCP layer. It is intentionally absent from `.mcp.json` so that no
project gets it enabled by default. It is only relevant for Windows
native / Electron / WebView2 desktop projects (`/clearpath:verify-windows`).

**What "opt-in" actually means today:** the Clearpath hooks do not
inspect MCP server configuration, so they cannot technically deny a
Windows-MCP tool call the way they deny `Bash`/`Edit`/`Write` calls.
The opt-in boundary is enforced by:

1. Windows-MCP is not in the plugin's `.mcp.json` — a project only
   gets it if the operator adds it to a project-level `.mcp.json`.
2. `templates/project/.mcp.windows-mcp.example.json` (see below) is
   the only sanctioned way to add it, and it is a file the operator
   copies in manually — `clearpath-init` does not do this
   automatically.
3. `/clearpath:verify-windows` instructs the agent to use only the
   safe interaction surface (`Screenshot`, `Snapshot`, `Click`, `Type`,
   `Scroll`, `Move`, `Shortcut`, `Wait`, `WaitFor`, `App`, `Clipboard`)
   and to treat `PowerShell`, `Registry`, `FileSystem`, and `Process`
   tools as denied unless the user has explicitly approved them for
   that specific test session.

**Known limitation:** step 3 is a skill-level instruction, not a hook
gate — there is currently no PreToolUse hook for MCP tool calls in
Claude Code's hook surface that this plugin can attach to. If your
Claude Code version or MCP client supports per-tool allow/deny lists,
apply them directly to the `PowerShell`, `Registry`, `FileSystem`, and
`Process` Windows-MCP tools as an additional layer; do not rely on the
skill instruction alone for a regulated environment.

## `templates/project/.claude/settings.json` (defense-in-depth template)

`templates/project/.claude/settings.json` is a recommended
defense-in-depth template. It is **not** auto-applied. The
operator or `clearpath-init` flow must copy it into the target
project for it to take effect.

What it does:

- Adds a Claude Code permissions layer that denies `Write`,
  `Edit`, and `MultiEdit` to `.clearpath/approvals/**` so the host
  runtime reinforces the hook's approval sentinel protection.

What it does NOT do:

- It does not replace the Clearpath hook gates. The hooks remain
  authoritative.
- It does not auto-apply. The file must be copied/applied by the
  operator or init workflow before it affects a project.

The JSON is intentionally schema-clean: no `_comment` or other
non-standard fields, so the runtime can validate it without
warnings. Operator-facing explanation lives here in the docs.

## Reporting limitations honestly

The hooks were hardened against a specific list of bypasses. The
gate is regex-based, not a parser. A determined user can still write
to `.clearpath/approvals/allow-destructive-shell` from a non-Claude
shell. The v0.4.1 release reduces the surface area, it does not
eliminate it. Operators must layer their own controls for high-trust
or regulated environments.
