<!-- refreshed: 2026-04-29 -->
# Architecture

**Analysis Date:** 2026-04-29

## System Overview

```text
┌─────────────────────────────────────────────────────────────┐
│                  Skill Entry Layer                           │
├──────────────────┬──────────────────┬───────────────────────┤
│ Generate Skill   │ Update Skill     │ Digest/Hooks Skills   │
│ `skills/code-to- │ `skills/code-to- │ `skills/code-to-docs- │
│ docs/SKILL.md`   │ docs-update/`    │ digest/`,`-hooks/`    │
└────────┬─────────┴────────┬─────────┴──────────┬────────────┘
         │                  │                     │
         ▼                  ▼                     ▼
┌─────────────────────────────────────────────────────────────┐
│                 Shared Reference Layer                       │
│ `skills/code-to-docs-references/`                            │
└─────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│             Runtime Integration / Side Effects               │
│ `.claude/settings.json`, `docs-vault/_state/analysis.json`  │
│ via `skills/code-to-docs-hooks/hooks/*.sh`                  │
└─────────────────────────────────────────────────────────────┘
```

## Component Responsibilities

| Component | Responsibility | File |
|-----------|----------------|------|
| Generate orchestrator contract | Defines full quick/full documentation workflow and model-tier dispatch rules | `skills/code-to-docs/SKILL.md` |
| Incremental update contract | Defines diff-driven re-analysis and merge behavior for changed modules only | `skills/code-to-docs-update/SKILL.md` |
| Digest context loader | Defines read-only preload behavior from prior generated vault state | `skills/code-to-docs-digest/SKILL.md` |
| Hook installer/remover | Installs and removes project-local SessionStart and PostToolUse hooks | `skills/code-to-docs-hooks/SKILL.md` |
| Shared execution specs | Provides canonical templates for analysis, output schema, and Obsidian formatting | `skills/code-to-docs-references/analysis-guide.md`, `skills/code-to-docs-references/output-structure.md`, `skills/code-to-docs-references/obsidian-templates.md` |

## Pattern Overview

**Overall:** Documentation-as-code skill-pack architecture

**Key Characteristics:**
- Declarative orchestration lives in markdown skill contracts, not application code.
- Shared policy is centralized in reference docs and reused by multiple skill entrypoints.
- Operational behavior is split into pure guidance (`SKILL.md`) and executable shell hooks (`hooks/*.sh`).

## Layers

**Skill Contract Layer:**
- Purpose: Defines command semantics, guardrails, and phase sequencing.
- Location: `skills/code-to-docs/`, `skills/code-to-docs-update/`, `skills/code-to-docs-digest/`, `skills/code-to-docs-hooks/`
- Contains: `SKILL.md` control documents.
- Depends on: Shared references in `skills/code-to-docs-references/`.
- Used by: Claude/Cursor skill invocations (`code-to-docs`, `code-to-docs:update`, `code-to-docs:digest`, `code-to-docs:hooks`).

**Reference Specification Layer:**
- Purpose: Canonical schema and template source of truth.
- Location: `skills/code-to-docs-references/`
- Contains: Analysis, output, and formatting contracts.
- Depends on: None in-repo.
- Used by: All skill contracts in `skills/code-to-docs*/SKILL.md`.

**Automation Hook Layer:**
- Purpose: Injects session context and commit-time reminders with minimal coupling.
- Location: `skills/code-to-docs-hooks/hooks/`
- Contains: Bash scripts for setup/teardown and runtime hook actions.
- Depends on: Project `.claude/settings.json`, generated vault `_state/analysis.json`, local `git`.
- Used by: `code-to-docs:hooks` setup/teardown flow.

## Data Flow

### Primary Request Path

1. Skill invocation enters through the matching contract (`skills/code-to-docs/SKILL.md`, `skills/code-to-docs-update/SKILL.md`, or `skills/code-to-docs-digest/SKILL.md`).
2. Contracted execution pulls authoritative rules/templates from `skills/code-to-docs-references/analysis-guide.md`, `skills/code-to-docs-references/output-structure.md`, and `skills/code-to-docs-references/obsidian-templates.md`.
3. Output target is generated documentation plus state in `docs-vault/` (especially `docs-vault/_state/analysis.json` as update/digest contract anchor).

### Hook Automation Flow

1. `skills/code-to-docs-hooks/hooks/setup.sh` merges code-to-docs hook definitions into `.claude/settings.json`.
2. `skills/code-to-docs-hooks/hooks/digest-on-start.sh` reads `docs-vault/_state/analysis.json` and injects summary context at session start.
3. `skills/code-to-docs-hooks/hooks/update-hint-on-commit.sh` inspects PostToolUse payload and emits update reminder after `git commit`.

**State Management:**
- Persistent cross-run state is the JSON contract in `docs-vault/_state/analysis.json` as defined in `skills/code-to-docs-references/output-structure.md`.
- Hook configuration state is persisted in project-local `.claude/settings.json`.

## Key Abstractions

**Skill as protocol contract:**
- Purpose: Treat each `SKILL.md` as an executable spec with invocation syntax, model policy, and red flags.
- Examples: `skills/code-to-docs/SKILL.md`, `skills/code-to-docs-update/SKILL.md`, `skills/code-to-docs-digest/SKILL.md`
- Pattern: Command protocol docs drive behavior; scripts handle only narrow side effects.

**Incremental contract state:**
- Purpose: Enable deterministic update/digest workflows from previous analysis snapshots.
- Examples: Schema in `skills/code-to-docs-references/output-structure.md`; runtime read in `skills/code-to-docs-hooks/hooks/digest-on-start.sh`
- Pattern: Single state file mediates generate → digest → update lifecycle.

## Entry Points

**Generate entrypoint:**
- Location: `skills/code-to-docs/SKILL.md`
- Triggers: `Skill(skill: "code-to-docs", args: ...)`
- Responsibilities: Full analysis/generation flow selection (`quick`/`full`) and dispatch policy.

**Update entrypoint:**
- Location: `skills/code-to-docs-update/SKILL.md`
- Triggers: `Skill(skill: "code-to-docs:update", args: ...)`
- Responsibilities: Validate prior state, diff by git commit, selectively regenerate.

**Digest entrypoint:**
- Location: `skills/code-to-docs-digest/SKILL.md`
- Triggers: `Skill(skill: "code-to-docs:digest", args: ...)`
- Responsibilities: Read-only context hydration for coding sessions.

**Hooks entrypoint:**
- Location: `skills/code-to-docs-hooks/SKILL.md`
- Triggers: `Skill(skill: "code-to-docs:hooks", args: "setup|teardown ...")`
- Responsibilities: Install/remove automation scripts without clobbering unrelated hooks.

## Architectural Constraints

- **Threading:** Single-process shell/Python hook execution; no in-repo concurrency primitives.
- **Global state:** Shared mutable state is externalized to `.claude/settings.json` and `docs-vault/_state/analysis.json`.
- **Circular imports:** Not applicable; architecture is file-contract driven, not code-module import graph.
- **Environment assumptions:** Hook scripts require `bash` + `python3` + readable git metadata in project context.

## Anti-Patterns

### Duplicating reference contracts in skill files

**What happens:** New behavior is described directly in one `SKILL.md` but not propagated to shared references.
**Why it's wrong:** Generate/update/digest can drift and produce incompatible output semantics.
**Do this instead:** Centralize canonical rules in `skills/code-to-docs-references/*.md` and keep entry skills as delegating contracts.

### Treating hooks as primary orchestration surface

**What happens:** Workflow logic is moved into hook scripts rather than staying in skill contracts.
**Why it's wrong:** Hooks are event-specific and intentionally narrow; broad logic there becomes fragile and hard to audit.
**Do this instead:** Keep orchestration in `skills/code-to-docs*/SKILL.md`; keep `skills/code-to-docs-hooks/hooks/*.sh` minimal and side-effect focused.

## Error Handling

**Strategy:** Guard-and-fallback for missing state/config, plus non-destructive merge/remove semantics.

**Patterns:**
- Validate file existence and abort gracefully (`skills/code-to-docs-hooks/hooks/digest-on-start.sh`, `.../teardown.sh`).
- Prefer fallback behavior over hard failure where possible (update contract in `skills/code-to-docs-update/SKILL.md`).

## Cross-Cutting Concerns

**Logging:** Hook scripts emit user-facing status messages via stdout (`skills/code-to-docs-hooks/hooks/*.sh`).
**Validation:** State-schema and required-field validation are specified in `skills/code-to-docs-references/output-structure.md`.
**Authentication:** Not detected; repository is local-skill and local-hook oriented.

---

*Architecture analysis: 2026-04-29*
