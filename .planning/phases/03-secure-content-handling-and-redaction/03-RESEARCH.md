# Phase 3 — Research notes

**Date:** 2026-04-29  
**Scope:** Secure content handling / redaction / retention (FR-2)

## Findings

1. **Hook surfaces:** `digest-on-start.sh` emits `project`, `modules`, `timestamp`, `commit` from `analysis.json`. Project/modules are the highest-risk user-visible fields if analysis captured repo-specific titles or paths.
2. **stdlib approach:** A small Python filter keeps dependencies zero and matches Phase 2 `setup.sh` JSON pattern; avoids maintaining parallel regex in bash.
3. **Policy-first:** ROADMAP emphasizes guidance and sample runs — pair `docs/security/*.md` with reproducible `bash -n` / dry-run checks in VERIFICATION.md.
4. **Retention:** `.gitignore` already excludes vault outputs; Phase 3 documents operator cleanup of `_state` and large traces without building a shredder.

## Alternatives considered

| Option | Rejection |
|--------|-----------|
| Full log scrubber daemon | Out of scope for local skill repo. |
| sed-only redaction | Harder to maintain; Python regex already used in hooks. |

## Planner handoff

Implement **D-01–D-06** from `03-CONTEXT.md` via plan `03-01`; verification commands must be copy-paste reproducible.
