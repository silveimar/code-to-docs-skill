# Phase 4 — Research notes

**Date:** 2026-04-29

## Findings

1. **No root test runner** — validation must be **bash + python** drivers, not pytest/jest (see `TESTING.md`).
2. **Pre-commit guard** is path-driven; regression = **staged file in temp git dir** + assert exit 1.
3. **No `.github/workflows`** — document optional CI in checklist only.
4. **README** is the right discovery surface for maintainers (vision: local operator).

## Handoff

Implement `04-01-PLAN.md` tasks: `validate-security.sh`, `security-regression.sh`, `validation-checklist.md`, README + PROJECT pointers, `VERIFICATION.md`.
