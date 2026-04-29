# Phase 5: PR CI workflow + Linux validation path - Context

**Gathered:** 2026-04-29  
**Status:** Ready for planning

<domain>
## Phase Boundary

Deliver a GitHub Actions workflow that runs on pull requests and executes `./scripts/validate-security.sh` on a Linux-hosted runner with least-privilege permissions and logs that clearly attribute failures to this validation step (shellcheck is **Phase 6** only).

</domain>

<decisions>
## Implementation Decisions

### Triggers & branch scope (CI-01)

- **D-01:** Use `on: pull_request` with branch filter **`branches: [main]`** (targets PRs whose merge base is `main`). Do not add `workflow_dispatch` in Phase 5 — manual runs stay backlog / optional later milestone note.
- **D-02:** Do **not** add `pull_request` paths filters in Phase 5; full-repo validation matches current `validate-security.sh` scope.

### Runner & environment (Linux parity)

- **D-03:** `runs-on: ubuntu-latest` — matches research recommendation; `validate-security.sh` uses `bash`, `find`, `python3` (available on hosted runners). If a future regression hits mover images, pin `ubuntu-22.04` in a follow-up PR.
- **D-04:** Single job per Phase 5 (no matrix). Document in PLAN if OS matrix is explicitly deferred.

### Permissions & third-party actions (CI-03)

- **D-05:** Set **`permissions: contents: read`** at workflow level (job inherits). No `id-token`, packages, or write scopes for this phase.
- **D-06:** Use **`actions/checkout@v4`** as the only GitHub-owned action in Phase 5. Tag pin acceptable for `actions/*`; record in DISCUSSION-LOG that orgs may later adopt full SHA pinning — not a Phase 5 gate.

### Job layout, naming & logs (CI-02, CI-04)

- **D-07:** Job id: **`security-validate`**. Two named steps: (1) **Checkout repository** — `actions/checkout@v4`; (2) **Run validate-security.sh** — `run: ./scripts/validate-security.sh` from repo root (script is bash + executable bit expected; if Windows path issues arise, use `bash ./scripts/validate-security.sh` in PLAN).
- **D-08:** Do not wrap the script in extra `continue-on-error`. Exit code from the script must fail the step. Echo prefixes inside the script already segment logs; YAML stays thin.

### Claude's Discretion

- Optional: **concurrency** group `ci-${{ github.ref }}` to cancel superseded PR runs — nice-to-have; planner may include if zero-config.
- **checkout fetch-depth:** default (full history) unless validate script later needs shallow — current script does not; keep default.

### Folded Todos

(None — `todo.match-phase` returned no matches.)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Roadmap & requirements

- `.planning/ROADMAP.md` — Phase 5 goal, success criteria, CI-01–CI-04 mapping.
- `.planning/REQUIREMENTS.md` — CI-01–CI-04 acceptance text for this milestone.

### Research & policy

- `.planning/research/SUMMARY.md` — CI architecture (thin YAML, fat script), Linux parity pitfalls.
- `.planning/research/PITFALLS.md` — macOS vs Linux, permissions, shellcheck noise (shellcheck deferred to Phase 6).
- `docs/security/outbound-allowlist.md` — CI must not expand outbound surface beyond policy.
- `docs/security/sensitive-content-handling.md` — Assistant-facing and logging expectations (unchanged by CI adds).

### Implementation surface

- `scripts/validate-security.sh` — Authoritative checks for Phase 5; must pass on `ubuntu-latest` when repo is clean.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets

- **`scripts/validate-security.sh`** — Single entrypoint: `bash -n` on `scripts/**/*.sh` and hooks paths, `python3` compile + smoke for `redact_public_text.py`, policy file presence, vault path rejection test. No macOS-specific binaries in the skim — suitable for Linux CI if paths exist.

### Established Patterns

- **Thin orchestration, fat script** — Workflow should only checkout and invoke the script; no duplicate logic in YAML.
- **Fail-closed** — Script uses `set -euo pipefail` and aggregates `FAILED`; CI must preserve non-zero exit.

### Integration Points

- **New:** `.github/workflows/*.yml` (directory does not exist yet — greenfield).
- **Hooks/skills paths** — Script references `skills/code-to-docs-hooks/hooks` and `scripts/`; repo layout must be checked out completely.

</code_context>

<specifics>
## Specific Ideas

- Align job name **`security-validate`** with future GitHub **required status checks** naming (stable identifier).
- Keep Phase 5 YAML free of secrets — validation requires none today.

</specifics>

<deferred>
## Deferred Ideas

- **`workflow_dispatch`** — useful for audits; belongs to backlog / optional Phase 7 doc if added later.
- **`actions/checkout` SHA pinning** — supply-chain hardening; optional follow-up PR after baseline CI is green.
- **shellcheck / stricter lint** — Phase 6 per roadmap.
- **Fork PR workflows** — standard `pull_request` runs with read-only token; no secrets required for current script.

### Reviewed Todos (not folded)

(None.)

</deferred>

---

*Phase: 5-PR CI workflow + Linux validation path*  
*Context gathered: 2026-04-29*
