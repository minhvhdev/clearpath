# Install Clearpath

## Install from GitHub marketplace

Add the marketplace:

```text
/plugin marketplace add minhvhdev/clearpath
```

Install Clearpath:

```text
/plugin install clearpath@clearpath-marketplace
```

Reload plugins:

```text
/reload-plugins
```

Start:

```text
/clearpath:go
```

## Local development install

```bash
claude --plugin-dir ./clearpath-plugin
```

Then use:

```text
/clearpath:doctor
/clearpath:init
```

## Updating the marketplace/plugin

```text
/plugin marketplace update clearpath-marketplace
/reload-plugins
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

For source-control finalization (`git commit`/`push`/`tag`/
`rebase`/`filter-branch`/`--amend`/`reset --hard`; `git add` and
read-only git commands do not need this):

```bash
touch .clearpath/approvals/allow-git-finalize
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
is **not enabled by default** — it is intentionally absent from the
plugin's own `.mcp.json`. See `/clearpath:verify-windows` for the
safety boundary and `docs/SECURITY_HARDENING.md` for the rationale.

To opt in, copy the `windows-mcp` entry from
`templates/project/.mcp.windows-mcp.example.json` into your
project's own `.mcp.json` (merge it under the existing
`mcpServers` key rather than overwriting the file):

```bash
cat templates/project/.mcp.windows-mcp.example.json
```

Then configure your MCP client to default-deny the `PowerShell`,
`Registry`, `FileSystem`, and `Process` tools for that server if your
client supports per-tool allow/deny lists — see
`docs/SECURITY_HARDENING.md` for why this is not enforced by a
Clearpath hook.
