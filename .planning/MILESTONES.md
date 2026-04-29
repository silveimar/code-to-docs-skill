# Milestones

## v1.1 CI & validation hardening (Shipped: 2026-04-29)

**Archive:** [ROADMAP snapshot](.planning/milestones/v1.1-ROADMAP.md) · [REQUIREMENTS snapshot](.planning/milestones/v1.1-REQUIREMENTS.md)

**Phases completed:** 5–7 (3 phases, 3 plans)

**Summary:** GitHub Actions on PRs to `main` (`security-ci.yml`), `scripts/run-shellcheck.sh`, `docs/security/ci-validation.md`, README and outbound-allowlist updates; phase `VERIFICATION.md` files under `.planning/phases/` for Phases 5–7.

---

## v1.0 Local-Only Security Foundation (Shipped: 2026-04-29)

**Archive:** [ROADMAP snapshot](.planning/milestones/v1.0-ROADMAP.md) · [REQUIREMENTS snapshot](.planning/milestones/v1.0-REQUIREMENTS.md)

**Phases completed:** 4 phases, 4 plans, 7 tasks

**Key accomplishments:**

- Outbound allowlist plus gated `bump.sh` lanes, vault-safe hook JSON generation, pre-commit blocking for sensitive paths, and minimal hook stdout hygiene — with reproducible checks in `VERIFICATION.md`.
- `docs/security/sensitive-content-handling.md`, `docs/security/artifact-retention.md`, `scripts/redact_public_text.py`, integration in `digest-on-start.sh`, SKILL cross-link, `VERIFICATION.md`.
- Aggregate local validation script, ephemeral-repo regression for `pre-commit-guard.sh`, markdown checklist, README subsection, PROJECT success-criteria line, `VERIFICATION.md`.
- Repository-wide local-only security baseline documented with traceable data flows, STRIDE threats, prioritized risks, and gate evidence.

---
