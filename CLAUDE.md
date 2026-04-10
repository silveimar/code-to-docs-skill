# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Claude Code plugin (`code-to-docs`) that analyzes codebases and generates Obsidian-native documentation vaults. It's a skill (prompt-based, not compiled code) — the "source" is markdown files that orchestrate Claude's behavior.

## Project Layout

- `.claude-plugin/plugin.json` — Plugin manifest (name, version, author)
- `skills/code-to-docs/SKILL.md` — Generate skill (quick/full mode, dispatch tables, red flags)
- `skills/update/SKILL.md` — Update skill (incremental doc updates after coding)
- `skills/digest/SKILL.md` — Digest skill (load vault context before coding, read-only)
- `skills/hooks/SKILL.md` — Hooks skill (install/remove project-level automation)
- `skills/hooks/hooks/` — Shell scripts for SessionStart/PostToolUse automation
- `skills/references/` — Shared reference files (analysis-guide, obsidian-templates, output-structure)
- `docs/superpowers/specs/` — Design specs that drove implementation decisions
- `docs/superpowers/plans/` — Implementation plan
- `tests/` — Pressure test scenarios (quick, full, parallel modes)
- `examples/dockhand/` — Complete example output vault (full mode)

## Development Commands

```bash
# Install/update local skills from repo
for dir in code-to-docs update digest hooks references; do
  mkdir -p ~/.claude/skills/$dir
  cp -r skills/$dir/* ~/.claude/skills/$dir/
done

# Version bump + GitHub release (interactive)
./scripts/bump.sh patch|minor|major|X.Y.Z

# Test the skill against a real codebase
/code-to-docs /path/to/codebase
/code-to-docs /path/to/codebase --mode full
/code-to-docs:update /path/to/codebase
/code-to-docs:digest ./docs-vault
```

## Architecture: How the Skill Works

The skill has no runtime code — it's a set of markdown files that instruct Claude how to behave. SKILL.md is the entry point; it references the other files as needed.

**Three-phase pipeline:**
1. **Analysis** (two-pass) — Haiku agents extract structure, then Sonnet/Opus agents find issues. Parallel per-module.
2. **Generation** — Parallel agents produce vault files (architecture, modules, health, index, canvas).
3. **Verification** — Haiku agent checks wikilinks resolve and frontmatter is complete.

**Three model tiers with dispatch tables:** Each phase has an explicit table mapping every agent call to Haiku/Sonnet/Opus. This is the cost-discipline mechanism — the orchestrator checks the table before dispatching. Haiku for extraction/mechanical work, Sonnet for narrative writing, Opus only for complex modules (>1000 LOC, concurrency, security) or large codebase synthesis (5+ modules).

**Four skills:** `code-to-docs` for generation (quick/full), `code-to-docs:update` (incremental via git diff), `code-to-docs:digest` (read-only context loading), `code-to-docs:hooks` (lifecycle automation).

## Key Design Decisions

- **Prompt engineering, not code** — changes happen in markdown skill files, not traditional source code. "Bugs" are usually unclear instructions that cause Claude to make wrong choices.
- **Dispatch tables are authoritative** — if a dispatch table says Haiku, the agent MUST use Haiku. This prevents the #1 cost mistake: running extraction at Opus prices.
- **Two-pass analysis** — Pass 1 (Haiku) extracts facts, Pass 2 (Sonnet/Opus) reasons about issues. Pass 2 receives Pass 1 output, never re-reads source files.
- **State file (`_state/analysis.json`)** tracks modules, deps, issues, git commit, and session history. This enables `code-to-docs:update` to diff against the last documented state.
- **Obsidian-native** — wikilinks (not markdown links), frontmatter properties, Mermaid inline, `.canvas` files, `.base` files. No external plugins required except optional Dataview.

## Editing Guidelines

- When modifying skill files, preserve dispatch table format exactly — they're parsed by the orchestrator logic in SKILL.md.
- The `examples/dockhand/` vault is reference output — update it when output format changes.
- Pressure tests in `tests/` define expected behaviors per mode — update them when adding features.
- Hook scripts use `source` field markers for safe install/uninstall — don't change the marker format.
