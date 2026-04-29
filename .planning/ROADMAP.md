# Roadmap: Code-to-Docs Skill Hardening

## Milestones

- ✅ **v1.0 — Local-Only Security Foundation** (Phases 1–4, shipped **2026-04-29**) — [archived roadmap](.planning/milestones/v1.0-ROADMAP.md) · [archived requirements](.planning/milestones/v1.0-REQUIREMENTS.md)
- **v1.1 — CI & validation hardening** (Phases 5–7, **shipped 2026-04-29**) — requirements: [`.planning/REQUIREMENTS.md`](REQUIREMENTS.md)

## Current work

*v1.1 complete. Use `/gsd-new-milestone` for the next cycle.*

---

## Milestone v1.1 (active)

### Phase 5: PR CI workflow + Linux validation path

**Goal:** Add a GitHub Actions workflow that runs on pull requests and executes `./scripts/validate-security.sh` on a Linux runner with clear logs and least-privilege permissions.

**Requirements:** CI-01, CI-02, CI-03, CI-04  
**Depends on:** v1.0 validation scripts and policies (complete).  
**Status:** Complete (2026-04-29) — `.github/workflows/security-ci.yml`, phase `VERIFICATION.md`.

**Success criteria**

1. Opening or updating a PR triggers the workflow when targeting the agreed branch(es).
2. The job fails if `validate-security.sh` exits non-zero; passes otherwise on a clean tree.
3. Workflow `permissions` are documented and minimal for checkout + validation.
4. Logs distinguish validation failures from later phases (shellcheck added in Phase 6).

**Risks / notes:** macOS vs Linux differences must be resolved or explicitly documented for CI.

---

### Phase 6: shellcheck integration

**Goal:** Add shellcheck to CI with explicit scope, severity policy, and local reproduction steps.

**Requirements:** SHL-01, SHL-02, SHL-03  
**Depends on:** Phase 5 (stable validation job).  
**Status:** Complete (2026-04-29) — `scripts/run-shellcheck.sh`, workflow shellcheck steps, phase `VERIFICATION.md`.

**Success criteria**

1. shellcheck runs in CI on the documented scope; exclusions are justified and listed.
2. Failure policy (e.g. errors-only) is documented and enforced consistently.
3. Maintainers can run the same shellcheck command locally.

**Risks / notes:** Avoid repo-wide enablement without baseline; ratchet if needed.

---

### Phase 7: Documentation, verification, and milestone closure prep

**Goal:** Document CI vs local parity, update security/onboarding docs, and record verification per repo conventions.

**Requirements:** DOC-01, DOC-02, NFR-01, NFR-02, NFR-03  
**Depends on:** Phases 5–6.  
**Status:** Complete (2026-04-29) — `docs/security/ci-validation.md`, README, outbound allowlist, checklist, `PROJECT`/`MILESTONES`, Phase 7 `VERIFICATION.md`.

**Success criteria**

1. README and/or `docs/security/` describes triggers, commands, and policy alignment with v1.0 outbound rules.
2. Verification artifact(s) exist for v1.1 (phase `VERIFICATION.md` or equivalent).
3. No undisclosed outbound behavior introduced by CI; reproducibility notes captured if OS deltas exist.

---

## Coverage check

| Requirement | Phase |
|-------------|-------|
| CI-01–CI-04 | 5 |
| SHL-01–SHL-03 | 6 |
| DOC-01–DOC-02, NFR-01–NFR-03 | 7 |

All v1.1 requirements mapped.

## Backlog candidates (post–v1.1)

- Optional encrypted local artifact storage.
- Optional policy-as-code enforcement for hardening checks.
- Optional per-phase automated security scorecard.
- Optional full `security-regression.sh` on PRs or scheduled runs.
