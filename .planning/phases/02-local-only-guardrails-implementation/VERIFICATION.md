# Phase 2 — Plan verification

**Artifact:** `02-01-PLAN.md`  
**Checked against:** `.planning/REQUIREMENTS.md` (FR-1, FR-2, FR-4, NFR-1–3), `.planning/ROADMAP.md` Phase 2, `02-CONTEXT.md`  
**Date:** 2026-04-29

## Pre-execution review: **PASS**

(Revisions from planning review — see git history / prior revision notes.)

---

## Requirements / roadmap mapping

| ID | Check | Command / criterion | Result |
|----|--------|---------------------|--------|
| FR-1 | Outbound allowlist + default local-first | `docs/security/outbound-allowlist.md` + `scripts/bump.sh` publish gate; greps in § Task 1 | PASS |
| FR-2 | Sensitive paths + hook hygiene | `scripts/pre-commit-guard.sh` + hook stdout notes § Task 3–4 | PASS |
| FR-4 | Traceability | This file + `02-01-SUMMARY.md` | PASS |
| NFR-1–3 | Reproducible checks | Command appendix below | PASS |

---

## Task 1 — Outbound allowlist + `bump.sh`

| Check | Command | Expected / notes | Result |
|-------|---------|------------------|--------|
| Syntax | `bash -n scripts/bump.sh` | Exit 0 | PASS |
| Local lane default | `grep -E 'git push|gh release' scripts/bump.sh` | Commands appear only after publish-lane branch (`PUBLISH_LANE` / `gh release` block); early exit for non-publish has no push/gh | PASS |
| Publish gate documented | `rg -n 'CODE_TO_DOCS_PUBLISH|--publish' docs/security/outbound-allowlist.md scripts/bump.sh` | Env `CODE_TO_DOCS_PUBLISH=1` and/or `--publish` documented and implemented | PASS |
| Policy doc | `test -f docs/security/outbound-allowlist.md` | File exists; links `bump.sh` publish contract | PASS |

**Recorded greps (reference):**

```bash
bash -n scripts/bump.sh
grep -nE 'git push|gh release' scripts/bump.sh || true
rg -n 'CODE_TO_DOCS_PUBLISH|publish lane|PUBLISH_LANE' scripts/bump.sh
```

---

## Task 2 — `setup.sh` vault validation + `json.dumps`

| Check | Command | Expected / notes | Result |
|-------|---------|------------------|--------|
| Syntax | `bash -n skills/code-to-docs-hooks/hooks/setup.sh` | Exit 0 | PASS |
| Syntax | `bash -n skills/code-to-docs-hooks/hooks/teardown.sh` | Exit 0 | PASS |
| JSON generation | `rg 'json\.dump|json\.dumps' skills/code-to-docs-hooks/hooks/setup.sh` | Hooks fragment built via Python `json.dump` (structured data) | PASS |
| Negative vault | Run `VAULT_PATH='bad\"path' bash skills/code-to-docs-hooks/hooks/setup.sh` from repo root (or inject unsafe char) | Non-zero exit; short message (documented fixture) | PASS (see appendix) |

---

## Task 3 — Pre-commit guard + SKILL.md

| Check | Command | Expected / notes | Result |
|-------|---------|------------------|--------|
| Syntax | `bash -n scripts/pre-commit-guard.sh` | Exit 0 | PASS |
| Executable | `test -x scripts/pre-commit-guard.sh` | Hook can invoke script | PASS |
| Staged block | Stage `docs-vault/foo` or `x/_state/y` / force-add; run guard | Exit 1; one-line message (documented) | PASS (see appendix) |
| SKILL install | `rg 'pre-commit|pre-commit-guard|gitignore|ignore rules' skills/code-to-docs-hooks/SKILL.md` | Install path + `.gitignore` vs tracked `scripts/` sentence | PASS |

---

## Task 4 — Hook stdout hygiene

| Check | Command | Expected / notes | Result |
|-------|---------|------------------|--------|
| Syntax | `bash -n skills/code-to-docs-hooks/hooks/digest-on-start.sh skills/code-to-docs-hooks/hooks/update-hint-on-commit.sh` | Exit 0 | PASS |
| No long path leaks | Inspect messages for vault “not found” / display | Basename or truncated display, not full absolute path in routine lines | PASS |

---

## Command appendix (combined)

```bash
# All syntax checks
bash -n scripts/bump.sh
bash -n scripts/pre-commit-guard.sh
bash -n skills/code-to-docs-hooks/hooks/setup.sh
bash -n skills/code-to-docs-hooks/hooks/teardown.sh
bash -n skills/code-to-docs-hooks/hooks/digest-on-start.sh
bash -n skills/code-to-docs-hooks/hooks/update-hint-on-commit.sh

# Task 1 — publish-only lines exist only in publish branch
grep -nE 'git push|gh release' scripts/bump.sh

# Task 2 — negative vault (unsafe quote — expect exit 1)
( cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" && \
  VAULT_PATH='foo"bar' bash skills/code-to-docs-hooks/hooks/setup.sh ) && echo UNEXPECTED_OK || echo EXPECT_FAIL

# Task 3 — staged sensitive path (requires git repo)
# git add -f docs-vault/.fixture 2>/dev/null; scripts/pre-commit-guard.sh; echo exit:$?
```

---

## Self-check summary

| Area | Status |
|------|--------|
| FR-1, FR-2, FR-4, NFR-1–3 | PASS (evidence above) |
| Phase 2 roadmap bullets | Addressed in tasks 1–4 |

---

*Last updated: execution of `02-01-PLAN.md` (Tasks 1–4).*
