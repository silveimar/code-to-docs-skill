# Pitfalls Research

**Domain:** Adding GHA + shellcheck to an existing security-focused bash repo  
**Researched:** 2026-04-29  
**Confidence:** HIGH

## Critical Pitfalls

### Pitfall 1: macOS-only assumptions in validation scripts

**What goes wrong:** `validate-security.sh` passes locally but fails on `ubuntu-latest` (paths, BSD vs GNU tools, `sed -i`).

**Why it happens:** Local dev on darwin; CI is Linux.

**How to avoid:** Run scripts in Linux container or CI dry-run before enforcing; guard OS-specific branches; document required tools.

**Warning signs:** Failures only on CI; path errors under `/Users` vs `/home/runner`.

**Phase to address:** First phase that wires CI (implement portable script path or document Linux-only CI scope).

---

### Pitfall 2: Secret or network leakage in CI steps

**What goes wrong:** Workflow adds steps that call external APIs contrary to v1.0 outbound posture.

**Why it happens:** Convenience scripts copy-paste from other projects.

**How to avoid:** Keep workflow to checkout + local scripts; review each step against `docs/security` allowlist.

**Warning signs:** New `curl`, `npm install` global hooks, or third-party actions without review.

**Phase to address:** CI workflow authoring phase + documentation phase.

---

### Pitfall 3: shellcheck noise overwhelms signal

**What goes wrong:** Thousands of SC2086/SC2155 warnings; contributors disable checks.

**Why it happens:** Enabling shellcheck repo-wide without baseline or excludes.

**How to avoid:** Scope to `scripts/` (and similar), use severity settings, fix or suppress intentionally per-file with comments.

**Warning signs:** PRs only touch unrelated files but fail on pre-existing issues everywhere.

**Phase to address:** shellcheck integration phase — define scope and baseline policy first.

---

### Pitfall 4: Non-reproducible Action versions

**What goes wrong:** Tag-moving action breaks CI or introduces compromised code.

**Why it happens:** Floating `@v4` without org policy.

**How to avoid:** Follow repo/org convention — pin SHAs for third-party actions; use Dependabot or renovate if adopted.

**Warning signs:** Sudden failures without code changes.

**Phase to address:** Initial workflow commit phase.

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Inline bash in YAML instead of scripts | Faster first PR | Duplication, drift | Never for core validation |
| Skip shellcheck for tests/fixtures | Green CI | Hidden bugs in harness | Only with explicit exclude list and review |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| `pull_request` from forks | Secrets unavailable on fork PRs | Keep validation unprivileged; no secrets needed |
| Concurrency | Duplicate runs waste minutes | `concurrency: group: ${{ github.workflow }}-${{ github.ref }}` optional |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Long sequential installs | 5–10 min jobs | Cache apt or use runner preinstalled shellcheck | Many PRs / large team |

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| `pull_request_target` with checkout misuse | Code execution with write token | Use standard `pull_request` for validation |
| Broad `permissions: write-all` | Supply chain / tampering | Default read-only for validate jobs |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Cryptic error from nested script | Lost time | Separate workflow steps; echo phase headers |

## "Looks Done But Isn't" Checklist

- [ ] **CI:** Workflow triggers on PRs to intended branches — verify with test PR.
- [ ] **Parity:** README documents exact local commands matching CI.
- [ ] **shellcheck:** Scope documented — verify excludes are justified.

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Linux incompatibility | MEDIUM | Reproduce in container; patch script; re-run |
| shellcheck flood | MEDIUM | Narrow scope; incremental ratcheting PR |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| macOS vs Linux | Phase implementing CI script path | Green CI on trivial PR |
| shellcheck noise | shellcheck phase | Contributor can reproduce locally |
| Action pinning | workflow authoring | Policy review in VERIFICATION |

## Sources

- GitHub security guidance on workflow permissions  
- Common shellcheck adoption post-mortems (community)  

---
*Pitfalls research for: v1.1*  
*Researched: 2026-04-29*
