# Sensitive content handling (local)

This repository processes **analyzed source code** and **generated documentation** for local use. Treat them as **sensitive by default** (see `REQUIREMENTS.md` **FR-2**).

## What we classify as sensitive

| Class | Examples | Default handling |
|-------|-----------|------------------|
| Source under analysis | Customer repos, proprietary modules | Stay local; do not paste full trees into public tickets without review |
| Generated markdown / vault | `docs-vault/` outputs | Gitignored by default; same sensitivity as inputs |
| Runtime state | `docs-vault/_state/*.json` | Ephemeral analysis metadata — may echo project titles; hook output is redacted (see below) |
| Transcripts & logs | Claude sessions, terminal captures | Apply same redaction discipline before sharing |

## Redaction patterns (operational output)

Hook and maintainer scripts use `scripts/redact_public_text.py` to strip common secret shapes from **stdout meant for assistants**:

- `Bearer` tokens
- JWT-shaped strings (`eyJ...`)
- API keys starting with `sk-` (common vendor shapes)
- AWS access key ids (`AKIA` + 16 chars)
- Email addresses

Matches are replaced with `[REDACTED]`. The helper is **best-effort** — when in doubt, treat the underlying content as sensitive even if not matched.

## Operator responsibilities

1. Do not commit vault outputs, raw traces, or `_state` JSON unless your policy explicitly allows it (see pre-commit guard).
2. Before exporting a transcript, scan for secrets; rely on redaction helpers as **supplement**, not sole control.
3. Keep English-only assistant-facing docs per **FR-5** where applicable.

## Canonical implementation

- `scripts/redact_public_text.py` — stdin/stdout filter  
- `skills/code-to-docs-hooks/hooks/digest-on-start.sh` — applies filter to vault-derived labels and diff-stat lines
