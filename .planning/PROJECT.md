# Project: Code-to-Docs Skill Hardening (Local-Only)

## Current Milestone: v1.1 CI & validation hardening

**Goal:** Automate existing security validation on pull requests and tighten shell-script quality so regressions are caught before merge.

**Target features:**

- GitHub Actions workflow that runs `./scripts/validate-security.sh` (and aligned checks) on pull requests.
- shellcheck and/or stricter shell lint integrated into the validation story, with documentation.
- CI and local checks remain consistent with the local-first security posture; document behavior under `docs/security` / README.

## Current state (after v1.0)

- **Shipped:** Milestone **v1.0 — Local-Only Security Foundation** (2026-04-29). See `.planning/MILESTONES.md` and `.planning/milestones/v1.0-ROADMAP.md`.
- **Controls in repo:** Outbound allowlist and gated `bump.sh`, vault-safe hook install, pre-commit path guard, redaction helper + SessionStart integration, `validate-security.sh` + `security-regression.sh`, and `docs/security/*` policy set.
- **Onboarding doc:** `.planning/reports/MILESTONE_SUMMARY-v1.0.md`.

## Vision

Improve and secure this skill project so it can run locally with strong protections for analyzed source code and generated content, minimizing data exposure risks while preserving developer productivity.

## Problem (original)

The project had codebase mapping artifacts but security and privacy expectations for local usage were not fully encoded. **v1.0** established requirements, a phased roadmap, guardrails, and repeatable validation.

## Core value

**Local-first by default** — explicit policy, fail-closed tooling, and auditable phase outputs — without blocking day-to-day skill development.

## Goals (ongoing)

- Enforce local-only workflows by default.
- Protect analyzed code/content at rest and in transit.
- Reduce accidental exfiltration through tooling, logs, and integrations.
- Maintain practical usability for day-to-day development.
- Keep all assistant-facing communication in English.

## Non-goals

- Building a cloud-hosted multi-tenant SaaS.
- Supporting remote telemetry collection by default.
- Adding broad feature scope unrelated to security, privacy, or reliability.

## Users

- **Primary:** local developer/operator maintaining this repository.
- **Secondary:** trusted collaborators on the same machine/network boundary.

## Requirements (validated in v1.0)

Milestone v1.0 implemented and verified the full set from the archived [v1.0 requirements](.planning/milestones/v1.0-REQUIREMENTS.md):

- ✓ **FR-1** — Local execution guardrails and documented outbound surface.
- ✓ **FR-2** — Sensitive content classification, redaction guidance, pre-commit + guardrails.
- ✓ **FR-3** — Baseline checklist and repeatable review (`validate-security.sh`, checklist).
- ✓ **FR-4** — Verification artifacts, planning sync, traceability (Phase 1 ID chain + per-phase VERIFICATION).
- ✓ **FR-5** — English for planning and assistant-facing artifacts.
- ✓ **NFR-1** — No default telemetry; local boundaries documented.
- ✓ **NFR-2** — Reproducible script-based checks.
- ✓ **NFR-3** — Controls documented under `docs/security/` and README.

## Success criteria (v1.0 — met)

- Documented executable roadmap with security-first phases.
- Local-only constraints in requirements and operational rules.
- Data handling policies for source, docs, logs, caches, exports.
- Baseline verification integrated: `./scripts/validate-security.sh`, `./scripts/security-regression.sh`, `docs/security/validation-checklist.md`.

## Constraints

- Operate primarily in local environment.
- Preserve existing skill behavior unless a hardening change is intentional.
- Prefer reversible and auditable changes.
- Communication language for assistant outputs: English.

## Inputs

- User brief: improve and secure the skill for local use.
- Codebase map: `.planning/codebase/`.

## Risks

- Controls that are too strict may reduce usability.
- Hidden egress paths across tools/plugins.
- Local machine compromise remains largely out of scope for this repo.
- CI must not introduce unintended outbound calls or secrets exposure beyond what v1.0 already allows.

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):

1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):

1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---

*Last updated: 2026-04-29 — milestone v1.1 started*
