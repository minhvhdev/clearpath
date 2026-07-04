# Install Clearpath

Clearpath works on both **Claude Code** and **Cursor**.

## Claude Code

### Install from GitHub marketplace

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

### Local development install

```bash
claude --plugin-dir ./clearpath-plugin
```

Then use:

```text
/clearpath:doctor
/clearpath:init
```

### Updating the marketplace/plugin

```text
/plugin marketplace update clearpath-marketplace
/reload-plugins
```

## Cursor

### Install from marketplace

In Cursor Settings > Plugins, add the marketplace `minhvhdev/clearpath`
and install Clearpath. Restart Cursor after installation.

### Local development install

Clone this repo and add it as a local plugin in Cursor Settings > Plugins.
Restart Cursor after adding the plugin.

### Usage in Cursor

All Clearpath skills and agents are available the same way as in
Claude Code. In Cursor, keep a project rule under
`.cursor/rules/clearpath.mdc` plus
`.cursor/rules/clearpath-autopilot.mdc` as the persistent fallback
because hook delivery is best-effort in the IDE. Session hooks can
still add context when they fire, but the always-applied rules are the
primary always-on layer. Use the same namespaced skills
(`/clearpath:go`, `/clearpath:doctor`, etc.).

## Project initialization

From the project root:

```bash
clearpath-init
```

or invoke `/clearpath:init` inside Claude Code.

## Doctor and auto-install (user scope)

Run `/clearpath:doctor`. When output includes
`CLEARPATH_DOCTOR_NEEDS_USER_APPROVAL: true`, the agent must ask you
before installing. After you approve:

```bash
CLEARPATH_DOCTOR_INSTALL_APPROVED=1 clearpath-doctor-install
```

This copies missing skills into `~/.claude/skills/` (from local
cache when available), merges MCP config into `~/.claude/settings.json`,
and attempts CLI installs (uv, codebase-memory-mcp).

Required user-scope skills for design work:

- `design-taste-frontend`
- `impeccable`

## Design approval (in chat)

For UI work, the agent presents the prototype and asks you to:

- **Approve** — continue to production implementation
- **Request changes** — describe what to revise

Reply in chat with e.g. `approve`, `looks good`, or `LGTM`.

## Optional MCP: Windows-MCP / CursorTouch

If the project is a Windows native or Electron/WebView2 app, the
operator can opt in to Windows-MCP for user-like UI testing. This
is **not enabled by default**. See `/clearpath:verify-windows`.

To opt in, copy the `windows-mcp` entry from
`templates/project/.mcp.windows-mcp.example.json` into your
project's own `.mcp.json`.
