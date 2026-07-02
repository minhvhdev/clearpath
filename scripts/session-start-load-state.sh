#!/usr/bin/env bash
set -u
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
BOOT="$PROJECT_DIR/.clearpath/docs/BOOT.md"
CURRENT="$PROJECT_DIR/.clearpath/docs/CURRENT_CONTEXT.md"
INDEX="$PROJECT_DIR/.clearpath/docs/ARTIFACT_INDEX.json"

if [[ -f "$BOOT" ]]; then
  echo "CLEARPATH_SESSION_START: Read .clearpath/docs/BOOT.md first. Do not read all Clearpath artifacts. Use ARTIFACT_INDEX.json and CURRENT_CONTEXT.md for progressive retrieval."
elif [[ -d "$PROJECT_DIR/.git" ]]; then
  echo "CLEARPATH_SESSION_START: Clearpath artifacts not initialized. Use /clearpath:init or run clearpath-init before relying on Clearpath state."
else
  echo "CLEARPATH_SESSION_START: Clearpath active. No git project detected; initialize project artifacts after choosing a project root."
fi

if [[ -f "$CURRENT" ]]; then
  echo "CLEARPATH_CURRENT_CONTEXT: .clearpath/docs/CURRENT_CONTEXT.md is available as the compact current view."
fi
if [[ -f "$INDEX" ]]; then
  echo "CLEARPATH_ARTIFACT_INDEX: .clearpath/docs/ARTIFACT_INDEX.json is available for artifact retrieval."
fi
exit 0
