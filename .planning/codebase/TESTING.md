# Testing Patterns

**Analysis Date:** 2026-04-29

## Test Framework

**Runner:**
- No executable automated test runner config detected (`jest`, `vitest`, `pytest`, `go test` configs absent at repo root).
- Config: Not detected.

**Assertion Library:**
- Not detected for executable tests.

**Run Commands:**
```bash
# Not detected: no repository-level automated test command configured
# Primary validation artifacts are manual checklists in tests/*.md
```

## Test File Organization

**Location:**
- Test strategy is documented as markdown pressure-test specs under `tests/`.
- Current files:
  - `tests/pressure-test-quick-mode.md`
  - `tests/pressure-test-full-mode.md`
  - `tests/pressure-test-parallel.md`

**Naming:**
- Kebab-case markdown scenario names prefixed by `pressure-test-`.

**Structure:**
```
tests/
├── pressure-test-quick-mode.md
├── pressure-test-full-mode.md
└── pressure-test-parallel.md
```

## Test Structure

**Suite Organization:**
```markdown
## Objective
## Scenario / Invocation
## Expected Behavior
## Validation Checklist
## Success Criteria / Exit Criteria
```

**Patterns:**
- Setup pattern: define target codebase constraints and prerequisites before execution (`tests/pressure-test-quick-mode.md`).
- Verification pattern: phase-based checklists (Phase 1/2/3/4/5) with pass/fail gates (`tests/pressure-test-quick-mode.md`, `tests/pressure-test-full-mode.md`).
- Assertion pattern: explicit checkbox criteria and failure conditions rather than executable assertions.

## Mocking

**Framework:** Not used.

**Patterns:**
```markdown
# No runtime mocking layer detected.
# Validation is scenario-driven and references expected behavior contractually.
```

**What to Mock:**
- Not applicable in current repository state.

**What NOT to Mock:**
- Not applicable in current repository state.

## Fixtures and Factories

**Test Data:**
```markdown
### Candidate Codebases
1. NanoClaw ...
2. Dockhand ...
3. Trayce ...
4. Scriptbox ...
```

**Location:**
- Embedded inside scenario docs as structured test fixtures and synthetic/hypothetical module layouts:
  - Candidate fixtures in `tests/pressure-test-quick-mode.md`
  - Hypothetical analytics fixture in `tests/pressure-test-parallel.md`

## Coverage

**Requirements:** 
- No numeric coverage threshold enforced by tooling.
- Coverage intent exists as checklist breadth across architecture, generation, verification, and discipline constraints in `tests/pressure-test-*.md`.

**View Coverage:**
```bash
# Not available via automated tooling in this repository
```

## Test Types

**Unit Tests:**
- Not implemented as executable unit test files.

**Integration Tests:**
- Manual integration-style pressure scenarios are documented (invocation + expected outputs + artifact checks) in `tests/pressure-test-quick-mode.md` and `tests/pressure-test-full-mode.md`.

**E2E Tests:**
- Semi-E2E manual workflow checks exist as full lifecycle checklists (survey -> generation -> verification) in `tests/pressure-test-quick-mode.md`.

## Common Patterns

**Async Testing:**
```markdown
- [ ] All 5 agent calls issued in single message (parallel)
- [ ] Wait for all agent completions before synthesis
```

**Error Testing:**
```markdown
### Critical Violations
- Sequential dispatch instead of parallel
- Reading large files without grep-first discipline
- Synthesis skipped or incomplete
```

## Known Testing Gaps

- No CI-wired automated execution of pressure tests from repository scripts or manifests.
- No executable regression tests for hook scripts in `skills/code-to-docs-hooks/hooks/*.sh`.
- No static checks for shell scripts (`shellcheck`) configured.
- `tests/` is listed in `.gitignore`, which can reduce shared reproducibility unless test docs are intentionally tracked by other means.

## Actionable Testing Guidance

- Treat `tests/pressure-test-*.md` as authoritative acceptance criteria when modifying skill behavior.
- Add an executable smoke suite for hook scripts (`setup.sh`, `teardown.sh`, `digest-on-start.sh`, `update-hint-on-commit.sh`) using temporary fixture directories.
- Add a lightweight CI step to validate markdown and shell syntax consistency so checklist drift is caught early.
- Keep manual scenario docs aligned with invocation contracts in:
  - `skills/code-to-docs/SKILL.md`
  - `skills/code-to-docs-update/SKILL.md`
  - `skills/code-to-docs-digest/SKILL.md`

---

*Testing analysis: 2026-04-29*
