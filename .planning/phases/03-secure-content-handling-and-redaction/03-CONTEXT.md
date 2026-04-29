# Phase 3: Secure Content Handling and Redaction - Context

**Gathered:** 2026-04-29  
**Status:** Ready for planning

<domain>
## Phase Boundary

Deliver **policy**, **operational redaction patterns**, and **lightweight automation** so logs, hook-injected context, and guidance reduce accidental leakage of sensitive content from analyzed code and generated artifacts — per ROADMAP Phase 3 and **FR-2**, **NFR-1–3**.

This phase does **not** implement enterprise DLP, remote scrubbing, or encrypted vault storage (see backlog). It focuses on repo-visible docs + hook stdout paths called out in Phase 1/2 baselines.

</domain>

<decisions>
## Implementation Decisions

### Policy and documentation

- **D-01:** Publish a **Sensitive content handling** policy under `docs/security/` describing classification (analyzed source, generated docs, `_state`, transcripts), default sensitivity stance, and operator responsibilities.
- **D-02:** Publish **artifact retention** guidance for local vault/state directories — what may accumulate, what must stay gitignored, and sensible cleanup posture (documentation-first).

### Redaction patterns and automation

- **D-03:** Maintain a **canonical pattern list** (Bearer/JWT-shaped, common API key prefixes, AWS-like keys, high-entropy hex blobs, obvious emails in operational output) in policy doc; duplicate a **minimal executable subset** in `scripts/redact_public_text.py` for hooks/scripts (stdlib only).
- **D-04:** Hook-injected SessionStart output (`digest-on-start.sh`) MUST run user-visible strings that derive from vault JSON or git through **redact helper** before echo (fail-closed: on helper failure, emit generic placeholder lines rather than raw fields).
- **D-05:** **PostToolUse** hook output remains minimal; still run through same helper if future lines include dynamic content.

### Behavior when uncertain

- **D-06:** Prefer **redact or shorten** over emitting ambiguous binary/large blobs in hook stdout; align with Phase 2 **fail-closed** posture for security UX.

### Claude's Discretion

- Exact regex list may evolve; keep policy and script in sync when adding patterns. Placement of helper (`scripts/` vs `skills/`) follows existing maintainer script pattern from Phase 2.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Baseline and requirements

- `.planning/REQUIREMENTS.md` — **FR-2** sensitive content and redaction guidance.
- `.planning/ROADMAP.md` — Phase 3 goals, deliverables, verification bullets.
- `.planning/phases/1/DATA-FLOWS.md` — where content moves.
- `.planning/phases/1/THREAT-MODEL.md` — disclosure scenarios.
- `.planning/phases/02-local-only-guardrails-implementation/02-CONTEXT.md` — **D-09/D-10** hygiene boundary before Phase 3.

### Implementation anchors

- `skills/code-to-docs-hooks/hooks/digest-on-start.sh` — primary injection surface for vault-derived strings.
- `skills/code-to-docs-hooks/hooks/update-hint-on-commit.sh` — secondary hook output.
- `skills/code-to-docs-hooks/SKILL.md` — install and operator-facing references.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable assets

- Phase 2 **pre-commit guard** and **vault validation** remain the commit-time and path-trust controls; Phase 3 adds **content shaping** for stdout.
- `digest-on-start.sh` already truncates commit hash and uses vault **basename**; Phase 3 tightens **project/modules** strings that may echo repository-identifying data.

### Established patterns

- Python 3 one-shots in bash hooks for JSON parsing — extend with shared `scripts/redact_public_text.py` invoked from bash.

</code_context>
