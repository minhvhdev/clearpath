# Clearpath Product Direction

## Table of Contents

1. Product definition
2. Source methodology references
3. Required dependency/MCP layer
4. Unified Delivery Loop
5. Workflow A — new product from scratch
6. Workflow B — continue a project already using Clearpath
7. Workflow C — adopt an existing product that never used Clearpath
8. Skills and agents
9. Hook enforcement and approval sentinels
10. Context Ledger artifact architecture
11. Validation requirements

## 1. Product definition

Clearpath is a unified AI product delivery workflow for Claude Code. It combines GSD-style phase/context engineering, Superpowers-style spec/TDD/subagent discipline, gstack-style role review, and Clearpath-specific approval gates for design, safety, data, dependency, and release boundaries.

Clearpath is not an app framework, UI kit, deploy tool, or code indexer. It is a workflow/governance layer for Claude Code.

## 2. Source methodology references

Clearpath references, but does not require installing, three methodology repositories:

- GSD Core: phase loop, context engineering, spec-driven development, fresh-context work, state survival.
- Superpowers: composable skills, spec-first discipline, planning, TDD, subagent-driven execution, code review.
- gstack: role-based workflows for CEO/product, designer, engineering manager, release manager, documentation, QA, browser testing, security, guard/freeze/careful modes.

Clearpath's differentiation: those systems improve how an agent works; Clearpath controls when the agent is allowed to cross product/design/safety/release boundaries.

## 3. Required dependency/MCP layer

Core plugin prerequisites:

- Claude Code
- Bash-compatible shell
- jq
- Git recommended

Required MCP layer for full workflows:

- Serena for symbol/reference navigation.
- Chrome DevTools MCP for browser QA/runtime evidence.
- Codebase-Memory MCP for large-repo indexing and knowledge graph retrieval.

Fallback policy:

- Chrome DevTools missing: UI work may continue, but browser QA cannot be marked passed.
- Serena missing: small repos may fall back to grep/read; large repo adoption should warn or stop.
- Codebase-Memory missing: new/small repos may continue; large/legacy/monorepo adoption should stop or run limited mode.
- jq missing: hard stop because hooks cannot safely parse JSON.

## 4. Unified Delivery Loop

Clearpath loop:

```text
Initialize / Recover
→ Discuss
→ Spec
→ Design or Architecture Review
→ Plan
→ Approval Gate
→ Execute
→ Verify
→ Role Review
→ Release Candidate
→ Release Gate
→ Archive / Learn
```

## 5. Workflow A — new product from scratch

1. Initialize Clearpath artifacts.
2. Discuss product intent, users, outcomes, constraints, and non-goals.
3. Create product summary, spec, acceptance criteria, and MVP scope.
4. Prototype UI locally when UI exists.
5. Run design critique and get manual design approval.
6. Plan implementation tasks.
7. Execute in small tasks; use TDD when tests exist.
8. Verify with tests/build and Chrome QA.
9. Run role review.
10. Produce release candidate and stop at Release Gate.
11. Archive decisions and current context.

## 6. Workflow B — continue a project already using Clearpath

1. Read BOOT.md and CURRENT_CONTEXT.md.
2. Use ARTIFACT_INDEX.json and active CHANGE_INDEX.md.
3. Parse the new request and locate only relevant artifacts/modules.
4. Use Serena/Codebase-Memory for targeted code evidence.
5. Continue the loop from Discuss/Spec or directly from the current phase.
6. Update compact summaries and indexes after each phase.

## 7. Workflow C — adopt an existing product that never used Clearpath

1. Do not read the whole repo.
2. Inventory repo structure, package scripts, CI, README, existing agent manifests, deploy config.
3. Use Codebase-Memory indexing and Serena navigation.
4. Create PROJECT_INDEX.json and only relevant module cards.
5. Create adoption change pack.
6. Adopt enough to safely execute the current change, not enough to document the whole company.
7. Continue through Spec, Plan, Execute, Verify, Review, Release Candidate.

## 8. Skills and agents

Skills are phase commands under `/clearpath:<skill>`: init, start, update, adopt, discuss, spec, design-prototype, architecture, plan, execute, verify, review, qa, release-candidate, release-gate, archive, doctor, artifact-index.

Agents: product-strategist, codebase-architect, ux-designer, design-critic, implementation-planner, implementation-engineer, qa-release-engineer, security-reviewer, context-ledger-manager.

## 9. Hook enforcement and approval sentinels

MVP enforcement uses two hook mechanisms:

- Safety Gate: umbrella enforcement for secret edits, dependency installs, destructive shell/data operations, production/infrastructure deploys, and approval sentinel self-edits.
- Design Approval Gate: production UI file edits require manual design approval.

Approval sentinels are files under `.clearpath/approvals/` created manually by the user outside Claude Code. Claude tools are blocked from creating or editing them.

## 10. Context Ledger artifact architecture

Clearpath intentionally produces many artifacts. The solution is not to reduce workflow depth, but to prevent artifact over-reading.

Context Ledger tiers:

- Tier 0: BOOT.md — startup index.
- Tier 1: CURRENT_CONTEXT.md and STATE.md — compact current view.
- Tier 2: Active change pack with CHANGE_INDEX.md.
- Tier 3: Module memory cards.
- Tier 4: historical archive/evidence.

Retrieval protocol:

1. Read BOOT.md.
2. Read CURRENT_CONTEXT.md.
3. Read ARTIFACT_INDEX.json.
4. Read active CHANGE_INDEX.md.
5. Read phase-required canonical files only.
6. Read evidence/archive only on demand.

Never read all Clearpath artifacts at startup.

## 11. Validation requirements

A valid Clearpath plugin must pass:

```bash
./tests/plugin-structure-test.sh
./tests/hook-smoke-test.sh
./bin/clearpath-doctor
claude plugin validate . --strict
```

The last command requires Claude Code CLI in the local environment.
