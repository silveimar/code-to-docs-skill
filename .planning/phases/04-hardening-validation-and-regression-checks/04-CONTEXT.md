# Phase 4: Hardening Validation and Regression Checks - Context

**Gathered:** 2026-04-29  
**Status:** Ready for planning

<domain>
## Phase Boundary

Deliver **repeatable local validation** and **targeted regression probes** so Phase 2–3 controls (outbound policy, hooks, pre-commit, redaction) **stay effective as the repo evolves** — without introducing hosted CI as a hard dependency.

In scope: executable driver script(s), human checklist, regression script with deterministic pass/fail, maintainer-facing README pointer, planning artifact updates.

Out of scope: GitHub Actions YAML (no `.github/` today), enterprise scorecards, encrypted storage (backlog).

</domain>

<decisions>
## Implementation Decisions

### Validation packaging

- **D-01:** Provide **`scripts/validate-security.sh`** as the canonical entry point (non-zero exit on any failed check). It aggregates **syntax checks**, **policy file presence**, **redact smoke**, **vault validation negative path**, and **references** commands already proven in Phase 2–3 `VERIFICATION.md` files where practical.
- **D-02:** Provide **`docs/security/validation-checklist.md`** — checkbox checklist mirroring script sections for auditors and PR reviewers (FR-4).

### Regression probing

- **D-03:** Provide **`scripts/security-regression.sh`** that creates an **ephemeral git repository**, stages a **blocked path** (`docs-vault/…`), runs **`scripts/pre-commit-guard.sh`**, and **fails the run if the guard does not exit non-zero** (policy still enforced).
- **D-04:** Do **not** require network or GitHub for regression — local-only, deterministic cleanup (`mktemp`, `rm -rf`).

### Maintainer ergonomics

- **D-05:** Add a **short README** subsection linking to the checklist and both scripts; keep commands copy-paste (`./scripts/…`).

### Documentation sync

- **D-06:** Update **`.planning/PROJECT.md`** success criteria only where needed to reflect “executable validation path exists” — minimal edit.

### Claude's Discretion

- Exact ordering of checks inside `validate-security.sh` and wording in the checklist — constrained by D-01–D-05.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Requirements and roadmap

- `.planning/REQUIREMENTS.md` — **FR-3** secure local setup / repeatable review; **FR-4** verification; **NFR-2** reproducibility.
- `.planning/ROADMAP.md` — Phase 4 deliverables and verification bullets.

### Implemented controls to validate (prior phases)

- `.planning/phases/02-local-only-guardrails-implementation/VERIFICATION.md` — bump lanes, pre-commit guard, setup vault validation.
- `.planning/phases/03-secure-content-handling-and-redaction/VERIFICATION.md` — redaction helper + hook references.
- `docs/security/outbound-allowlist.md` — publish lane contract.
- `docs/security/sensitive-content-handling.md` — redaction policy.
- `scripts/pre-commit-guard.sh` — blocked path prefixes.
- `scripts/redact_public_text.py` — stdin filter.

### Codebase maps

- `.planning/codebase/TESTING.md` — gaps explicitly call for executable hook smoke / CI-friendly validation.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable assets

- **`scripts/pre-commit-guard.sh`** — regression target (must block staged `docs-vault/*`).
- **`scripts/redact_public_text.py`** — compile + stdin smoke in validate driver.
- **Hook scripts** under `skills/code-to-docs-hooks/hooks/*.sh` — `bash -n` sweep.

### Established patterns

- Strict bash (`set -euo pipefail`), Python stdlib only — carry forward into new scripts.

### Integration points

- README audience overlaps maintainer security workflow — single subsection suffices.

</code_context>

<specifics>
## Specific Ideas

- Prefer **one validate driver** over scattering checks across unrelated files.

</specifics>

<deferred>
## Deferred Ideas

- GitHub Actions workflow when maintainers want hosted gates — note in checklist “optional CI” without implementing here.

</deferred>

---

*Phase: 04-hardening-validation-and-regression-checks*  
*Context gathered: 2026-04-29*
