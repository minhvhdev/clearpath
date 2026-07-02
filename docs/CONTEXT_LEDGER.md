# Clearpath Context Ledger

Artifacts are source-of-truth memory, not startup context.

## Required files

- `BOOT.md`: startup pointer file, <= 200 lines.
- `CURRENT_CONTEXT.md`: compact materialized view, <= 300 lines.
- `ARTIFACT_INDEX.json`: machine-readable retrieval index.
- `CHANGE_INDEX.md`: per-change retrieval map.

## Read protocol

Before reading any detailed artifact, state why it is needed, check the index, read the smallest relevant file, and stop when the phase has enough context.

## Artifact lifecycle

- draft
- canonical
- superseded
- archived

Only active canonical artifacts are read by default.
