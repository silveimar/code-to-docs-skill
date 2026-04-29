# Phase 2: Local-Only Guardrails Implementation - Context

**Gathered:** 2026-04-29  
**Status:** Ready for planning

<domain>
## Phase Boundary

Implement repository-local guardrails that enforce **local-first defaults** and reduce **accidental outbound egress** and **accidental commits of sensitive artifacts**, aligned with Phase 1 threat modeling outputs.

This phase intentionally focuses on **controls + documentation + lightweight automation**. Full redaction engineering belongs to Phase 3, except where trivial sanitization is necessary to avoid leaking sensitive paths/tokens in hook output.

</domain>

<decisions>
## Implementation Decisions

### Outbound execution policy (network-capable workflows)

- **D-01:** Default posture is **fail-closed** for network egress unless the operation is part of an explicit **allowlisted command surface**.
- **D-02:** Maintain an **allowlist** of commands/scripts permitted to perform outbound/network actions (starting with `scripts/bump.sh`), documented in-repo with rationale and prerequisites (for example GitHub CLI auth).
- **D-03:** Treat Git operations as **two lanes**:
  - **Local lane:** tagging/version bump commits may remain local-only when configured that way.
  - **Publish lane:** **remote push + GitHub release** (`git push`, `gh release create`) requires an additional explicit gate beyond the script’s interactive confirmation (documented env/flag contract).

### Vault/path trust boundaries (hook-install paths)

- **D-04:** `CODE_TO_DOCS_VAULT` / hook-installed vault paths may be **any absolute path**, but must emit a **high-signal warning** when outside the repository root (still permitted).
- **D-05:** Reject vault paths containing **quotes/control characters/shell metacharacters** at validation time (fail-closed with actionable remediation), preferring robust escaping when generating `.claude/settings.json` hook commands.

### Sensitive artifact protection (accidental commits)

- **D-06:** Add a **local pre-commit guard** (script/hook) that blocks staging/commits of known sensitive artifact paths/patterns (vault outputs, analysis/state JSON, local tooling directories), tuned to this repo’s layout.
- **D-07:** Keep `.gitignore` aligned as defense-in-depth, but treat the guard as the primary automated prevention mechanism.

### Guardrail UX / failure behavior

- **D-08:** Policy violations default to **fail-closed** (non-zero exit, stop immediately).
- **D-09:** Error messaging is **short and actionable**: what failed, why, and the smallest next command/fix (avoid dumping sensitive content).

### Phase boundary note — redaction work

- **D-10:** Phase 2 includes **minimal sanitization only** when trivially safe (for example avoid printing raw secrets; trim noisy paths). Broader redaction patterns belong to Phase 3.

### Claude's Discretion

- Exact allowlist membership beyond `scripts/bump.sh`, naming of env gates, and structure of the pre-commit guard implementation (bash vs Python helper) — constrained by decisions above.

</decisions>

<specifics>
## Specific Ideas

- Publishing remains possible but must not be “ambient network”; it must be **opt-in per lane** (local vs publish), consistent with FR-1.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase inputs (security baseline)

- `.planning/phases/1/DATA-FLOWS.md` — authoritative inventory of flows/boundaries this phase must constrain.
- `.planning/phases/1/THREAT-MODEL.md` — STRIDE scenarios driving guardrail priorities.
- `.planning/phases/1/RISK-REGISTER.md` — prioritized risks and mitigation targets for Phase 2 scope.
- `.planning/phases/1/VERIFICATION.md` — Phase 1 verification evidence and PASS baseline.

### Requirements and roadmap anchors

- `.planning/REQUIREMENTS.md` — FR/NFR constraints for local-only operation and sensitive content handling.
- `.planning/ROADMAP.md` — Phase 2 goals/deliverables/verification targets.

### Repo hotspots referenced by Phase 1 / codebase maps

- `scripts/bump.sh` — explicit outbound path (`git push`, `gh release create`) requiring publish-lane gating.
- `skills/code-to-docs-hooks/hooks/setup.sh` — generates `.claude/settings.json` hook commands; path quoting/sanitization is in-scope for Phase 2 hardening.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets

- Hook lifecycle scripts under `skills/code-to-docs-hooks/hooks/` are the primary enforcement surface for session behaviors.
- `scripts/bump.sh` is the clearest packaged outbound workflow today.

### Established Patterns

- Bash + inline Python JSON merges are already used for settings merging; validation/sanitization should extend this pattern rather than introducing new runtime dependencies.

### Integration Points

- `.claude/settings.json` hook wiring is the trust boundary for automatic execution on Claude events.
- `.gitignore` currently excludes several local directories; Phase 2 should align ignore rules with the pre-commit guard (defense in depth).

</code_context>

<deferred>
## Deferred Ideas

- Full redaction library/patterns for logs and transcripts — Phase 3 per roadmap.
- CI-grade secret scanning service integration — optional backlog (not required for local-only posture).

</deferred>

---

*Phase: 02-local-only-guardrails-implementation*  
*Context gathered: 2026-04-29*
