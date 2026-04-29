---
phase: 02-local-only-guardrails-implementation
plan: "02-01"
subsystem: security
tags: [bash, git-hooks, outbound-policy, json, pre-commit]

requires:
  - phase: "01"
    provides: Phase 1 threat baseline / verification PASS
provides:
  - Outbound allowlist doc + gated bump.sh local vs publish lanes
  - Vault-validated hook installer with Python JSON serialization
  - Pre-commit guard + SKILL install guidance
  - Minimal hook stdout hygiene + rolling VERIFICATION evidence

affects:
  - Phase 3 redaction / broader hygiene

tech-stack:
  added: []
  patterns:
    - "Documented CODE_TO_DOCS_PUBLISH=1 / --publish second gate for publish lane"
    - "Hook commands built as structured data + JSON serialize (stdlib json)"

key-files:
  created:
    - docs/security/outbound-allowlist.md
    - scripts/pre-commit-guard.sh
    - scripts/pre-commit
  modified:
    - scripts/bump.sh
    - skills/code-to-docs-hooks/hooks/setup.sh
    - skills/code-to-docs-hooks/hooks/teardown.sh
    - skills/code-to-docs-hooks/hooks/digest-on-start.sh
    - skills/code-to-docs-hooks/SKILL.md
    - .gitignore
    - .planning/phases/02-local-only-guardrails-implementation/VERIFICATION.md

key-decisions:
  - "Publish lane gates: CODE_TO_DOCS_PUBLISH=1 or --publish plus interactive y"
  - ".gitignore uses docs/** + scripts/** exceptions for shipped policy and maintainer scripts"

patterns-established:
  - "Fail-closed publish lane: push/gh errors not masked"
  - "Pre-commit enumerates cached paths and exits 1 on sensitive prefixes"

requirements-completed: [FR-1, FR-2, FR-4, NFR-1, NFR-2, NFR-3]

duration: 45min
completed: 2026-04-29
---

# Phase 2 Plan 02-01: Local-only guardrails Summary

**Outbound allowlist plus gated `bump.sh` lanes, vault-safe hook JSON generation, pre-commit blocking for sensitive paths, and minimal hook stdout hygiene — with reproducible checks in `VERIFICATION.md`.**

## Performance

- **Tasks:** 4
- **Commits:** `ebe527e`, `273fc01`, `9844151`, `00d788e`; summary/metadata commit follows on branch tip.
- **Self-check:** Files below exist; commits reachable from `main`.

## Accomplishments

- **Task 1:** `docs/security/outbound-allowlist.md`; `scripts/bump.sh` default local lane (no push/gh); publish lane requires `CODE_TO_DOCS_PUBLISH=1` or `--publish`; removed silent push masking; `gh` auth enforced fail-closed for publish.
- **Task 2:** `setup.sh` resolves repo root, validates vault paths (D-05), warns out-of-repo vault (D-04), emits hooks JSON via `json.dump` of structured fields + `shlex.quote`; `teardown.sh` runs from git toplevel.
- **Task 3:** `scripts/pre-commit-guard.sh` + `scripts/pre-commit` wrapper; `SKILL.md` install paths and `.gitignore` vs tracked `scripts/` note; `.gitignore` exceptions for `docs/security/**` and tracked scripts.
- **Task 4:** `digest-on-start.sh` uses basename-style vault display for the missing-vault line; `update-hint-on-commit.sh` unchanged (already path-free); `VERIFICATION.md` updated with commands and PASS rows.

## Task commits

1. **Task 1** — `ebe527e` — `feat(2-01): outbound allowlist and bump local/publish lanes`
2. **Task 2** — `273fc01` — `feat(2-01): validate vault path and build hook JSON with Python`
3. **Task 3** — `9844151` — `feat(2-01): pre-commit guard for sensitive paths and SKILL docs`
4. **Task 4** — `00d788e` — `feat(2-01): hook stdout hygiene and Phase 2 VERIFICATION`

## Deviations from Plan

None — plan executed as specified. Implementation uses `json.dump` after building a dict (equivalent to composing with `json.dumps` then writing).

## Known stubs

None for this phase scope.

## Threat flags

None beyond planned `<threat_model>` surfaces.

## Self-check: PASSED

- [x] `docs/security/outbound-allowlist.md` exists
- [x] Task commits `ebe527e` `273fc01` `9844151` `00d788e` and summary commit at `HEAD` verified on `main`

---
*Phase: 02-local-only-guardrails-implementation · Completed: 2026-04-29*
