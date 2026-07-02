#!/usr/bin/env python3
import json, os, re, sys, datetime
from pathlib import Path

project = Path(sys.argv[1] if len(sys.argv) > 1 else os.environ.get('CLAUDE_PROJECT_DIR', os.getcwd())).resolve()
cp = project / 'docs' / 'clearpath'
changes = project / 'docs' / 'changes'
cp.mkdir(parents=True, exist_ok=True)
changes.mkdir(parents=True, exist_ok=True)

def read(path, default=''):
    try:
        return Path(path).read_text(encoding='utf-8')
    except FileNotFoundError:
        return default

state_text = read(cp / 'STATE.md')
active_change = None
phase = None
for line in state_text.splitlines():
    m = re.match(r'\s*active_change_id\s*:\s*([\w.\-/]+)', line, re.I)
    if m: active_change = m.group(1).strip()
    m = re.match(r'\s*current_phase\s*:\s*([\w.\-/]+)', line, re.I)
    if m: phase = m.group(1).strip()
if not active_change:
    m = re.search(r'##\s+Active Change\s*\n([^\n]+)', state_text, re.I)
    if m:
        val = m.group(1).strip().strip('-').strip()
        if val and val.lower() not in {'none','unknown','n/a'}:
            active_change = val
if not phase:
    m = re.search(r'##\s+Current Phase\s*\n([^\n]+)', state_text, re.I)
    if m: phase = m.group(1).strip().strip('-').strip()
phase = phase or 'unknown'
active_change = active_change or 'none'

artifact_files = []
for base in [cp, changes]:
    if base.exists():
        for p in base.rglob('*'):
            if p.is_file() and p.name != 'ARTIFACT_INDEX.json':
                rel = str(p.relative_to(project))
                try:
                    size = p.stat().st_size
                except OSError:
                    size = 0
                artifact_files.append({'path': rel, 'size_bytes': size})

active_dir = changes / active_change if active_change != 'none' else None
active_index = str((active_dir / 'CHANGE_INDEX.md').relative_to(project)) if active_dir and (active_dir / 'CHANGE_INDEX.md').exists() else None

idx = {
    'schema_version': 'clearpath.artifact_index.v1',
    'generated_at': datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0).isoformat().replace('+00:00', 'Z'),
    'active_change_id': active_change,
    'current_phase': phase,
    'boot_files': [
        'docs/clearpath/BOOT.md',
        'docs/clearpath/CURRENT_CONTEXT.md'
    ],
    'current_state': [
        'docs/clearpath/STATE.md',
        'docs/clearpath/PRODUCT.md',
        'docs/clearpath/DECISIONS.md',
        'docs/clearpath/PROJECT_INDEX.json'
    ],
    'active_change': {
        'index': active_index,
        'phase_required': {
            'initialize': ['docs/clearpath/BOOT.md', 'docs/clearpath/CURRENT_CONTEXT.md'],
            'discuss': ['CHANGE.md'],
            'spec': ['CHANGE.md', 'SPEC.md'],
            'design': ['SPEC.md', 'UI_CONTRACT.md'],
            'architecture': ['SPEC.md', 'IMPACT_ANALYSIS.md'],
            'plan': ['PLAN.md'],
            'execute': ['PLAN.md', 'context-packs/<task-id>.md'],
            'verify': ['QA.md'],
            'review': ['REVIEW.md', 'QA.md'],
            'release': ['RELEASE_CANDIDATE.md', 'QA.md']
        }
    },
    'read_policy': [
        'Read BOOT.md first.',
        'Read CURRENT_CONTEXT.md second.',
        'Use this index and the active CHANGE_INDEX.md before reading details.',
        'Never read docs/changes/** or docs/clearpath/** wholesale.',
        'Evidence and archive files are on-demand only.'
    ],
    'artifacts': sorted(artifact_files, key=lambda x: x['path'])
}
(cp / 'ARTIFACT_INDEX.json').write_text(json.dumps(idx, indent=2) + '\n', encoding='utf-8')

boot = cp / 'BOOT.md'
if boot.exists():
    text = boot.read_text(encoding='utf-8')
    text = re.sub(r'(?s)<!-- CLEARPATH_INDEX_START -->.*?<!-- CLEARPATH_INDEX_END -->',
                  f'<!-- CLEARPATH_INDEX_START -->\n## Generated Current Pointers\n- Current phase: {phase}\n- Active change: {active_change}\n- Artifact index: docs/clearpath/ARTIFACT_INDEX.json\n- Current context: docs/clearpath/CURRENT_CONTEXT.md\n<!-- CLEARPATH_INDEX_END -->', text)
    boot.write_text(text, encoding='utf-8')
print(json.dumps({'ok': True, 'artifact_index': str(cp / 'ARTIFACT_INDEX.json'), 'active_change_id': active_change, 'current_phase': phase}))
