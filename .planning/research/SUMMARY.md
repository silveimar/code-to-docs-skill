# Project Research Summary

**Project:** Code-to-Docs Skill Hardening (Local-Only)  
**Domain:** GitHub Actions CI + shellcheck on an existing bash validation stack  
**Researched:** 2026-04-29  
**Confidence:** HIGH

## Executive Summary

v1.1 adds automated enforcement that mirrors local safety work from v1.0: a pull-request workflow on GitHub-hosted runners should invoke the same entrypoints maintainers already trust (`./scripts/validate-security.sh`) and add static shell analysis via shellcheck with a deliberately scoped, noisy-safe rollout. Architecture stays **thin YAML, fat scripts** so outbound surface and behavior stay reviewable under existing security docs. The main risks are **Linux vs macOS parity** for scripts, **shellcheck scope creep**, and **workflow supply-chain hygiene** (permissions, action pinning). Mitigations are portable scripting or documented CI assumptions, incremental shellcheck coverage with excludes/documented directives, and least-privilege workflow permissions with pinned first-party patterns.

## Key Findings

### Recommended Stack

Use GitHub Actions with `actions/checkout@v4`, `ubuntu-latest` (or a pinned Ubuntu if reproducibility demands), `shellcheck` from the runner package manager or a pinned install, and optional `actions/upload-artifact@v4` for logs. Avoid introducing new network calls beyond GitHub and package installs already aligned with policy.

**Core technologies:**

- **GitHub Actions:** PR-triggered validation — industry default for OSS repos.  
- **shellcheck:** Catches shell semantics bugs — complements runtime checks in `validate-security.sh`.  
- **Existing bash scripts:** Single source of truth — keeps CI and local dev aligned.

### Expected Features

**Must have (table stakes):**

- PR workflow that runs `./scripts/validate-security.sh` non-interactively.  
- shellcheck integrated with explicit path/severity policy.  
- Documentation tying CI behavior to local commands and security posture.

**Should have (competitive):**

- Clear step boundaries / logs for debugging failures quickly.  
- Optional artifact upload on failure if logs grow large.

**Defer (v2+):**

- policy-as-code scorecard, encrypted local storage — remain backlog per PROJECT non-goals for this milestone.

### Architecture Approach

Treat CI as a **read-only clone + invoke scripts** pattern with optional separate steps for shellcheck. Keep permissions minimal (`contents: read` for pure validation). Document the relationship between local runs and CI in `docs/security` or README so contributors can reproduce failures.

**Major components:**

1. **Workflow file(s)** — triggers, jobs, permissions.  
2. **validate-security.sh** — unchanged contract where possible; Linux-safe path.  
3. **shellcheck layer** — scoped analysis with manageable signal-to-noise.

### Critical Pitfalls

1. **macOS vs Linux script drift** — reproduce on Linux before enforcing.  
2. **shellcheck noise** — scope gradually; avoid repo-wide enable without baseline.  
3. **Workflow permissions / actions** — avoid `pull_request_target` misuse; pin risky actions.  
4. **Drift between README and CI** — same commands documented.

## Implications for Roadmap

Suggested phase structure (starting at **Phase 5** — continuing v1.0 numbering):

### Phase 5: CI workflow skeleton + Linux-safe validation

**Rationale:** Establishes PR signal without expanding lint scope.  
**Delivers:** `.github/workflows/*.yml`, green path running `validate-security.sh` on `ubuntu-latest`.  
**Addresses:** PR automation table stakes.  
**Avoids:** shellcheck noise before baseline exists.

### Phase 6: shellcheck integration + policy

**Rationale:** Adds static analysis after runtime gate is stable.  
**Delivers:** Scoped shellcheck, documented excludes/severity, optional pre-commit alignment note.  
**Addresses:** shell quality requirements.  
**Avoids:** Anti-pattern “enable everywhere day one.”

### Phase 7: Documentation + verification

**Rationale:** Locks maintainer UX and audit trail.  
**Delivers:** Updates to `docs/security`/README, VERIFICATION or checklist entries.  
**Addresses:** Traceability and onboarding.  
**Avoids:** Undocumented CI/local divergence.

### Phase Ordering Rationale

- Runtime validation before static lint reduces simultaneous failure modes.  
- Docs last so they reference final commands and scope.

### Research Flags

- **Phase 5:** May need one-off Linux debugging — budget time for path/tool fixes.  
- **Phase 6:** May need ratcheting — multiple small fixes if legacy warnings exist.

Phases with standard patterns:

- **Phase 7:** Documentation-only patterns — low novelty risk.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Well-documented Actions + shellcheck |
| Features | HIGH | Narrow milestone scope |
| Architecture | HIGH | Matches repo’s script-centric model |
| Pitfalls | MEDIUM-HIGH | Linux parity depends on current scripts |

**Overall confidence:** HIGH

### Gaps to Address

- **Actual script portability:** Validate by running `validate-security.sh` in Linux environment during Phase 5 planning.  
- **Org settings:** Branch protection is outside repo — document recommendation only.

## Sources

### Primary (HIGH confidence)

- GitHub Docs — workflow syntax, permissions  
- shellcheck project documentation  

### Secondary (MEDIUM confidence)

- OSS patterns for shellcheck in CI  

---
*Research completed: 2026-04-29*  
*Ready for roadmap: yes*
