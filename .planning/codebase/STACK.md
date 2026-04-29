# Technology Stack

**Analysis Date:** 2026-04-29

## Languages

**Primary:**
- Markdown - Core product and implementation instructions in `README.md` and `skills/**/SKILL.md`
- Bash - Operational automation in `skills/code-to-docs-hooks/hooks/*.sh` and `scripts/bump.sh`

**Secondary:**
- Python 3 (inline) - JSON/state transformations embedded in shell scripts such as `skills/code-to-docs-hooks/hooks/setup.sh` and `skills/code-to-docs-hooks/hooks/digest-on-start.sh`
- JSON - Plugin metadata and settings contracts in `.claude-plugin/marketplace.json` and `.claude/settings.json` (managed by hook scripts)

## Runtime

**Environment:**
- POSIX shell runtime via `bash` (`#!/usr/bin/env bash` in `skills/code-to-docs-hooks/hooks/*.sh`)
- Python 3 required for script-side JSON manipulation (`python3 -c` usage in hook scripts)

**Package Manager:**
- Not detected (no `package.json`, `pyproject.toml`, `Cargo.toml`, or lockfiles in repo root)
- Lockfile: missing

## Frameworks

**Core:**
- Claude Code Skill format - Defines behavior through `SKILL.md` contracts in `skills/code-to-docs/`, `skills/code-to-docs-update/`, `skills/code-to-docs-digest/`, and `skills/code-to-docs-hooks/`
- Claude plugin marketplace metadata - Plugin declaration in `.claude-plugin/marketplace.json`

**Testing:**
- Manual scenario docs (not an executable framework) - Pressure-test playbooks in `tests/pressure-test-quick-mode.md`, `tests/pressure-test-full-mode.md`, and `tests/pressure-test-parallel.md`

**Build/Dev:**
- Git CLI - Diff-based update flow described and referenced in `README.md` and `skills/code-to-docs-update/SKILL.md`
- GitHub CLI (`gh`) - Release automation in `scripts/bump.sh`
- Optional Obsidian CLI - Opportunistic note/property operations documented in `README.md` and `skills/code-to-docs-references/output-structure.md`

## Key Dependencies

**Critical:**
- `bash` - Executes all operational scripts in `skills/code-to-docs-hooks/hooks/*.sh` and `scripts/bump.sh`
- `python3` - Performs JSON parse/merge and state extraction in hook lifecycle scripts
- `git` - Required for incremental diff logic (`git diff`) and commit/tag workflows

**Infrastructure:**
- `gh` (GitHub CLI) - Publishes releases in `scripts/bump.sh`
- `obsidian` CLI (optional) - Enhances note creation/property handling when available per `README.md` and `skills/code-to-docs/SKILL.md`

## Configuration

**Environment:**
- Runtime override via `CODE_TO_DOCS_VAULT` in `skills/code-to-docs-hooks/hooks/digest-on-start.sh`, `update-hint-on-commit.sh`, and `setup.sh`
- Project hook wiring stored in `.claude/settings.json` (created/merged by `skills/code-to-docs-hooks/hooks/setup.sh`)

**Build:**
- Plugin catalog metadata in `.claude-plugin/marketplace.json`
- No compiler/transpiler build configuration detected

## Platform Requirements

**Development:**
- Unix-like shell environment with `bash`, `python3`, and `git`
- Optional: `gh` for release flow and `obsidian` for native vault operations

**Production:**
- Not applicable as a deployed service; delivery target is a distributable Claude skill/plugin repository (`.claude-plugin/marketplace.json`)

---

*Stack analysis: 2026-04-29*
