# Codebase Structure

**Analysis Date:** 2026-04-29

## Directory Layout

```text
code-to-docs-skill/
├── skills/                 # Core skill contracts, references, and hook scripts
├── assets/                 # Repository images/diagrams used in docs
├── examples/               # Example generated output vaults
├── scripts/                # Project utility scripts
├── tests/                  # Pressure-test scenarios and validation fixtures
├── README.md               # User-facing architecture, usage, and lifecycle
├── CHANGELOG.md            # Release and behavior history
└── .planning/codebase/     # Codebase mapping outputs for GSD planning/execution
```

## Directory Purposes

**`skills/`:**
- Purpose: Primary product surface; defines behavior of code-to-docs commands.
- Contains: Command skill manifests, reusable references, hook automation scripts.
- Key files: `skills/code-to-docs/SKILL.md`, `skills/code-to-docs-update/SKILL.md`, `skills/code-to-docs-digest/SKILL.md`, `skills/code-to-docs-hooks/SKILL.md`

**`skills/code-to-docs-references/`:**
- Purpose: Single source of truth for analysis method, output schema, and markdown conventions.
- Contains: Reference markdown files used by all lifecycle skills.
- Key files: `skills/code-to-docs-references/analysis-guide.md`, `skills/code-to-docs-references/output-structure.md`, `skills/code-to-docs-references/obsidian-templates.md`

**`skills/code-to-docs-hooks/hooks/`:**
- Purpose: Runtime automation entrypoints for session start and commit events.
- Contains: Bash scripts for setup, teardown, and event-time execution.
- Key files: `skills/code-to-docs-hooks/hooks/setup.sh`, `skills/code-to-docs-hooks/hooks/teardown.sh`, `skills/code-to-docs-hooks/hooks/digest-on-start.sh`, `skills/code-to-docs-hooks/hooks/update-hint-on-commit.sh`

**`assets/`:**
- Purpose: Static visuals for repository docs.
- Contains: SVG diagrams.
- Key files: `assets/code-to-docs-architecture.svg`, `assets/code-to-docs-health-pie.svg`, `assets/code-to-docs-dep-tree.svg`

**`tests/`:**
- Purpose: Scenario-driven validation docs for quick/full/parallel behavior.
- Contains: Markdown pressure test definitions.
- Key files: `tests/pressure-test-quick-mode.md`, `tests/pressure-test-full-mode.md`, `tests/pressure-test-parallel.md`

## Key File Locations

**Entry Points:**
- `skills/code-to-docs/SKILL.md`: Main generation command contract.
- `skills/code-to-docs-update/SKILL.md`: Incremental update contract.
- `skills/code-to-docs-digest/SKILL.md`: Read-only context loading contract.
- `skills/code-to-docs-hooks/SKILL.md`: Hook install/remove contract.

**Configuration:**
- `.gitignore`: Repository-level local/ignored artifacts policy.
- `skills/code-to-docs-references/output-structure.md`: Contract for generated vault state/config.
- `skills/code-to-docs-hooks/hooks/setup.sh`: Project hook configuration writer targeting `.claude/settings.json`.

**Core Logic:**
- `skills/code-to-docs-references/analysis-guide.md`: Analysis and synthesis control flow.
- `skills/code-to-docs-references/obsidian-templates.md`: Required output rendering conventions.
- `skills/code-to-docs-hooks/hooks/*.sh`: Executable side-effect logic.

**Testing:**
- `tests/pressure-test-quick-mode.md`: Quick mode expectations.
- `tests/pressure-test-full-mode.md`: Full mode expectations.
- `tests/pressure-test-parallel.md`: Parallel dispatch expectations.

## Naming Conventions

**Files:**
- Skill manifests use fixed name `SKILL.md` per command directory (example: `skills/code-to-docs/SKILL.md`).
- Reference docs use kebab-case descriptive markdown names (example: `skills/code-to-docs-references/analysis-guide.md`).
- Hook scripts use kebab-case verb phrases (example: `skills/code-to-docs-hooks/hooks/update-hint-on-commit.sh`).

**Directories:**
- Command directories use command-aligned slugs (`skills/code-to-docs-update/`, `skills/code-to-docs-digest/`).
- Nested `hooks/` under `skills/code-to-docs-hooks/` isolates executable scripts from spec docs.

## Where to Add New Code

**New Feature:**
- Primary code: Add new command contract under `skills/<new-command>/SKILL.md` or extend relevant existing `skills/code-to-docs*/SKILL.md`.
- Tests: Add scenario docs under `tests/` following `pressure-test-*.md` naming.

**New Component/Module:**
- Implementation: Put shared policy/spec additions in `skills/code-to-docs-references/`; put command behavior wiring in the relevant `skills/code-to-docs*/SKILL.md`.

**Utilities:**
- Shared helpers: Add shell helpers under `skills/code-to-docs-hooks/hooks/` only when behavior is event-driven or automation-oriented.

## Special Directories

**`.planning/codebase/`:**
- Purpose: Generated architecture/quality/stack maps for downstream GSD commands.
- Generated: Yes.
- Committed: Yes.

**`.claude-plugin/`:**
- Purpose: Plugin metadata/runtime packaging support.
- Generated: No.
- Committed: Yes.

**`examples/`:**
- Purpose: Human-consumable sample vaults and expected output style references.
- Generated: No (checked-in artifacts).
- Committed: Yes.

---

*Structure analysis: 2026-04-29*
