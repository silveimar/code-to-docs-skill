---
name: hooks
description: >
  Install or remove project-level automation hooks for the code-to-docs lifecycle.
  Setup adds SessionStart (digest on session start) and PostToolUse (update hint
  after git commits) hooks. Teardown removes only code-to-docs hooks.
  Use when someone wants to automate doc updates, set up hooks, or remove hooks.
---

# Hooks

Install or remove project-level hooks that automate the code-to-docs lifecycle. Hooks are written to `.claude/settings.json`. Project-local, read-only, non-destructive.

## Related Skills

| Skill | Purpose |
|-------|---------|
| `code-to-docs` | Full documentation generation |
| `code-to-docs:digest` | What the SessionStart hook triggers |
| `code-to-docs:update` | What the PostToolUse hook reminds about |

## Invocation

```
Skill(skill: "code-to-docs:hooks", args: "setup [vault-path]")
Skill(skill: "code-to-docs:hooks", args: "teardown")
```

## Setup

Run the setup script to install both hooks:

```bash
bash skills/code-to-docs-hooks/hooks/setup.sh [vault-path]
```

This installs two hooks into `.claude/settings.json`:

| Hook | Type | Script | Purpose |
|------|------|--------|---------|
| digest-on-start | SessionStart | `digest-on-start.sh` | Run digest at the start of each session |
| update-hint-on-commit | PostToolUse | `update-hint-on-commit.sh` | Remind to update docs after git commits |

## Teardown

Run the teardown script to remove code-to-docs hooks:

```bash
bash skills/code-to-docs-hooks/hooks/teardown.sh
```

Removes hooks by matching the `source` field. Other hooks in settings.json are left untouched.

## Environment

Set `CODE_TO_DOCS_VAULT` to override the default vault path. This is picked up by both setup and the hook scripts themselves.

## Sensitive content (SessionStart output)

Vault-derived labels shown by `digest-on-start.sh` are passed through `scripts/redact_public_text.py` so common token/email shapes are replaced with `[REDACTED]` before entering the assistant context. Policy and pattern rationale: `docs/security/sensitive-content-handling.md`.

## Hook Scripts

| Script | Purpose |
|--------|---------|
| `setup.sh` | Install SessionStart and PostToolUse hooks into `.claude/settings.json` |
| `teardown.sh` | Remove code-to-docs hooks from `.claude/settings.json` by source field |
| `digest-on-start.sh` | SessionStart hook — triggers digest skill on session open |
| `update-hint-on-commit.sh` | PostToolUse hook — prints update reminder after git commit operations |

## Pre-commit guard (sensitive paths)

Install **`scripts/pre-commit-guard.sh`** so staged commits cannot include paths classified as sensitive (vault outputs, local research/plugin dirs), aligned with FR-2 / `.gitignore` intent.

**Option A — `core.hooksPath` (recommended):**

```bash
chmod +x scripts/pre-commit scripts/pre-commit-guard.sh
git config core.hooksPath scripts
```

With `core.hooksPath=scripts`, Git invokes `scripts/pre-commit`, which runs `pre-commit-guard.sh`.

**Option B — Classic `.git/hooks/pre-commit`:**

```bash
chmod +x scripts/pre-commit-guard.sh
cat > .git/hooks/pre-commit <<'EOF'
#!/usr/bin/env bash
exec "$(git rev-parse --show-toplevel)/scripts/pre-commit-guard.sh"
EOF
chmod +x .git/hooks/pre-commit
```

Defense-in-depth: `.gitignore` alone does not stop `git add -f`; the guard blocks the commit at the index.

### `.gitignore` vs tracked `scripts/`

**Ignore rules do not untrack already-tracked files:** repository-tracked maintainer scripts such as `scripts/bump.sh` and `scripts/pre-commit-guard.sh` remain versioned even though `.gitignore` suppresses *new* untracked noise under `scripts/`; the pre-commit guard evaluates **staged** paths regardless of ignore rules.
