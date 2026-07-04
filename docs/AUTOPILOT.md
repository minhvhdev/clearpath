# Clearpath Autopilot

Clearpath Autopilot is the default UX layer. A user installs
Clearpath, opens Claude Code, and says what they want — no slash
commands required.

## What Autopilot does

- On `SessionStart`, detects the project mode and injects routing
  context. Read-only; does not write files.
- On `UserPromptSubmit`, classifies intent (including `approve` and
  `request changes`) and injects routing context.
- `/clearpath:go` is the manual entrypoint with the same behavior.
- `/clearpath:goal` is the explicit override when the user wants
  end-to-end execution without the normal design approval checkpoint.

In Cursor, ship the same core guidance as an always-applied project
rule as well, including the prompt-routing behavior normally handled by
`UserPromptSubmit`. Hook-delivered context in the IDE is best-effort,
so the rules are the reliable fallback.

## Simple workflow

```text
prototype -> present -> user approves in chat -> autonomous build
```

When the request involves UI:

1. `/clearpath:design-prototype` builds the prototype and reviews.
2. The agent presents it and asks: **Approve** or **Request changes**.
3. When the user approves in chat, `/clearpath:autonomy` takes over:
   implement, test, fix, verify — without routine questions.

## Detection modes

`scripts/clearpath-detect-mode.sh` returns one of:

- `existing-clearpath-project` — route `/clearpath:update`
- `adopt-existing-project` — route `/clearpath:adopt`
- `new-scaffolded-project` — route `/clearpath:init` then `/clearpath:start`
- `new-empty-project` — route `/clearpath:init` then `/clearpath:start`
- `unknown` — route `/clearpath:go` and clarify if needed

## Clarification policy

Ask only when:

- the product goal is ambiguous,
- credentials are missing,
- the request exceeds current scope.

## Platform-specific verification

- Web UI: `/clearpath:verify-web`
- Windows native: `/clearpath:verify-windows`
- Other: `/clearpath:qa`

## Output

`.clearpath/docs/AUTOPILOT.md` is updated by workflow skills for
session continuity. It is not a gate.
