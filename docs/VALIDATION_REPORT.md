# Clearpath v0.4.1 Validation Report

This report is regenerated per release. If a check was not run, it
must say `NOT RUN` and the reason. Do not infer a PASS for a check
that was skipped.

## Commands run

```bash
bash tests/plugin-structure-test.sh
bash tests/hook-smoke-test.sh
./bin/clearpath-doctor
claude plugin validate . --strict
```

## Result

- Plugin structure test: see Results below.
- Hook smoke test: see Results below.
- Doctor hard failures: see Results below.
- `claude plugin validate . --strict`: see Results below.

## Hook coverage tested

Safety gate denies (v0.4.1):

- malformed JSON
- approval sentinel `Write` to `.clearpath/approvals/design-approved`
- design approval doc edit
- `.env` edit
- `dd ... of=.clearpath/approvals/...`
- `install -m 644 /dev/null .clearpath/approvals/...`
- `: > .clearpath/approvals/...`
- `echo > .clearpath/approvals/...`
- `awk BEGIN{... > ".clearpath/approvals/..."}`
- `python3 -c "open('.clearpath/approvals/...','w')..."`
- `npm install`, `npm ci`, `uv sync`
- `yarn dlx`, `pnpm dlx`, `bunx`, `deno run -A`
- `make install`, `find -delete`, `python3 -c "shutil.rmtree(...)"`
- `/usr/bin/pip3 install`, `/usr/local/bin/npm install`
- `npx -y some-package`
- `curl https://... | sh`
- `rm -rf /tmp/...`
- `psql -c "truncate table users"`
- `vercel deploy --prod`

Safety gate allows:

- `npm test`
- non-secret source edit
- `npm ci` after manual `allow-dependency-install` sentinel
- `test -f .clearpath/approvals/design-approved`
- `[ -f .clearpath/approvals/design-approved ]`
- `ls .clearpath/approvals`
- `cat .clearpath/approvals/design-approved`

Design gate denies before manual design approval (v0.4.1):

- `Edit|Write|MultiEdit` and `Bash` to `pages/index.js`,
  `src/components/Button.js`, `app/layout.ts`, `src/app/page.tsx`,
  `styles/globals.css`
- `Bash` writes (cat redirect, tee, printf, echo, cp) to
  `components/Button.tsx`, `app/page.tsx`,
  `mobile/screens/HomeScreen.tsx`, `lib/widgets/home_widget.dart`,
  `source/App.vue`
- self-write of `.clearpath/approvals/design-approved`

Design gate allows:

- `prototype/index.html`
- `docs/examples/sample.css`
- `src/lib/api.ts`
- `prototype/App.vue` via Bash
- `docs/examples/note.md` via Bash
- production UI files (Edit, Write, Bash) after manual
  `.clearpath/approvals/design-approved` sentinel

## Results

This section is filled in by running the commands above. If a check
was not run, write `NOT RUN` and the reason.

- `bash tests/plugin-structure-test.sh`: PASS
- `bash tests/hook-smoke-test.sh`: PASS (56/56 cases, including 4
  new Node writeFileSync regression cases for the wrapped Node
  write variants: deny without approval, deny on `components/`,
  allow on `prototype/`, allow after design approval)
- `bash scripts/clearpath-doctor.sh`: PASS (0 failures, 1 warning:
  `codebase-memory-mcp` not on PATH)
- `claude plugin validate . --strict`: PASS

Run date: 2026-07-02. v0.4.1 pre-commit hardening run
(source-control autonomy boundary, schema-clean settings template,
Node writeFileSync regression coverage). Hooks/scripts/agents
frontmatter unchanged from the v0.4.1 P0 workflow hardening pass.

## Known environment warnings

- `codebase-memory-mcp` was not installed on PATH in the sandbox.
