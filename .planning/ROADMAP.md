# ROADMAP

## Milestone 1: Local-Only Security Foundation

### Phase 1: Threat Model and Data Flow Baseline
**Goal:** Identify and document how sensitive code/content moves through the project.
**Requirements:** [FR-1, FR-2, FR-3, FR-4, FR-5, NFR-1, NFR-2, NFR-3]
**Status:** Completed (2026-04-29)
**Evidence:** `.planning/phases/1/VERIFICATION.md` (PASS), `.planning/phases/1/1-1-SUMMARY.md`

**Deliverables**
- Initial threat model focused on local-only operation.
- Data flow inventory for source inputs, generated docs, logs, caches, and exports.
- Prioritized risk register mapped to mitigations.

**Verification**
- Threat scenarios are documented and reviewed.
- All major data flows have explicit trust boundaries.
- High-severity risks have owner and mitigation path.

### Phase 2: Local-Only Guardrails Implementation
**Goal:** Enforce local-first defaults and block accidental data egress.
**Requirements:** [FR-1, FR-2, FR-4, NFR-1, NFR-2, NFR-3]
**Status:** Completed (2026-04-29)
**Evidence:** `.planning/phases/02-local-only-guardrails-implementation/VERIFICATION.md` (PASS), `02-01-SUMMARY.md`

**Deliverables**
- Config and workflow controls that default to local-only behavior.
- Documented outbound-network policy and opt-in exceptions.
- Ignore/protection rules for sensitive artifacts.

**Verification**
- Default workflows run without external calls.
- Attempted disallowed paths fail with clear errors.
- Sensitive artifact files are prevented from accidental commit.

### Phase 3: Secure Content Handling and Redaction
**Goal:** Reduce leakage risk from logs, traces, and generated artifacts.
**Status:** Completed (2026-04-29)
**Evidence:** `.planning/phases/03-secure-content-handling-and-redaction/VERIFICATION.md` (PASS), `03-01-SUMMARY.md`, `03-UAT.md` (complete)

**Deliverables**
- Sensitive content handling policy.
- Redaction guidance/patterns for operational output.
- Artifact retention guidance for local storage.

**Verification**
- Sample runs confirm sensitive tokens/content are redacted in logs.
- Generated artifacts follow documented storage/retention boundaries.

### Phase 4: Hardening Validation and Regression Checks
**Goal:** Ensure security controls remain effective over time.
**Status:** Implementation complete (2026-04-29); UAT optional
**Evidence:** `.planning/phases/04-hardening-validation-and-regression-checks/VERIFICATION.md` (PASS), `04-01-SUMMARY.md`

**Deliverables**
- Repeatable local security validation checklist.
- Regression checks integrated into normal development workflow.
- Updated planning docs reflecting implemented controls.

**Verification**
- Validation checklist passes on clean local environment.
- Regression checks catch intentionally introduced policy violations.

## Backlog Candidates
- Optional encrypted local artifact storage.
- Optional policy-as-code enforcement for hardening checks.
- Optional per-phase automated security scorecard.
