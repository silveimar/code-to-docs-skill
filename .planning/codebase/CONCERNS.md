# Codebase Concerns

**Analysis Date:** Wednesday Apr 29, 2026

## Tech Debt

**P0 - High severity / Medium likelihood - Shell command injection surface in hook setup:**
- Issue: `setup.sh` interpolates user-provided `VAULT_PATH` into JSON command strings wrapped in single quotes, which can break quoting or allow command injection-like behavior if the path contains `'`.
- Files: `skills/code-to-docs-hooks/hooks/setup.sh`
- Impact: Project `.claude/settings.json` can be generated with malformed commands; in worst case, unsafe command fragments could be persisted and later executed by hooks.
- Fix approach: Validate/escape `VAULT_PATH` before interpolation (reject unsafe chars or use robust JSON-safe escaping via Python and avoid shell-quoted concatenation).

**P1 - Medium severity / High likelihood - Documentation/process drift across multiple authoritative files:**
- Issue: operational rules are duplicated across `README.md`, `skills/code-to-docs/SKILL.md`, and `skills/code-to-docs-references/*`, creating multiple sources of truth.
- Files: `README.md`, `skills/code-to-docs/SKILL.md`, `skills/code-to-docs-update/SKILL.md`, `skills/code-to-docs-references/analysis-guide.md`, `skills/code-to-docs-references/output-structure.md`
- Impact: Behavior mismatches and stale instructions are likely as the skill evolves.
- Fix approach: Define one canonical spec file and make other docs thin references; add a docs consistency check in CI.

## Known Bugs

**Commit hash truncation can make stale-check diff ambiguous (Medium severity / Medium likelihood):**
- Symptoms: Session-start stale check may compute diff from an abbreviated commit hash (`[:8]`) rather than the full hash.
- Files: `skills/code-to-docs-hooks/hooks/digest-on-start.sh`
- Trigger: Repos with ambiguous short hashes or rewritten histories.
- Workaround: Store/use full commit hash end-to-end for `git diff`.

## Security Considerations

**Hook execution trust boundary is broad (High severity / Medium likelihood):**
- Risk: Hook setup installs commands into `.claude/settings.json` that run automatically on session/tool events.
- Files: `skills/code-to-docs-hooks/hooks/setup.sh`, `skills/code-to-docs-hooks/hooks/digest-on-start.sh`, `skills/code-to-docs-hooks/hooks/update-hint-on-commit.sh`
- Current mitigation: `set -euo pipefail`, explicit `source` tagging for teardown.
- Recommendations: Add strict input sanitization for `VAULT_PATH`, pin allowed vault path patterns, and add hook integrity validation before overwrite/merge.

## Performance Bottlenecks

**SessionStart can add avoidable startup latency on large repos (Low severity / Medium likelihood):**
- Problem: Hook runs Python JSON parse and may run `git diff --stat` every session when doc commit differs.
- Files: `skills/code-to-docs-hooks/hooks/digest-on-start.sh`
- Cause: Synchronous shell + git operations on startup path.
- Improvement path: Skip `git diff --stat` behind a size threshold; cache previous stale-check result per HEAD.

## Fragile Areas

**JSON merge logic in hook setup is brittle to schema drift (Medium severity / Medium likelihood):**
- Files: `skills/code-to-docs-hooks/hooks/setup.sh`, `skills/code-to-docs-hooks/hooks/teardown.sh`
- Why fragile: Ad-hoc Python inline merges rely on current `.claude/settings.json` shape and event array format.
- Safe modification: Centralize merge/remove logic in one tested script/module and validate resulting JSON schema after write.
- Test coverage: No executable tests detected in repository (`tests/` is ignored in `.gitignore` and not present).

## Scaling Limits

**No automated validation pipeline for shell scripts/docs (Medium severity / High likelihood):**
- Current capacity: Manual verification only.
- Limit: Change volume increases risk of silent breakage in hooks and reference docs.
- Scaling path: Add CI (e.g., ShellCheck + smoke tests for setup/teardown + markdown link checks).

## Dependencies at Risk

**Runtime dependencies are implicit platform tools (Low severity / Medium likelihood):**
- Risk: Scripts assume availability/behavior of `python3`, `git`, and shell features without version checks.
- Impact: Hook setup/runtime failures on constrained environments.
- Migration plan: Add preflight checks and user-facing actionable errors with minimum versions.

## Missing Critical Features

**Missing automated test suite for hook behavior and state parsing (High severity / High likelihood):**
- Problem: No regression harness for command generation, settings merge behavior, or stale-check logic.
- Blocks: Safe refactors of hook scripts and confidence in cross-platform behavior.

**Missing CI gate for docs/spec consistency (Medium severity / High likelihood):**
- Problem: High-risk documentation duplication is not checked automatically.
- Blocks: Reliable evolution of skill contracts.

## Test Coverage Gaps

**Hook scripts are untested (High priority):**
- What's not tested: Setup idempotence, teardown safety, malformed `settings.json`, path quoting edge cases.
- Files: `skills/code-to-docs-hooks/hooks/setup.sh`, `skills/code-to-docs-hooks/hooks/teardown.sh`
- Risk: Corrupt project settings or silently broken automation.
- Priority: High

**SessionStart/PostToolUse behavior is untested (Medium priority):**
- What's not tested: Stale-check correctness, commit hash handling, command detection logic from hook JSON input.
- Files: `skills/code-to-docs-hooks/hooks/digest-on-start.sh`, `skills/code-to-docs-hooks/hooks/update-hint-on-commit.sh`
- Risk: False stale warnings or missed update reminders degrade trust in workflow.
- Priority: Medium

---

*Concerns audit: Wednesday Apr 29, 2026*
