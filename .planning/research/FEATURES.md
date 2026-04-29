# Feature Research

**Domain:** PR CI validation + shell quality for security scripts  
**Researched:** 2026-04-29  
**Confidence:** HIGH

## Feature Landscape

### Table Stakes (Maintainers Expect These)

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| PR-triggered workflow | Catch regressions before merge | LOW | `on: pull_request` targeting default branch |
| Run existing `./scripts/validate-security.sh` | Single source of truth with local | LOW–MEDIUM | Script must be Linux-safe and non-interactive |
| Clear failure logs in Actions UI | Debug without reproducing locally | LOW | Echo step boundaries; optional artifact upload |
| Documented CI behavior | Aligns with local-first policy | LOW | Link from README or `docs/security/` |

### Differentiators (Valuable but Optional)

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| shellcheck job or composite step | Catches classes of bugs tests miss | MEDIUM | Start with `scripts/` paths; tune excludes |
| Required status check / branch protection | Enforcement | LOW (org settings) | Product/process, not repo code |
| Matrix (multiple OS) | Broader coverage | HIGH | Often unnecessary for allowlisted bash |

### Anti-Features (Commonly Requested, Often Problematic)

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Full `security-regression.sh` in every PR | “Maximum coverage” | May be slow, need secrets, or flaky env | Gate heavy suite on label or nightly |
| Auto-fix bots rewriting scripts | Convenience | Review noise, policy drift | Fail CI; fix in dedicated PRs |

## Feature Dependencies

```
[CI workflow exists]
    └──requires──> [validate-security.sh runs clean on Linux]
                       └──requires──> [no macOS-only deps in script path]

[shellcheck clean]
    └──enhances──> [validate-security reliability]

[Branch protection]
    └──requires──> [stable job name / check run]
```

### Dependency Notes

- **CI requires Linux-safe scripts:** Auditing `validate-security.sh` dependencies prevents false red on PRs.
- **shellcheck enhances validation:** Order phases so script semantics are stable before tightening lint rules.

## MVP Definition

### Launch With (v1.1)

- [ ] PR workflow running `./scripts/validate-security.sh` (exit non-zero fails job).
- [ ] shellcheck integrated with explicit scope (directories/globs) and documented exclusions if needed.
- [ ] Short documentation of CI purpose, triggers, and how it relates to local runs.

### Add After Validation (v1.x)

- [ ] Upload artifacts on failure — when logs get large.
- [ ] Optional `workflow_dispatch` for manual audit runs.

### Future Consideration (v2+)

- [ ] policy-as-code / scorecard — already backlog in PROJECT.

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| PR + validate-security | HIGH | LOW | P1 |
| shellcheck | HIGH | MEDIUM | P1 |
| actionlint | MEDIUM | LOW | P2 |
| Matrix OS | LOW | HIGH | P3 |

## Competitor Feature Analysis

| Feature | Typical OSS security repos | Our Approach |
|---------|---------------------------|--------------|
| Lint + unit scripts | Common pattern | Align lint with existing script layout |
| GHA + pre-commit parity | Often mirrored | Document local commands matching CI |

## Sources

- GitHub Actions usage patterns in hardened OSS repos (informal)  
- Maintainer expectations from v1.0 local validation baseline  

---
*Feature research for: v1.1 CI & validation hardening*  
*Researched: 2026-04-29*
