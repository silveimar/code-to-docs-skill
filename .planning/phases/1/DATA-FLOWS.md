# Phase 1 Data Flows Baseline

## Scope and assumptions
- Scope is local-first repository workflows and explicit opt-in external release operations.
- Sensitive data classes are treated as protected by default in line with project requirements.

## Data classification legend
| Class | Description | Examples |
|---|---|---|
| C1 Sensitive source/content | Source code and analysis-derived content that may expose internals | Target repo files, generated docs in `docs-vault/` |
| C2 Operational metadata | Run metadata and diagnostics that can leak structure/history | `docs-vault/_state/analysis.json`, git diff stats, hook payload JSON |
| C3 Tool/runtime config | Local automation and settings state affecting execution integrity | `.claude/settings.json`, hook command payloads |
| C4 Release/export artifacts | Material intentionally published outside local boundary | Git tags/releases via `gh release create` |
| C5 Reference docs | In-repo guidance and planning artifacts | `skills/**/SKILL.md`, `.planning/**` |

## Flow inventory
| Flow ID | Data Class | Source | Processor | Storage | Trust Boundary | Potential Egress | Notes |
|---|---|---|---|---|---|---|---|
| DF-01 | C1 | Local operator invoking `code-to-docs` | Skill contract + agent runtime | Source repo + generated `docs-vault/` notes | User intent -> local tool runtime | None by default | Core baseline flow for analysis/generation (`README.md`, `skills/code-to-docs/SKILL.md`) |
| DF-02 | C2 | `docs-vault/_state/analysis.json` | `digest-on-start.sh` | Session stdout context injection | Local file store -> runtime hook output | Clipboard/screenshot/manual copy risk | Hook reads state and prints summary on session start (`skills/code-to-docs-hooks/hooks/digest-on-start.sh`) |
| DF-03 | C3 | Hook install invocation + vault path input | `setup.sh` inline Python JSON merge | `.claude/settings.json` | User-provided path -> executable hook config | Future hook command execution can amplify bad config | Broad trust boundary noted in concerns (`skills/code-to-docs-hooks/hooks/setup.sh`, `.planning/codebase/CONCERNS.md`) |
| DF-04 | C2 | Tool call payload after `git commit` | `update-hint-on-commit.sh` | Session stdout reminder | Tool event payload -> shell parser -> output | Accidental output disclosure in shared terminals/log capture | PostToolUse hook detects commit command and emits reminder (`skills/code-to-docs-hooks/hooks/update-hint-on-commit.sh`) |
| DF-05 | C2/C5 | Git tracked files + history | `code-to-docs:update` diff logic | Local git object DB + markdown outputs | Repo content -> analysis/update pipeline | None by default | Incremental update computes changed modules from git diff (`skills/code-to-docs-update/SKILL.md`) |
| DF-06 | C4 | Maintainer release intent | `scripts/bump.sh` + `gh` CLI | Local git tags + GitHub release assets | Local-only baseline -> external GitHub API | Explicit outbound path | Must remain explicit opt-in exception under FR-1/NFR-1 (`scripts/bump.sh`) |

## Trust-boundary map (textual)
1. **TB-1 User/operator -> local agent runtime:** Entry of prompts/commands that determine what repository content is read and transformed (DF-01, DF-03).
2. **TB-2 Local filesystem -> executable hooks:** Files and settings are converted into commands executed on lifecycle events (DF-02, DF-03, DF-04).
3. **TB-3 Local repository -> derived documentation/state:** Sensitive code/content is transformed into markdown/state representations (DF-01, DF-05).
4. **TB-4 Local runtime -> external service (opt-in only):** Release operation crosses from local to GitHub network boundary (DF-06).

## Egress inventory
| Path | Default | Intentional/Accidental | Related Flows | Control expectation |
|---|---|---|---|---|
| `gh release create` in `scripts/bump.sh` | Disabled unless user runs script | Intentional | DF-06 | Keep explicit opt-in and operator-owned |
| Hook/session stdout content | Enabled when hooks installed | Accidental | DF-02, DF-04 | Limit sensitive detail in output; treat terminals/transcripts as sensitive |
| Git push/tag outside local-only mode | Manual | Intentional | DF-05, DF-06 | Require maintainer intent and review gate |
| Local artifacts committed accidentally | Mitigated by `.gitignore` | Accidental | DF-01, DF-02, DF-05 | Preserve ignore protections for runtime state/artifacts |

## Flow to threat linkage
| Flow ID | Primary threat IDs |
|---|---|
| DF-01 | TH-001, TH-002 |
| DF-02 | TH-003, TH-004 |
| DF-03 | TH-001, TH-005 |
| DF-04 | TH-003 |
| DF-05 | TH-004, TH-006 |
| DF-06 | TH-007, TH-008 |
