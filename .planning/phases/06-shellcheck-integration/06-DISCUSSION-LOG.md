# Phase 6: shellcheck integration - Discussion Log

> **Audit trail only.** Decisions live in `06-CONTEXT.md`.

**Date:** 2026-04-29  
**Phase:** 6 — shellcheck integration  
**Mode:** `--chain` (consolidated decisions from REQUIREMENTS SHL-01–SHL-03, Phase 5 CI layout, `.planning/research/PITFALLS.md` / `SUMMARY.md`)

---

## Gray areas considered

| Area | Resolution |
|------|------------|
| Scope vs repo-wide | Same `find` roots as `validate-security.sh` (`scripts`, `skills/code-to-docs-hooks/hooks`). |
| Severity | `--severity=warning` (fail on warning+); info/style excluded. |
| CI placement | Extra steps in existing `security-validate` job after validate-security. |
| Local vs CI | Shared `scripts/run-shellcheck.sh`; CI installs shellcheck via apt. |

## Alternatives not chosen

- **Error-only (`--severity=error`)** — deferred ratchet if warning noise is acceptable first.
- **Separate workflow file** — unnecessary; same PR event.
- **pre-commit** — Phase 7 / optional follow-up.

## User interaction note

Interactive gray-area picklist was not blocking: Phase 6 options are fully constrained by SHL-* and prior research; defaults are recorded in `06-CONTEXT.md` for override before planning if needed.
