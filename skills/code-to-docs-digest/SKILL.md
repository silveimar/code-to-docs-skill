---
name: code-to-docs-digest
description: Use at the start of a coding session to load existing project documentation context from a code-to-docs vault, including architecture, module summaries, known issues, and dependency maps
---

## Overview

Load structured context from an existing code-to-docs vault into the current conversation. This skill reads — never writes — the vault, providing the AI agent with project architecture, module relationships, known issues, and relevant documentation before coding work begins.

Designed to be the first step in the code-to-docs lifecycle: **digest → code → update**.

## Invocation

```
Skill(skill: "code-to-docs-digest", args: "<vault-path> [--scope <module,...>] [--focus issues|architecture|all]")
```

- `<vault-path>` — path to the docs-vault directory (required)
- `--scope` — comma-separated module names to load in full (default: all modules, overview-only)
- `--focus` — what to emphasize: `issues` (health reports), `architecture` (system overview + deps), `all` (everything). Default: `architecture`

## What Gets Loaded

### Always loaded (lightweight baseline):

1. **`_state/analysis.json`** — module list, dependency graph, known issues, last run metadata
2. **`Architecture/System Overview.md`** — full content (architecture narrative + diagrams)

### Loaded based on `--focus`:

| Focus | Additional Content |
|-------|-------------------|
| `architecture` (default) | `Architecture/Dependency Map.md`, module Overview sections only (~20 lines each) |
| `issues` | `Health/Limitations.md`, `Health/Code Review.md`, module Code Review Notes from Advanced sections |
| `all` | Everything in `architecture` + `issues` + `Health/Health Summary.md` |

### Loaded based on `--scope`:

When `--scope` names specific modules, those module docs are loaded in full (all sections: Beginner through API Reference). Unscoped modules still get overview-only treatment.

**Example invocations:**

```
# Starting work on the auth system — load full auth docs + known issues
Skill(skill: "code-to-docs-digest", args: "./docs-vault --scope Auth,Database --focus issues")

# General session — just architecture context
Skill(skill: "code-to-docs-digest", args: "./docs-vault")

# Deep dive — load everything
Skill(skill: "code-to-docs-digest", args: "./docs-vault --focus all")
```

## Execution

**Model: Haiku** — this is a read-and-present task, no analysis or generation.

### Step 1: Validate vault

1. Check `<vault-path>` exists
2. Check `_state/analysis.json` exists — if missing, report "No code-to-docs vault found at this path. Run code-to-docs to generate one first."
3. Read `_state/analysis.json`

### Step 2: Load baseline context

1. Read `Architecture/System Overview.md` in full
2. Extract from state file: module list, dependency graph, last run timestamp, git commit

### Step 3: Load focus content

Based on `--focus` flag, read additional files per the table above. For module overviews (when not in `--scope`), read only the `# Module Name`, `## Overview`, and `## Architecture` sections — stop before `## Beginner`.

### Step 4: Load scoped modules

For each module named in `--scope`, read the full `Modules/{Name}.md`.

### Step 5: Present context

Output a structured summary to the conversation:

```
## Project Context: {project name}

**Last documented:** {timestamp} | **Commit:** {git_commit} | **Mode:** {mode}
**Modules:** {count} | **Known issues:** {open issue count}

### Architecture
{System Overview content}

### Module Map
{Dependency graph as inline list or Mermaid}

### Scoped Modules
{Full content of --scope modules, if any}

### Known Issues
{Issues from state file, grouped by severity}
{Health report content if --focus includes issues}

### Session Notes
{Any relevant context from sessions array — e.g., "Last update was 3 days ago, 2 modules changed"}
```

## Token Budget

The digest skill should stay under these targets:

| Scope | Target |
|-------|--------|
| Default (architecture only) | < 3,000 tokens output |
| With `--scope` (1-2 modules) | < 6,000 tokens output |
| With `--focus all` | < 10,000 tokens output |

If content exceeds these targets, truncate module docs to Overview + Architecture sections and note the truncation.

## Red Flags

1. Writing any files — this skill is read-only
2. Running code-to-docs generation — if the vault is stale, suggest an update, don't run one
3. Loading all module docs in full without `--scope` or `--focus all` — wasteful
4. Ignoring the state file — it's the cheapest source of project context

## Integration with code-to-docs Lifecycle

This skill reads what `code-to-docs` writes. The intended workflow:

```
Session start:  /code-to-docs-digest ./docs-vault --scope {modules you'll work on}
Coding work:    ... normal development ...
Session end:    /code-to-docs /path/to/codebase --update
```

The digest skill does not modify the vault or state file. It only reads. The update mode on code-to-docs handles the write side of the lifecycle.
