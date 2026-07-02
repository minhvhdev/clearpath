# Sources and Methodology References

Clearpath is an original plugin/workflow, but it intentionally borrows method-level patterns from:

- GSD Core / GSD: context engineering, spec-driven development, phase loop, state survival.
- Superpowers: composable skills, spec-first discipline, TDD, planning, code review.
- gstack: role-based operator workflows for CEO/product, design, engineering, QA, release, security and browser testing.

Technical integration assumptions:

- Claude Code plugin manifest: `.claude-plugin/plugin.json`.
- Plugin components at root: `skills/`, `agents/`, `hooks/hooks.json`, `.mcp.json`, `bin/`, `scripts/`.
- PreToolUse hooks return structured `hookSpecificOutput.permissionDecision = deny` for blocking.
- Memory strategy follows index-first and on-demand retrieval rather than loading all artifacts.
