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

## Milestone: v1.1 — CI & validation hardening

**Shipped:** 2026-04-29  
**Phases:** 5–7 (3) | **Plans:** 3

### What was built

- GitHub Actions `security-ci.yml`: PR → `main`, `validate-security.sh`, apt `shellcheck`, `run-shellcheck.sh`.
- Shared `scripts/run-shellcheck.sh` with scope parity to bash-syntax pass; `.gitignore` exception for tracking.
- `docs/security/ci-validation.md`, README security section, outbound allowlist CI subsection, validation checklist automation row.

### What worked

- Thin CI YAML + fat scripts matched v1.0 philosophy; separate workflow steps made failures attributable.
- Continuing phase numbers (5–7) after v1.0 avoided renumbering churn.

### What was inefficient / deferred

- `gsd-sdk query commit` sometimes omitted tracked paths (needed follow-up commit for docs/workflow files).
- Formal `v1.1` roadmap/requirements archive pointers in ROADMAP required manual collapse after `milestone.complete`.

### Patterns established

- Single job `security-validate` with ordered steps; concurrency cancel-in-progress on PRs.

### Key lessons

- Document CI egress (checkout + apt) in allowlist alongside scripted outbound rules.

---

## Cross-milestone trends

| Milestone | Phases | Focus |
|-----------|--------|--------|
| v1.0 | 4 | Local-only security foundation |
| v1.1 | 5–7 | CI + shellcheck + docs |

---

*Living document — append future milestones above Cross-milestone trends.*
