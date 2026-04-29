# Coding Conventions

**Analysis Date:** 2026-04-29

## Naming Patterns

**Files:**
- Skill definitions use uppercase `SKILL.md` in per-skill directories, e.g. `skills/code-to-docs/SKILL.md`.
- Reference docs use kebab-case markdown names, e.g. `skills/code-to-docs-references/analysis-guide.md`.
- Hook scripts use kebab-case shell names ending in `.sh`, e.g. `skills/code-to-docs-hooks/hooks/update-hint-on-commit.sh`.

**Functions:**
- Shell functions are mostly implicit command blocks rather than named Bash functions in `skills/code-to-docs-hooks/hooks/*.sh`.
- Python snippets embedded in shell scripts use snake_case variables, e.g. `existing_sources` in `skills/code-to-docs-hooks/hooks/setup.sh`.

**Variables:**
- Shell variables are uppercase snake_case for config/path values, e.g. `VAULT_PATH`, `STATE_FILE`, `PROJECT_SETTINGS` in `skills/code-to-docs-hooks/hooks/*.sh`.
- Temporary and derived values follow descriptive uppercase names in shell and snake_case in inline Python.

**Types:**
- No TypeScript/Python type declarations are present in repository source files.
- Generated-document schemas are expressed as markdown/json/yaml examples in `skills/code-to-docs-references/obsidian-templates.md` and `skills/code-to-docs-references/output-structure.md`.

## Code Style

**Formatting:**
- Markdown-first repository; style relies on consistent heading hierarchy, tables, and fenced blocks across `README.md` and `skills/**/*.md`.
- Shell scripts use strict mode (`set -euo pipefail`) consistently in `skills/code-to-docs-hooks/hooks/*.sh`.
- Key settings observed:
  - Defensive shell execution with strict flags.
  - Shebang `#!/usr/bin/env bash` for portability.
  - Clear top-of-file usage comments before implementation.

**Linting:**
- No lint configuration detected (`eslint`, `prettier`, `biome`, `shellcheck`, `markdownlint` configs not found).
- Practical enforcement appears documentation-driven through explicit rules in `skills/code-to-docs-references/analysis-guide.md`.

## Import Organization

**Order:**
1. Shell scripts avoid imports; they rely on standard CLI tools (`bash`, `python3`, `git`, `mktemp`, `chmod`) in `skills/code-to-docs-hooks/hooks/*.sh`.
2. Embedded Python snippets import standard library modules first (`json`, optionally `sys`) in `skills/code-to-docs-hooks/hooks/setup.sh` and `skills/code-to-docs-hooks/hooks/teardown.sh`.
3. External SDK imports are not used in repository code.

**Path Aliases:**
- Not applicable (no TS/JS module system in the repository implementation files).

## Error Handling

**Patterns:**
- Fail-fast script behavior via `set -euo pipefail` across all hook scripts.
- Guard clauses for missing prerequisites with explicit messages and early exits:
  - Missing hook file check in `skills/code-to-docs-hooks/hooks/setup.sh`.
  - Missing vault/state file check in `skills/code-to-docs-hooks/hooks/digest-on-start.sh` and `skills/code-to-docs-hooks/hooks/update-hint-on-commit.sh`.
  - Missing settings file handling in `skills/code-to-docs-hooks/hooks/teardown.sh`.
- Use of fallback values for non-critical parsing failures (e.g., default tuple in `skills/code-to-docs-hooks/hooks/digest-on-start.sh`).

## Logging

**Framework:** `echo`/stdout in shell scripts.

**Patterns:**
- User-facing status lines are concise and action-oriented (install summary, next-step hints) in `skills/code-to-docs-hooks/hooks/setup.sh`.
- Hook scripts print contextual reminders intended for agent context injection (not persistent logs), e.g. `skills/code-to-docs-hooks/hooks/update-hint-on-commit.sh`.

## Comments

**When to Comment:**
- Top-of-file comment headers explain purpose, usage, and safety expectations in each hook script.
- Inline comments mark non-obvious behavior (JSON merge semantics, temp-file cleanup, staleness checks) in `skills/code-to-docs-hooks/hooks/setup.sh` and `skills/code-to-docs-hooks/hooks/digest-on-start.sh`.

**JSDoc/TSDoc:**
- Not applicable (no JS/TS source files in repo).

## Function Design

**Size:** 
- Scripts are kept medium length with linear flow and sectioned blocks rather than deep abstraction, e.g. `skills/code-to-docs-hooks/hooks/setup.sh`.

**Parameters:** 
- CLI argument positionals with defaults are preferred (`${1:-./docs-vault}`), plus optional env override (`CODE_TO_DOCS_VAULT`) in hook scripts.

**Return Values:** 
- Exit codes and stdout messages are the primary contract; JSON mutations are delegated to inline Python subprocesses.

## Module Design

**Exports:**
- Repository is organized as skill modules (`skills/code-to-docs*`) and supporting references instead of runtime package exports.
- Contracts are specified in markdown sections (Invocation, Execution, Red Flags) in each `SKILL.md`.

**Barrel Files:**
- Not used.

---

*Convention analysis: 2026-04-29*
