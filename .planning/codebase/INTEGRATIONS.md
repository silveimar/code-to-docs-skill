# External Integrations

**Analysis Date:** 2026-04-29

## APIs & External Services

**Developer Tooling Platforms:**
- GitHub - Release publishing target for plugin distribution
  - SDK/Client: `gh` CLI in `scripts/bump.sh`
  - Auth: GitHub CLI local auth/session (no repo-stored env var detected)
- Obsidian (optional local app/CLI) - Note creation and property management during documentation generation
  - SDK/Client: `obsidian` CLI referenced in `README.md`, `skills/code-to-docs/SKILL.md`, and `skills/code-to-docs-references/output-structure.md`
  - Auth: Not required by this repo (local desktop tooling usage)
- Claude Code runtime hooks - SessionStart and PostToolUse automation contract
  - SDK/Client: Hook JSON schema and shell commands in `skills/code-to-docs-hooks/hooks/setup.sh`
  - Auth: Not applicable (local project settings integration)

## Data Storage

**Databases:**
- None detected
  - Connection: Not applicable
  - Client: Not applicable

**File Storage:**
- Local filesystem only
  - Vault/state writes and reads target paths such as `docs-vault/` and `_state/analysis.json` per `README.md` and `skills/code-to-docs-update/SKILL.md`

**Caching:**
- None detected

## Authentication & Identity

**Auth Provider:**
- Custom/local tooling auth only
  - Implementation: Delegated to host tools (primarily GitHub CLI login state for release operations in `scripts/bump.sh`)

## Monitoring & Observability

**Error Tracking:**
- None detected (no Sentry/Datadog/New Relic integrations)

**Logs:**
- Shell stdout/stderr messaging from scripts (e.g., user-facing status lines in `skills/code-to-docs-hooks/hooks/*.sh` and `scripts/bump.sh`)

## CI/CD & Deployment

**Hosting:**
- Not applicable (no running service deployment target)

**CI Pipeline:**
- None detected in repository (no GitHub Actions, CircleCI, or other pipeline config files found)

## Environment Configuration

**Required env vars:**
- `CODE_TO_DOCS_VAULT` - Overrides default vault path for hooks (`skills/code-to-docs-hooks/hooks/setup.sh`, `digest-on-start.sh`, `update-hint-on-commit.sh`)

**Secrets location:**
- No explicit secrets storage pattern detected in repo; credentials are expected to be managed externally by host CLIs (for example GitHub CLI auth)

## Webhooks & Callbacks

**Incoming:**
- None (no HTTP webhook endpoints implemented; hooks are local Claude event hooks configured in `.claude/settings.json`)

**Outgoing:**
- GitHub release API calls via `gh release create` in `scripts/bump.sh`
- Local hook command callbacks from Claude events to shell scripts in `skills/code-to-docs-hooks/hooks/setup.sh`

---

*Integration audit: 2026-04-29*
