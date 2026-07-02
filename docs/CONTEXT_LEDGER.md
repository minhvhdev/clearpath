# Clearpath Context Ledger

Artifacts are source-of-truth memory, not startup context.

## Required files

All paths are relative to the project root.

- `.clearpath/docs/BOOT.md`: startup pointer file, <= 200 lines.
- `.clearpath/docs/CURRENT_CONTEXT.md`: compact materialized view, <= 300 lines.
- `.clearpath/docs/ARTIFACT_INDEX.json`: machine-readable retrieval index.
- `.clearpath/docs/changes/<id>/CHANGE_INDEX.md`: per-change retrieval map.
- `.clearpath/prototype/`: HTML + Tailwind CSS UI previews.

## Read protocol

Before reading any detailed artifact, state why it is needed, check the index, read the smallest relevant file, and stop when the phase has enough context.

## Artifact lifecycle

- draft
- canonical
- superseded
- archived

Only active canonical artifacts are read by default.
