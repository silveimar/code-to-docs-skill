# Phase 7: Documentation, verification, and milestone closure prep - Context

**Gathered:** 2026-04-29  
**Status:** Ready for planning

<domain>
## Phase Boundary

Publish **maintainer-facing documentation** so CI behavior, local parity, and outbound posture for PR validation are explicit (DOC-01, NFR-01–NFR-03). Record **milestone-level verification** for v1.1 (DOC-02). Does **not** run `gsd-complete-milestone` archive copies unless separately requested — this phase delivers **docs + verification artifacts** only.

</domain>

<decisions>
## Implementation Decisions

### Documentation placement (DOC-01)

- **D-01:** Add **`docs/security/ci-validation.md`** as the canonical description of PR CI (triggers, workflow path, step order, local commands, policy alignment).
- **D-02:** Extend **`README.md`** section **Local security validation** with a short summary, bullets for `run-shellcheck.sh`, and a link to `docs/security/ci-validation.md` (avoid duplicating long prose in README).

### Policy cross-links (NFR-01)

- **D-03:** Update **`docs/security/outbound-allowlist.md`** with a dedicated subsection for **GitHub Actions** — checkout (GitHub), `apt-get` on Ubuntu runners for the `shellcheck` package only — **no** repo script egress beyond existing allowlist; CI does not use `bump.sh` or publish lanes.

### Checklist maintenance (DOC-01 / traceability)

- **D-04:** Replace the stale **Optional CI** note in **`docs/security/validation-checklist.md`** with the **current** automated job (validate-security + shellcheck) and pointers to the workflow file.

### Verification artifacts (DOC-02)

- **D-05:** Write **`07-VERIFICATION.md`** (this phase) summarizing v1.1 verification coverage and referencing Phase 5/6 `VERIFICATION.md` files plus REQUIREMENTS checkbox completion.

### Reproducibility wording (NFR-02)

- **D-06:** In `ci-validation.md`, state explicitly that **the same scripts** run locally and in CI; note **OS packaging** differences (e.g. `brew` vs `apt` for shellcheck) without changing script behavior.

### Language (NFR-03)

- **D-07:** All new prose in **English**, consistent with v1.0 FR-5.

### Milestone index (closure prep)

- **D-08:** Update **`.planning/MILESTONES.md`** so **v1.1** is marked **shipped** with date and pointers to roadmap/requirements (formal archive directory optional follow-up).

### PROJECT.md

- **D-09:** Add **current state after v1.1** bullets (CI + shellcheck docs); adjust milestone wording to **complete** for planning purposes.

### Claude's Discretion

- **D-10:** Single plan file **`07-01-PLAN.md`** covering all doc edits in one wave unless merge conflicts suggest splitting (not expected).

</decisions>

<canonical_refs>
## Canonical References

- `.planning/ROADMAP.md` — Phase 7 goals.
- `.planning/REQUIREMENTS.md` — DOC-01–DOC-02, NFR-01–NFR-03.
- `.github/workflows/security-ci.yml` — Source of truth for CI steps.
- `scripts/validate-security.sh`, `scripts/run-shellcheck.sh` — Local parity commands.
- `.planning/phases/05-pr-ci-workflow-linux-validation-path/VERIFICATION.md`, `.planning/phases/06-shellcheck-integration/VERIFICATION.md` — Phase evidence.

</canonical_refs>

<code_context>
## Existing Code Insights

- README already has **Local security validation** — extend, do not replace unrelated sections.
- `docs/security/` is the established policy home — new `ci-validation.md` fits alongside outbound-allowlist.

</code_context>

<specifics>
## Specific Ideas

- Keep diagrams optional — prose + tables only unless README already uses mermaid for security (it doesn’t for this subsection).

</specifics>

<deferred>
## Deferred Ideas

- **Branch protection** screenshot/docs — org settings; mention only as optional in `ci-validation.md`.
- **Archiving** `v1.1` roadmap snapshot under `.planning/milestones/` — defer to `/gsd-complete-milestone` if user wants file copies.

</deferred>

---

*Phase: 7 — Documentation, verification, and milestone closure prep*  
*Context gathered: 2026-04-29*
