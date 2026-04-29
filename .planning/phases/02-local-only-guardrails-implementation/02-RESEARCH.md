# Phase 2: Local-Only Guardrails Implementation — Research

**Researched:** 2026-04-29  
**Domain:** Bash hooks, Git/GitHub release workflow, JSON settings generation  
**Confidence:** MEDIUM (evidence from repo artifacts + locked CONTEXT; no runtime dependency versions probed)

## Summary

Phase 2 implements fail-closed guardrails aligned with **R-001, R-004, R-006** (`RISK-REGISTER.md`) and **DF-03, DF-06** (`DATA-FLOWS.md`). The repository already centralizes outbound behavior in `scripts/bump.sh` (push + `gh release create`) and hook command generation in `skills/code-to-docs-hooks/hooks/setup.sh`. The highest-impact implementation sequence is: (1) split **local** vs **publish** lanes in `bump.sh` with an explicit second gate per **D-03**; (2) validate `CODE_TO_DOCS_VAULT` / CLI vault path before writing JSON and prefer **JSON-native construction** (Python `json.dumps`) over heredoc string assembly for hook commands; (3) add a **pre-commit guard** that blocks forced staging of paths classified as sensitive in **FR-2** / `.gitignore`; (4) apply **minimal stdout hygiene** in hooks (Phase 2 scope per **D-10**), deferring pattern-based redaction to Phase 3 (**R-003**).

**Primary recommendation:** Gate all network I/O in `bump.sh` behind a documented env/flag contract; validate vault paths in `setup.sh` with fail-closed rules and emit warnings for out-of-repo absolute paths; implement `scripts/pre-commit-guard.sh` (or equivalent) aligned with `.gitignore` and document installation.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** Default posture is **fail-closed** for network egress unless the operation is part of an explicit **allowlisted command surface**.
- **D-02:** Maintain an **allowlist** of commands/scripts permitted to perform outbound/network actions (starting with `scripts/bump.sh`), documented in-repo with rationale and prerequisites (for example GitHub CLI auth).
- **D-03:** Git operations as **two lanes**: **Local lane** (tagging/version bump commits may remain local-only); **Publish lane** (**remote push + GitHub release**) requires an additional explicit gate beyond the script’s interactive confirmation (documented env/flag contract).
- **D-04:** `CODE_TO_DOCS_VAULT` / hook-installed vault paths may be **any absolute path**, but must emit a **high-signal warning** when outside the repository root (still permitted).
- **D-05:** Reject vault paths containing **quotes/control characters/shell metacharacters** at validation time (fail-closed), preferring robust escaping when generating `.claude/settings.json` hook commands.
- **D-06:** Add a **local pre-commit guard** that blocks staging/commits of known sensitive artifact paths/patterns, tuned to this repo’s layout.
- **D-07:** Keep `.gitignore` aligned as defense-in-depth; guard is **primary** automated prevention.
- **D-08:** Policy violations default to **fail-closed** (non-zero exit).
- **D-09:** Error messaging is **short and actionable** (no dumping sensitive content).
- **D-10:** Phase 2 **minimal sanitization only**; broader redaction → Phase 3.

### Claude's Discretion

- Exact allowlist membership beyond `scripts/bump.sh`, naming of env gates, structure of pre-commit guard (bash vs Python helper) — constrained by decisions above.

### Deferred Ideas (OUT OF SCOPE)

- Full redaction library/patterns for logs and transcripts — Phase 3.
- CI-grade secret scanning — optional backlog.
</user_constraints>

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|--------------|----------------|-----------|
| Outbound allowlist + publish gating | Maintainer scripts / docs (`scripts/`) | Planning docs (policy text) | Network-capable entry points are scripts, not hooks (`DATA-FLOWS.md` DF-06). |
| Vault path validation + safe JSON commands | Hook installer (`skills/code-to-docs-hooks/hooks/setup.sh`) | `.claude/settings.json` consumer (runtime) | TB-2: filesystem path becomes executable command (`DATA-FLOWS.md` DF-03; `THREAT-MODEL.md` TH-001). |
| Pre-commit guard | Local Git client (`pre-commit` hook) | `.gitignore` | Blocks accidental commits before remote; ignore rules are secondary (`02-CONTEXT.md` D-07). |
| Hook stdout minimization | Hook scripts (`digest-on-start.sh`, `update-hint-on-commit.sh`) | Phase 3 policy | Disclosure risk is hook transcript (`RISK-REGISTER.md` R-003 → Phase 3). |

## Standard Stack

### Core

| Component | Version | Purpose | Why Standard |
|-----------|---------|---------|--------------|
| Bash | `[ASSUMED]` 3.2+ on macOS | Scripting for hooks and `bump.sh` | Matches existing `set -euo pipefail` scripts (`scripts/bump.sh`, `hooks/*.sh`). |
| Python 3 | `[ASSUMED]` system `python3` | JSON merge in `setup.sh` / teardown | Already used for `json.load`/`json.dump` in `setup.sh` lines 73–99. |
| git / gh | `[ASSUMED]` CLI present for maintainer | Publish lane | `bump.sh` lines 90–94, 112–129. |

### Supporting

| Artifact | Purpose | Evidence |
|----------|---------|----------|
| In-repo **outbound policy doc** + optional machine-readable list | Satisfies **FR-1** “document allowed… operations” and **D-02** | `REQUIREMENTS.md` FR-1; `02-CONTEXT.md` D-02. |
| `scripts/pre-commit-guard.sh` (name discretionary) | **D-06** | Pattern matches “script/hook” in CONTEXT. |

**Version verification:** Not run — Phase 2 has no `package.json`/lockfile for npm-verified deps; stack is shell + stdlib Python.

## Focus Area (1) — Outbound Allowlist + Publish-Lane Gating for `bump.sh`

### Current behavior (evidence)

- After interactive `Proceed?`, `bump.sh` always runs `git tag`, `git push` (with errors suppressed), second `git push` for tag, then `gh release create` (`scripts/bump.sh` lines 80–129).
- **Silent push failure:** `git push 2>/dev/null || true` masks errors (`scripts/bump.sh` line 91), weakening operator feedback for local-vs-publish failures.

### Recommended approach

1. **Allowlist (D-02):** Add a short markdown file under the repo (e.g. `docs/security/outbound-allowlist.md` or `.planning/phases/02-local-only-guardrails-implementation/outbound-allowlist.md`) listing **`scripts/bump.sh`** as the only approved bundled outbound workflow, with prerequisites (`gh auth`, network, repo `REPO` constant at line 16), and pointer to publish-lane contract.
2. **Two lanes (D-03):** Refactor `bump.sh` into:
   - **Local lane (default):** version bump, optional commit, **local tag only**, no `git push`, no `gh` — satisfies “default workflows run without external calls” (`ROADMAP.md` Phase 2 Verification).
   - **Publish lane:** requires **second explicit gate** in addition to `read -rp` (e.g. `CODE_TO_DOCS_PUBLISH=1` or `./scripts/bump.sh … --publish`), documented in the same markdown; then run `git push` and `gh release create`.
3. **Fail-closed (D-01, D-08):** If publish lane requested but `gh` missing or `gh auth` fails, exit non-zero with short message (D-09); remove `|| true` on push or restrict to documented dry-run only.
4. **Traceability:** Maps **R-004** / **TH-007** (`RISK-REGISTER.md`, `THREAT-MODEL.md`) to explicit opt-in publish path.

## Focus Area (2) — Vault Path Validation + Safe JSON Hook Command Generation

### Current behavior (evidence)

- Hook commands are built as a **heredoc JSON** with embedded shell: `"command": "CODE_TO_DOCS_VAULT='$VAULT_PATH' bash '$DIGEST_HOOK'"` (`setup.sh` lines 37–67). Any **single quote or newline** in `VAULT_PATH` breaks the shell fragment inside JSON (**TH-001**).
- Merge path uses Python with `open('$PROJECT_SETTINGS')` — paths with quotes could break the `-c` string (`setup.sh` lines 73–76) `[CITED: repo file setup.sh]`.
- **D-04:** Compare resolved vault root to `git rev-parse --show-toplevel` (or `pwd` at install time); if outside, print **warning** but continue.
- **D-05:** Before writing HOOKS_TMPFILE, run validation: reject empty, reject characters in class `['"`'`'\n\r\t\$\`\;\|\&\(\)\<\>\*?]` or use a stricter allowlist (portable absolute/relative POSIX path). On failure: exit 1, message with remediation (D-09).

### Recommended approach

1. **Validate first:** Normalize with `realpath`/`cd` where available; reject metacharacters (D-05).
2. **Generate JSON safely:** Build the hooks object in Python (`json.dumps`) from structured fields (`vault_path`, `digest_hook`, `update_hook`) instead of heredoc concatenation — guarantees valid JSON and proper escaping of command strings `[VERIFIED: pattern aligns with existing Python merge in setup.sh]`.
3. **Optional hardening:** If escaping remains fragile, write validated vault path to a repo-local file (e.g. `.claude/code-to-docs-vault-path`) and use a **fixed** hook command that reads that file — minimizes attacker-controlled bytes inside `settings.json` (defense-in-depth for TH-001).

## Focus Area (3) — Pre-Commit Guard Design for This Repo Layout

### Evidence from `.gitignore`

Ignored local/sensitive areas include **`docs-vault/`**, **`research/`**, **`docs/`**, **`scripts/`**, **`tests/`**, **`.claude-plugin/`**, `.firecrawl/`, `.superpowers/`, `CLAUDE.md` (`.gitignore` lines 18–26). **Note:** Ignoring entire `scripts/` is unusual for shipping automation; the guard still matters for **`git add -f`** and future `.gitignore` changes.

### Recommended approach

1. **Blocked paths (baseline):** Stage/block commits touching `docs-vault/**`, `**/docs-vault/**`, common state filenames (`**/_state/analysis.json`), plus patterns called out in `DATA-FLOWS.md` C1/C2 (e.g. vault state under operator-chosen `CODE_TO_DOCS_VAULT`).
2. **Mechanism:** Executable `scripts/pre-commit-guard.sh` invoked from `.git/hooks/pre-commit` or `git config core.hooksPath`; enumerate `git diff --cached --name-only` and fail with one-line fix (“unstage X or use GUARD bypass documented for maintainers” — only if explicitly allowed by policy).
3. **Alignment:** Mirror `.gitignore` intent (D-07); document discrepancy if `.gitignore` ignores `scripts/` but repo tracks `scripts/bump.sh` — resolve in implementation so guards don’t contradict tracked layout `[EVIDENCE: .gitignore lists scripts/]`.

## Focus Area (4) — Minimal Stdout Sanitization (Phase 2) vs Phase 3

| Topic | Phase 2 (D-10, minimal) | Phase 3 (R-003) |
|-------|-------------------------|-----------------|
| Hook reminders | Keep messages generic; avoid echoing full filesystem paths in **error** paths (D-09); optional basename-only for vault in warnings | Systematic redaction of tokens, payloads, transcripts |
| `digest-on-start.sh` | Avoid dumping raw JSON; current Python extract is summary-only (`digest-on-start.sh` lines 18–29) — keep; fix **short hash** only if Phase 2 tasks include **R-007**/`TH-006` | Regex/token scrubbing for logs |
| `update-hint-on-commit.sh` | Static message already (`update-hint-on-commit.sh` line 22) — no change required for content | Paranoid parsing of stdin JSON if payloads grow |

**Defer:** Rich redaction library, “no sensitive fragments in stdout” verification harness — **R-003** targets Phase 3 (`RISK-REGISTER.md` row R-003).

## Common Pitfalls

| Pitfall | Evidence / cause | Mitigation |
|---------|------------------|------------|
| Silent failed `git push` | `bump.sh` line 91 | Remove `2>/dev/null || true` for publish lane or surface exit code. |
| Quote injection in hook command | `setup.sh` embeds `$VAULT_PATH` in single-quoted shell | Validation (D-05) + `json.dumps` command construction. |
| Guard bypass via `-f` | Git allows force-add | Document + optional `core.hooksPath` CI check later (Phase 4). |

## Validation Architecture

`.planning/config.json` has no `workflow.nyquist_validation` key — treat validation as **manual/review** unless added later.

| Property | Value |
|----------|-------|
| Framework | None detected — `[EVIDENCE: glob *test* yields .planning/codebase/TESTING.md only]` |
| Quick check | Run hook scripts with fixture vault path + `bash -n` on edited scripts |
| Phase gate | ROADMAP Phase 2 verification bullets + manual attempt to violate policy |

## Security Domain (ASVS-oriented)

| ASVS area | Applies | Phase 2 control |
|-----------|---------|-----------------|
| V5 Input Validation | Yes | Vault path validation (D-05); staged path checks in pre-commit guard. |
| V9 Communications | Yes (publish lane) | Explicit publish gate for `git`/`gh` (D-03). |
| V13 Config integrity | Yes | Safe JSON generation for `.claude/settings.json` (TH-001). |

## Assumptions Log

| ID | Claim | Risk if wrong |
|----|-------|----------------|
| A1 | Bash/Python versions adequate for `json` and `realpath` | Setup fails on exotic environments; add checks. |
| A2 | Maintainers are sole users of `bump.sh` | Wrong if CI calls bump — document CI prohibition until gated. |

## Open Questions

1. **`.gitignore` vs tracked `scripts/`:** `.gitignore` lists `scripts/` but `scripts/bump.sh` is in-repo — confirm intended tracking model so the pre-commit guard and docs don’t conflict.
2. **Allowlist enforcement mechanism:** Doc-only vs wrapper that refuses unknown network scripts — discretion per CONTEXT.

## Sources

### Primary (repo-evidence)

- `.planning/phases/02-local-only-guardrails-implementation/02-CONTEXT.md` — D-01–D-10.
- `.planning/phases/1/RISK-REGISTER.md`, `THREAT-MODEL.md`, `DATA-FLOWS.md`.
- `.planning/REQUIREMENTS.md` — FR-1, FR-2, FR-4, NFR-1–3.
- `scripts/bump.sh`, `skills/code-to-docs-hooks/hooks/setup.sh`, `digest-on-start.sh`, `update-hint-on-commit.sh`, `teardown.sh`, `.gitignore`.

### Project Constraints (`.cursor/rules/`)

None — directory empty / absent `[VERIFIED: glob .cursor/rules]`.

## Metadata

**Valid until:** ~30 days or after major hook/settings schema change.
