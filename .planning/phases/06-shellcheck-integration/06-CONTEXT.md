# Phase 6: shellcheck integration - Context

**Gathered:** 2026-04-29  
**Status:** Ready for planning

<domain>
## Phase Boundary

Add **shellcheck** to the PR pipeline with an **explicit scope** matching existing bash validation, a **documented severity policy**, and a **single shared entrypoint** so CI and local runs stay aligned (SHL-01–SHL-03). Documentation polish for contributors lands in **Phase 7** except minimal inline comments.

</domain>

<decisions>
## Implementation Decisions

### Scope (SHL-01)

- **D-01:** Shellcheck runs on the **same shell files** as `validate-security.sh`’s syntax pass: all `*.sh` under `scripts/` and `skills/code-to-docs-hooks/hooks/` (equivalent to `find scripts skills/code-to-docs-hooks/hooks -name '*.sh'`). No additional roots in Phase 6.
- **D-02:** **Exclusions** are **per-file** only via standard `shellcheck disable` directives where justified — no repo-wide ignore file in Phase 6 unless a file blocks the gate (then fix or narrowly disable with comment).

### Severity / failure policy (SHL-02)

- **D-03:** Use **`shellcheck --severity=warning`** — warnings and errors fail; style/info-level findings do not fail the gate. Document that tightening to `--severity=error` is a future ratchet option.
- **D-04:** Propagate shellcheck **exit code** to CI (no `continue-on-error`).

### CI integration

- **D-05:** Extend **existing** `.github/workflows/security-ci.yml` **job** `security-validate`: after **`Run validate-security.sh`**, add steps to **install shellcheck** on the Ubuntu runner (`apt-get update && apt-get install -y shellcheck`) then **run the shared wrapper** `./scripts/run-shellcheck.sh` so CI and local share logic.
- **D-06:** Step title **`Run shellcheck`** — keeps logs distinct from `validate-security.sh` (CI-04 spirit).

### Local parity (SHL-03)

- **D-07:** Add **`scripts/run-shellcheck.sh`** (executable) implementing D-01 + D-03. If `shellcheck` is missing from PATH, print install hints (brew/apt) and **exit 127** — same pattern as other tooling scripts.

### Claude's Discretion

- **D-08:** Do not add **pre-commit** shellcheck in Phase 6 (optional Phase 7 / backlog).
- **D-09:** Omit **`shellcheck -x`** unless a script fails without it; add only if needed after first CI run.

### Folded Todos

(None.)

</decisions>

<canonical_refs>
## Canonical References

### Roadmap & requirements

- `.planning/ROADMAP.md` — Phase 6 goal, SHL-01–SHL-03.
- `.planning/REQUIREMENTS.md` — Shell validation section.

### Prior phase

- `.planning/phases/05-pr-ci-workflow-linux-validation-path/05-CONTEXT.md` — CI job shape; shellcheck is a **separate step** after validate-security.

### Research

- `.planning/research/PITFALLS.md` — shellcheck scope / noise (ratchet, incremental).
- `.planning/research/SUMMARY.md` — shellcheck layer after runtime validation.

### Implementation

- `scripts/validate-security.sh` — Parity reference for **find** scope (bash -n loop).
- `.github/workflows/security-ci.yml` — Workflow to extend.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable assets

- **`scripts/validate-security.sh`** — Defines which `.sh` paths are “in scope” for security automation; shellcheck should stay consistent.
- **Phase 5 workflow** — Same job; append steps (avoid new workflows).

### Established patterns

- **Fail-closed** — Non-zero exits fail CI.
- **Thin CI** — Install tool + run repo script.

### Integration points

- **`security-ci.yml`** — Add shellcheck steps after existing validate step.

</code_context>

<specifics>
## Specific Ideas

- Keep **one job** so PR checks stay a single required context if branch protection is enabled later.

</specifics>

<deferred>
## Deferred Ideas

- **Pre-commit** shellcheck hook.
- **SHA-pinning** system packages — not applicable; using distro `shellcheck` package.
- **shellcheck -x** — enable only if sourcing causes false negatives.

</deferred>

---

*Phase: 6-shellcheck integration*  
*Context gathered: 2026-04-29*
