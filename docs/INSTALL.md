# Install Clearpath

## Local test

```bash
claude --plugin-dir ./clearpath-plugin
```

Then use:

```text
/clearpath:doctor
/clearpath:init
```

## Project initialization

From the project root:

```bash
clearpath-init
```

or invoke `/clearpath:init` inside Claude Code.

## Manual approval examples

After approving a UI prototype/design contract:

```bash
mkdir -p .clearpath/approvals
touch .clearpath/approvals/design-approved
```

For dependency install approval:

```bash
touch .clearpath/approvals/allow-dependency-install
```

For production release approval:

```bash
touch .clearpath/approvals/allow-production-release
```

For destructive shell operations:

```bash
touch .clearpath/approvals/allow-destructive-shell
```

Remove sentinels when no longer needed.

> The Clearpath hooks enforce these boundaries, but they are
> guardrails, not a security sandbox. For defense in depth (deny
> writes to approval sentinels in Claude Code permissions, enable
> sandboxing where supported, fail closed if not) see
> [docs/SECURITY_HARDENING.md](SECURITY_HARDENING.md).

## Optional: defense-in-depth permissions template

`templates/project/.claude/settings.json` is a recommended
defense-in-depth template. The operator (or `clearpath-init`)
must copy it into the target project for it to take effect. The
file itself is intentionally schema-clean (no `_comment` field);
operator-facing explanation lives in
[docs/SECURITY_HARDENING.md](SECURITY_HARDENING.md).

## Optional MCP: Windows-MCP / CursorTouch

If the project is a Windows native or Electron/WebView2 app, the
operator can opt in to Windows-MCP for user-like UI testing. This
is **not enabled by default**. See
`/clearpath:verify-windows` for the safety boundary and
`docs/SECURITY_HARDENING.md` for the rationale.
