# Phase 1 Research: Threat Model and Data Flow Baseline

**Date:** 2026-04-29  
**Scope:** Local-only threat-model and data-flow baseline for this repository  
**Overall confidence:** HIGH (repo observations + OWASP primary guidance)

## Summary

Phase 1 should produce a lightweight but auditable baseline: (1) one repository-specific data-flow map with trust boundaries, (2) one STRIDE threat register mapped to those flows, and (3) one prioritized risk register with clear owners and mitigations. This directly satisfies roadmap verification requirements for documented scenarios, trust boundaries, and high-severity owner/mitigation paths. [VERIFIED: `.planning/ROADMAP.md`] [VERIFIED: `.planning/REQUIREMENTS.md`]

The most practical method for this repo is: model the actual local execution paths first (skill invocation, hooks, vault/state/log artifacts, git operations), then evaluate only boundary crossings and sensitive stores with STRIDE. Use OWASP DFD + trust-boundary framing and OWASP likelihood/impact severity categories to keep scoring consistent and repeatable without introducing heavy tooling. [CITED: https://cheatsheetseries.owasp.org/cheatsheets/Threat_Modeling_Cheat_Sheet.html] [CITED: https://owasp.org/www-community/Threat_Modeling_Process] [CITED: https://wiki.owasp.org/index.php/OWASP_Risk_Rating]

## Current-State Observations (Repo-Specific)

1. Project intent and requirements are explicitly local-only, security-first, no default telemetry/remote sync. [VERIFIED: `.planning/PROJECT.md`] [VERIFIED: `.planning/REQUIREMENTS.md`] [VERIFIED: `.planning/config.json`]
2. Primary workflow writes sensitive outputs under `docs-vault/` (including `_state/analysis.json` with module/dependency/issues/session metadata) and uses git diff/update flows. [VERIFIED: `README.md`]
3. Hook scripts are local and read-only by design; they read local state and print context hints to stdout. [VERIFIED: `skills/code-to-docs-hooks/hooks/digest-on-start.sh`] [VERIFIED: `skills/code-to-docs-hooks/hooks/update-hint-on-commit.sh`]
4. `.gitignore` currently excludes `docs-vault/`, `tests/`, `scripts/`, `.claude-plugin/`, `.firecrawl/`, and other local artifacts, reducing accidental commit risk for many runtime outputs. [VERIFIED: `.gitignore`]
5. A release script (`scripts/bump.sh`) pushes tags/releases and calls `gh release create`; this is an explicit outbound path that must be classed as opt-in/exception under local-only guardrails. [VERIFIED: `scripts/bump.sh`]

## Phase Requirements

| ID | Requirement (condensed) | Research Support |
|---|---|---|
| FR-1 | Local-only defaults + explicit opt-in for external workflows | Data-flow map must label all outbound-capable edges and exception controls |
| FR-2 | Sensitive content protection | Threat model must include disclosure/tampering scenarios for source, generated docs, state, logs |
| FR-3 | Secure local baseline checklist | Deliver explicit setup and review checklist artifacts |
| FR-4 | Workflow integrity + verification | Deliver repeatable threat-model and risk review checklist with ownership fields |
| FR-5 | English-only artifacts | Use English templates/checklists for all outputs |
| NFR-1..3 | Privacy, reliability, maintainability | Keep methods lightweight, repeatable, and stored in repo planning artifacts |

## Recommended Threat-Model Method (Implementation)

Use a **4-step STRIDE-per-boundary workflow**:

1. **Define scope and assets**: enumerate sensitive assets first (`analyzed source`, `generated docs`, `_state/analysis.json`, hook outputs, release metadata). [VERIFIED: `README.md`] [VERIFIED: `skills/code-to-docs-hooks/hooks/digest-on-start.sh`]
2. **Model system with DFD elements**: external entities, processes, data stores, data flows, and trust boundaries. [CITED: https://cheatsheetseries.owasp.org/cheatsheets/Threat_Modeling_Cheat_Sheet.html] [CITED: https://owasp.org/www-community/Threat_Modeling_Process]
3. **Apply STRIDE to each boundary-crossing flow/component** and capture concrete abuse case + control. [CITED: https://owasp.org/www-community/Threat_Modeling_Process]
4. **Prioritize risks** with standardized likelihood/impact and severity matrix. [CITED: https://wiki.owasp.org/index.php/OWASP_Risk_Rating]

**Why this is best here:** Local-only hardening is mostly about preventing unintended disclosure/egress and preserving integrity of local artifacts; STRIDE on trust boundaries is high-signal and low-overhead for this repo size. [VERIFIED: `.planning/ROADMAP.md`] [VERIFIED: `.planning/REQUIREMENTS.md`]

## Recommended Data-Flow Mapping Method

Create one **Level-0 Data Flow Inventory** table (no diagram tooling dependency required) with these columns:

- `Flow ID` (DF-01...)  
- `Source` / `Destination`  
- `Data Class` (`Sensitive code/content`, `Operational metadata`, `Public`)  
- `Storage/Transit` (filesystem/stdout/git/network)  
- `Trust Boundary Crossed?` (Y/N)  
- `Default State` (allowed/blocked/opt-in)  
- `Evidence` (file or command reference)

Minimum flows to capture for this repo:
- User/agent -> skill execution -> source repo read [VERIFIED: `README.md`]
- Skill execution -> `docs-vault/*` writes [VERIFIED: `README.md`]
- Hook script -> stdout context injection [VERIFIED: `skills/code-to-docs-hooks/hooks/*.sh`]
- `git diff` / commit metadata -> state/update logic [VERIFIED: `README.md`]
- `scripts/bump.sh` -> GitHub push/release (explicit outbound exception) [VERIFIED: `scripts/bump.sh`]

## Recommended Risk Ranking Method

Use OWASP risk-rating structure:

- Score **Likelihood** (threat agent + vulnerability factors) and **Impact** (technical + business/privacy factors). [CITED: https://wiki.owasp.org/index.php/OWASP_Risk_Rating]
- Convert to `Low / Medium / High` using OWASP bands and matrix. [CITED: https://wiki.owasp.org/index.php/OWASP_Risk_Rating]
- Add one local-only override rule: **any unapproved outbound flow carrying sensitive content is at least High severity until constrained/blocked**. [ASSUMED]

Recommended register columns:
`Risk ID`, `Threat (STRIDE)`, `Affected Flow IDs`, `Likelihood`, `Impact`, `Severity`, `Current Control`, `Mitigation`, `Owner`, `Due`, `Verification Step`.

## Recommended Artifacts for Phase 1

1. `THREAT-MODEL.md` (scope, assets, trust boundaries, STRIDE scenarios).
2. `DATA-FLOWS.md` (Level-0 inventory table with boundary flags and data classes).
3. `RISK-REGISTER.md` (prioritized risks with owner/mitigation/verification).
4. `PHASE-1-CHECKLIST.md` (execution + review checklist below).

These can live under `.planning/phases/1/` for tight auditability with roadmap artifacts. [VERIFIED: `.planning/ROADMAP.md`]

## Execution Checklist (Practical)

- [ ] Confirm sensitive asset list and data classes.
- [ ] Build baseline data-flow table from actual repo behavior.
- [ ] Mark every trust boundary crossing and external dependency.
- [ ] Run STRIDE prompts per high-value flow/component.
- [ ] Score each threat with likelihood/impact and assign severity.
- [ ] For each High risk: assign owner, mitigation path, and verification.
- [ ] Review against FR-1..FR-4 acceptance points before phase sign-off.

## Constraints for Planning

- Keep recommendations local-first and opt-in for external operations. [VERIFIED: `.planning/REQUIREMENTS.md`] [VERIFIED: `.planning/config.json`]
- Prefer artifacted markdown tables/checklists over heavyweight tools for phase baseline speed and reproducibility. [ASSUMED]
- Treat release/publish flows as explicit exceptions, not defaults. [VERIFIED: `scripts/bump.sh`] [VERIFIED: `.planning/REQUIREMENTS.md`]

## Assumptions Log

| ID | Assumption | Risk if Wrong |
|---|---|---|
| A1 | Any sensitive outbound flow should be auto-rated High before control review | Could over-prioritize some issues; low operational risk |
| A2 | Markdown artifact set in `.planning/phases/1/` is preferred for this team's execution rhythm | Could require later reshaping into a different template |

## Sources

- OWASP Threat Modeling Cheat Sheet — DFD/trust-boundary/STRIDE workflow: https://cheatsheetseries.owasp.org/cheatsheets/Threat_Modeling_Cheat_Sheet.html
- OWASP Threat Modeling Process — entry/exit points, trust levels, DFD elements, STRIDE usage: https://owasp.org/www-community/Threat_Modeling_Process
- OWASP Risk Rating Methodology — likelihood/impact/severity approach: https://wiki.owasp.org/index.php/OWASP_Risk_Rating
- Repository evidence: `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, `.planning/config.json`, `README.md`, `.gitignore`, `scripts/bump.sh`, `skills/code-to-docs-hooks/hooks/*.sh`
