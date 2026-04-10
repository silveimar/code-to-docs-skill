# Changelog

All notable changes to the code-to-docs skill are documented in this file.

## 2026-04-10

### Added
- Marketplace discovery via `marketplace.json` for plugin system integration
- Separate skills for each lifecycle phase: `code-to-docs:digest`, `code-to-docs:update`, `code-to-docs:hooks`
- Colon-style skill invocations (`code-to-docs:update` instead of flags)

### Changed
- Split monolith SKILL.md into independent skill files per command
- Moved shared reference files (`analysis-guide`, `obsidian-templates`, `output-structure`) to `skills/references/`
- Updated hook scripts and reference files for colon-style invocations

### Fixed
- Hook scripts and reference paths updated for new skill layout

### Housekeeping
- Removed `CLAUDE.md` from git tracking (kept in `.gitignore`)
- Added `.firecrawl/`, `.superpowers/`, `tests/` to `.gitignore`

## 2026-03-30

### Added
- Dispatch tables for model tier cost discipline — explicit Haiku/Sonnet/Opus assignment per agent
- ApexCharts-rendered SVG diagrams in README

### Fixed
- `Documentation.base` template — use YAML with `and`/`or`/`not` filters
- PostToolUse update-hint hook never firing

## 2026-03-29

### Added
- Codebase health assessment output (Limitations, Code Review, Health Summary)
- Three-tier model strategy (Haiku for extraction, Sonnet for writing, Opus for reasoning)
- Development lifecycle: `digest` and `update` modes
- Optional project-level hook automation (SessionStart, PostToolUse)
- Obsidian Bases catalog (`.base` files) and opportunistic CLI integration
- Dockhand example vault demonstrating full mode output

### Fixed
- Hook default vault path to `./docs-vault`
- Path argument defaults to cwd instead of being required
- 6 code health issues identified by self-analysis

## 2026-03-28

### Added
- Initial release: code-to-docs Claude Code skill
- Two-pass analysis pipeline (extract then reason)
- Quick and full generation modes
- Obsidian-native output (wikilinks, Mermaid, frontmatter)
- Parallel agent dispatch for multi-module codebases
