# Clearpath

Clearpath is a Claude Code product delivery plugin with a simple
workflow: **prototype → approve in chat → agent builds autonomously**.

It combines:

- **GSD Core-style context engineering**: phase loop, fresh-context work, state artifacts.
- **Superpowers-style development discipline**: spec-first, plan-first, TDD/review when available.
- **gstack-style role review**: product/CEO, design, engineering, QA, security, release.
- **Context Ledger**: artifact memory without reading everything at startup.

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

Or just describe what you want to build or change.

## Local development install

From the parent directory of this plugin:

```bash
claude --plugin-dir ./clearpath-plugin
```

Inside Claude Code, you can just say what you want. The
Autopilot detects the project mode and routes the request. You can
also use namespaced skills such as:

```text
/clearpath:go             (default autopilot entrypoint)
/clearpath:init
/clearpath:start
/clearpath:update
/clearpath:adopt
/clearpath:doctor
/clearpath:design-prototype
/clearpath:execute
/clearpath:verify
/clearpath:verify-web
/clearpath:verify-windows
/clearpath:autonomy
```

## Simplest usage

1. Install/enable the plugin.
2. Open Claude Code at your project root.
3. Tell Claude what you want to build or change.

Examples:

```text
Build me a SaaS landing page for ...
Add billing settings to this app.
Review this existing codebase and prepare it for Clearpath.
Fix the onboarding bug and verify it.
```

Lifecycle:

```text
detect -> prototype -> present -> user approves in chat ->
implement -> test -> fix -> verify -> done
```

For UI work, the agent will:

1. Build an **HTML + Tailwind CSS** prototype under `.clearpath/prototype/`
   and show you how to preview it.
2. Ask you to **Approve** or **Request changes**.
3. After you reply "approve" (or similar), continue building without
   routine questions.

`.clearpath/docs/AUTOPILOT.md` is a continuity artifact created by
workflow skills. See [docs/AUTOPILOT.md](docs/AUTOPILOT.md).

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

## Doctor and prerequisites

Run `/clearpath:doctor` to verify:

- User-scope skills: `design-taste-frontend`, `impeccable`
- MCP servers: chrome-devtools, serena, codebase-memory-mcp
- CLI: jq, git, node, npx, uvx, codebase-memory-mcp

If anything is missing, the agent will ask for permission, then run:

```bash
CLEARPATH_DOCTOR_INSTALL_APPROVED=1 clearpath-doctor-install
```

## Validation

```bash
./tests/plugin-structure-test.sh
./tests/hook-smoke-test.sh
./bin/clearpath-doctor
claude plugin validate . --strict
```

`claude plugin validate` requires the Claude Code CLI and must be run
in your local environment.
