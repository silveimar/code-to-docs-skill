# Phase 4 — Discussion log (`--chain` + `--analyze`)

**Invocation:** `/gsd-discuss-phase 4 --chain --analyze`  
**Date:** 2026-04-29

Notes: `--analyze` requires a trade-off table before each gray-area decision. `--chain` auto-advances to `/gsd-plan-phase 4 --auto` after context is written.

---

## Gray area 1 — Where should repeatable validation live?

**Trade-off analysis: validation entrypoint**

| Approach | Pros | Cons |
|----------|------|------|
| **Single bash driver** in `scripts/` (e.g. `validate-security.sh`) | Matches existing `scripts/bump.sh`, `pre-commit-guard.sh`; zero new tooling; runs everywhere CI/mac/linux | No npm/Makefile discoverability for JS-centric contributors |
| **Makefile targets** | Familiar `make validate` UX | Extra layer for a repo that is mostly markdown + bash |
| **package.json scripts** | IDE integration | No `package.json` at root today — would add surface area |

**Recommended:** **Single bash driver in `scripts/validate-security.sh`** — aligns with `.planning/codebase/TESTING.md` (actionable: "executable smoke suite for hook scripts") and keeps NFR-2 fail-closed behavior in one place.

**Decision:** Adopt recommended driver + companion markdown checklist in `docs/security/validation-checklist.md` (human-readable traceability for FR-4).

---

## Gray area 2 — How deep should “regression” automation go?

**Trade-off analysis: regression checks**

| Approach | Pros | Cons |
|----------|------|------|
| **Ephemeral git fixture** — temp repo + staged `docs-vault/*` → expect guard exit 1 | Proves `pre-commit-guard.sh` still blocks sensitive paths | Temp dirs; must invoke guard by absolute path |
| **Only static greps** | Fast, no git state | Does not prove guard wiring |
| **Full CI matrix** | Maximum confidence | No `.github/workflows` yet — out of scope for minimal Phase 4 |

**Recommended:** **Ephemeral git fixture script** `scripts/security-regression.sh` that expects non-zero from `pre-commit-guard.sh` when illegal paths are staged — satisfies roadmap verification (“catch intentionally introduced policy violations”) without requiring hosted CI.

**Decision:** Adopt regression script + keep checklist documenting manual spot-checks for bump lanes and vault validation.

---

## Gray area 3 — Developer workflow surfacing

**Trade-off analysis: discoverability**

| Approach | Pros | Cons |
|----------|------|------|
| **README section** | Maintainers see commands immediately | Top-level README grows |
| **CONTRIBUTING.md only** | Keeps README short | Easy to miss |
| **docs/security only** | Central policy | Lower discovery |

**Recommended:** **Short README subsection** linking to `docs/security/validation-checklist.md` — fits PROJECT.md goal (“baseline verification integrated into workflows”) without new top-level files.

**Decision:** Add “Local security validation” subsection to `README.md`.

---

## Summary

All three gray areas resolved using the **recommended** column — consistent with prior phases’ bash-first, fail-closed, locally reproducible posture (02/03 CONTEXT).
