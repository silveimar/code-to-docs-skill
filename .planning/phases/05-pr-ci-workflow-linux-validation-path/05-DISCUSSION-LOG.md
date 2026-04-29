# Phase 5: PR CI workflow + Linux validation path - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.  
> Decisions are captured in `05-CONTEXT.md`.

**Date:** 2026-04-29  
**Phase:** 5 — PR CI workflow + Linux validation path  
**Areas discussed:** Triggers & branches; Runner OS; Permissions & checkout action; Job layout & naming  
**Mode:** `--chain` (interactive discuss semantics; consolidated decisions from roadmap + research where infrastructure choices are fully constrained by CI-01–CI-04 and `.planning/research/SUMMARY.md`)

---

## Triggers & branch scope

| Option | Description | Selected |
|--------|-------------|----------|
| PR → `main` only | `pull_request` with `branches: [main]` | ✓ |
| PR to all branches | Broader triggers | |
| Include `workflow_dispatch` | Manual runs | Deferred |

**User's choice:** Consolidated default — PRs targeting `main` only for Phase 5; manual dispatch deferred (see CONTEXT deferred ideas).  
**Notes:** Matches CI-01; keeps fork PRs on standard `pull_request` semantics without secrets.

---

## Runner image

| Option | Description | Selected |
|--------|-------------|----------|
| `ubuntu-latest` | Moving baseline; Python 3 + bash available | ✓ |
| `ubuntu-22.04` pin | Fixed GLIBC/tool versions | |

**User's choice:** `ubuntu-latest` per research SUMMARY; pin later if reproducibility issues appear.

---

## Permissions & checkout action

| Option | Description | Selected |
|--------|-------------|----------|
| `contents: read` + `actions/checkout@v4` | Least privilege; maintained action | ✓ |
| SHA-pinned checkout only | Maximum supply-chain rigor | Deferred optional hardening |

**User's choice:** Read-only contents + `actions/checkout@v4`; SHA pinning noted as future improvement.

---

## Job layout & logging

| Option | Description | Selected |
|--------|-------------|----------|
| Single job `security-validate`; steps Checkout → Run script | Clear logs; matches CI-04 | ✓ |
| Matrix multi-OS | Broader coverage | Out of scope Phase 5 |

**User's choice:** Single job, named steps, script owns detailed log sections.

---

## Claude's Discretion

- Optional workflow **concurrency** — planner may add cancel-in-progress for PR refs.
- **fetch-depth** — default checkout depth unless script gains shallow-git assumptions.

## Deferred Ideas

- `workflow_dispatch`, SHA-pinning checkout, shellcheck — captured in `05-CONTEXT.md` deferred section.
