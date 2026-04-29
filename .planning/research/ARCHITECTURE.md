# Architecture Research

**Domain:** CI integration for an existing bash-centric validation stack  
**Researched:** 2026-04-29  
**Confidence:** HIGH

## Standard Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     GitHub (pull_request)                    │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐      ┌─────────────────────────────────┐  │
│  │ checkout     │ ───► │ Job: validate (ubuntu-latest)    │  │
│  └──────────────┘      │  • run validate-security.sh        │  │
│                        │  • run shellcheck (scoped)        │  │
│                        └─────────────────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                     Maintainer feedback                       │
│          (status check → merge gate when enabled)             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              Local dev (unchanged v1.0 posture)              │
│   ./scripts/validate-security.sh  |  shellcheck scripts/    │
└─────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| Workflow YAML | Declares triggers, permissions, steps | `.github/workflows/*.yml` |
| validate-security.sh | Authoritative repo checks | Existing script; CI calls it |
| shellcheck | Static analysis layer | Separate step or folded into script |
| Docs | Explains parity local vs CI | `docs/security/*`, README |

## Recommended Project Structure

```
.github/
└── workflows/
    └── security-ci.yml    # or validate.yml — PR validation + shellcheck

scripts/
├── validate-security.sh   # existing — ensure CI-safe
└── …

docs/security/
└── (update) ci.md or section in existing doc
```

### Structure Rationale

- **`.github/workflows/`:** GitHub’s standard discovery path; one workflow keeps complexity low.
- **`scripts/`:** Keeps execution logic out of YAML beyond invocation.

## Architectural Patterns

### Pattern 1: Thin workflow, fat script

**What:** YAML only invokes repo scripts; minimal inline bash.  
**When to use:** This repo already centers on `validate-security.sh`.  
**Trade-offs:** Script must be portable; YAML stays auditable.

### Pattern 2: Fail-fast steps

**What:** Separate steps for `validate-security` vs `shellcheck` for clearer logs.  
**When to use:** When debugging which layer failed matters.  
**Trade-offs:** Slightly longer setup; better UX.

### Pattern 3: Least privilege `permissions`

**What:** `contents: read` for checkout-only jobs; narrow if adding codex/comment bots later.  
**When to use:** Always default for validation-only workflows.  
**Trade-offs:** Must widen if workflow later posts comments.

## Data Flow

### PR check flow

```
PR opened / updated
    ↓
Workflow triggered
    ↓
Checkout repo at merge ref
    ↓
Run validate-security.sh → exit code 0/1
    ↓
Run shellcheck on scoped paths → exit code 0/1
    ↓
GitHub displays check result on PR
```

### Key Data Flows

1. **Code → CI:** Read-only clone; no secret material should be required for baseline validation.
2. **Failure → human:** Logs in Actions; optional artifact for large outputs.

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| Single maintainer / low PR volume | Single job sufficient |
| High PR volume | Cache apt/shellcheck if setup adds install steps; keep job idempotent |

### Scaling Priorities

1. **First bottleneck:** Script runtime — profile before parallelizing.
2. **Second bottleneck:** Flaky environment — pin runner or dependencies.

## Anti-Patterns

### Anti-Pattern 1: Divergent CI and local commands

**What people do:** Different checks in CI vs README.  
**Why it's wrong:** Contributors cannot reproduce failures.  
**Do this instead:** Same script entrypoints; document flags.

### Anti-Pattern 2: Over-broad shellcheck day one

**What people do:** `shellcheck **/*.sh` with legacy noise.  
**Why it's wrong:** Constant red CI; checks get ignored.  
**Do this instead:** Scoped paths, severity, or phased fixes.

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| GitHub Actions | YAML workflows | Align job permissions with org policy |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| Workflow ↔ scripts | Process exit codes | Keep shell `set -euo pipefail` behavior explicit |

## Sources

- GitHub Actions documentation — workflow structure and permissions  
- v1.0 milestone artifacts — existing validation boundaries  

---
*Architecture research for: v1.1 CI integration*  
*Researched: 2026-04-29*
