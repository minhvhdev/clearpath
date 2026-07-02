# Security Hardening (deprecated)

As of the simplified workflow release, Clearpath no longer uses
`PreToolUse` safety or design approval hook gates, and no longer
requires `.clearpath/approvals/` sentinel files.

Design approval happens in chat: the agent presents the prototype,
the user replies **Approve** or **Request changes**, and the agent
continues autonomously after approval.

If you need hard enforcement for secrets, deploys, or dependency
installs, configure Claude Code permissions in your project
`.claude/settings.json` directly.
