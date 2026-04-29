# Stack Research

**Domain:** GitHub Actions CI + shell validation for a local-first security skill repo  
**Researched:** 2026-04-29  
**Confidence:** HIGH

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| GitHub Actions | `actions/checkout@v4` | Clone repo on `ubuntu-latest` (or pin) for PR runs | Default, maintained; v4 is current major for Node 20 runtime |
| GitHub Actions | `actions/upload-artifact@v4` (optional) | Store logs on failure | Standard for surfacing `validate-security` output in PRs |
| shellcheck | **0.9.x+** (distro or pinned) | Static analysis for bash/sh | De facto standard; matches v1.0’s shell-heavy scripts |
| GNU bash / dash | As on `ubuntu-latest` | Execute `./scripts/validate-security.sh` | Parity with common Linux CI; document if macOS-only assumptions exist |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `koalaman/shellcheck-precommit` pattern (or local hook) | n/a | Mirror CI rules locally | If you add pre-commit shellcheck in a later sub-step |
| `actionlint` (optional) | Latest via installer | Validate workflow YAML | When workflows grow complex; not required for a single job |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| `shellcheck` CLI | Local parity with CI | Install via brew/apt; same flags as CI |
| `act` (optional) | Run workflows locally | Useful for debugging; not mandatory |

## Installation

```bash
# Local (macOS)
brew install shellcheck

# CI — typically
sudo apt-get update && sudo apt-get install -y shellcheck   # ubuntu-latest
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| `ubuntu-latest` runner | `ubuntu-22.04` pin | Reproducibility or GLIBC compatibility issues |
| shellcheck | `shfmt` only | Formatting without semantics — insufficient alone for safety |
| Single workflow file | Reusable workflow | Multiple repos sharing same checks |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Pulling unpinned third-party actions without hash pinning | Supply-chain risk | Pin to full commit SHA for non-GitHub-owned actions |
| Running validation only on `push` to main | Regressions merge via PR | Use `pull_request` (and optionally `workflow_dispatch`) |

## Stack Patterns by Variant

**If scripts assume macOS paths:**

- Use a matrix or document “best effort” Linux CI; add guards in scripts or skip incompatible steps in CI with explicit messaging.

**If repo must stay zero-network except allowlisted:**

- CI uses GitHub-hosted runners as controlled egress; keep workflow steps minimal and aligned with `docs/security` outbound policy.

## Version Compatibility

| Package A | Compatible With | Notes |
|-----------|-----------------|-------|
| `actions/checkout@v4` | Node 20 on runner | Matches current Actions defaults |
| shellcheck 0.9.x | Bash 3.2+ / POSIX checks | Align severity with script dialect (`shell` directive in scripts) |

## Sources

- GitHub Docs — [Workflow syntax for GitHub Actions](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions) — verified 2026-04-29  
- shellcheck — [GitHub koalaman/shellcheck](https://github.com/koalaman/shellcheck) — stable usage patterns  
- Context7 — prefer refresh during implementation for exact `actions/*` tag SHAs if policy requires pinning  

---
*Stack research for: CI + shell validation for Code-to-Docs skill*  
*Researched: 2026-04-29*
