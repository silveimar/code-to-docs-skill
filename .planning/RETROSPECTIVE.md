# Retrospective

## Milestone: v1.0 — Local-Only Security Foundation

**Shipped:** 2026-04-29  
**Phases:** 4 | **Plans:** 4

### What was built

- Threat/data-flow baseline with STRIDE, risk register, and DF→TH→R traceability.
- Outbound allowlist, gated `bump.sh` lanes, vault-validated hook JSON, pre-commit guard, stdout hygiene.
- Sensitive-content + retention policies, `redact_public_text.py`, digest hook integration.
- Aggregate `validate-security.sh`, ephemeral-repo `security-regression.sh`, validation checklist, README/PROJECT pointers.

### What worked

- Bash + stdlib Python aligned with repo reality (no spurious test framework).
- Per-phase `VERIFICATION.md` gave repeatable commands and PASS audit trails.
- Phased CONTEXT → PLAN → execute kept scope bounded.

### What was inefficient / deferred

- Phase numbering mixed `1` vs `02–04` directories — tooling sometimes reports odd `roadmap.analyze` vs disk; manageable.
- No hosted CI — intentional; validation stays local-first.
- Phase 4 UAT file optional — scripts cover regression instead.

### Patterns established

- Fail-closed policy UX; two-lane publishing; allowlist documentation.
- Gitignore exceptions for tracked maintainer scripts under `scripts/`.

### Key lessons

- **`CODE_TO_DOCS_VAULT`** (not ad-hoc env names) must match `setup.sh` for vault tests.
- Milestone summary + complete-milestone archive keeps `.planning/` scalable.

---

## Cross-milestone trends

| Milestone | Phases | Focus |
|-----------|--------|--------|
| v1.0 | 4 | Local-only security foundation |

---

*Living document — append future milestones above Cross-milestone trends.*
