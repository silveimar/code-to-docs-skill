# Local security validation checklist

Use this checklist for **manual** PR / release review. Automated aggregate: `./scripts/validate-security.sh`. Guard regression probe: `./scripts/security-regression.sh`.

## Quick commands

| Step | Command | Expect |
|------|---------|--------|
| Aggregate checks | `./scripts/validate-security.sh` | Exit 0 |
| Pre-commit regression | `./scripts/security-regression.sh` | Exit 0 |
| Publish lane intent | `grep -nE 'git push|gh release' scripts/bump.sh` | Only inside publish / gated blocks (see Phase 2 VERIFICATION) |

## Shell & Python

- [ ] All `scripts/*.sh` and `skills/code-to-docs-hooks/hooks/*.sh` pass `bash -n` (included in `validate-security.sh`).
- [ ] `scripts/redact_public_text.py` compiles and redacts synthetic `sk-*` sample (included).

## Policy artifacts

- [ ] `docs/security/outbound-allowlist.md` present.
- [ ] `docs/security/sensitive-content-handling.md` present.
- [ ] `docs/security/artifact-retention.md` present.

## Hook / vault

- [ ] `CODE_TO_DOCS_VAULT='foo"bar' bash skills/code-to-docs-hooks/hooks/setup.sh` exits non-zero (included in validate script).

## Optional CI

- [ ] If adding GitHub Actions later, wire `./scripts/validate-security.sh` as a job step (not required for Phase 4 completion).
