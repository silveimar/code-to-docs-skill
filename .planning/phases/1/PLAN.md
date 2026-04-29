---
phase: 1
title: "Threat Model and Data Flow Baseline"
requirements:
  - FR-1
  - FR-2
  - FR-3
  - FR-4
  - FR-5
  - NFR-1
  - NFR-2
  - NFR-3
depends_on: []
files_modified:
  - .planning/phases/1/PLAN.md
  - .planning/phases/1/RESEARCH.md
  - .planning/phases/1/DATA-FLOWS.md
  - .planning/phases/1/THREAT-MODEL.md
  - .planning/phases/1/RISK-REGISTER.md
  - .planning/phases/1/VERIFICATION.md
must_haves:
  truths:
    - "A maintainer can identify every major sensitive-data flow in one place."
    - "Each major flow has explicit trust boundaries and crossings."
    - "High-severity risks include owner and mitigation path."
    - "Phase 1 baseline is reproducible using documented gates."
  artifacts:
    - .planning/phases/1/PLAN.md
    - .planning/phases/1/THREAT-MODEL.md
    - .planning/phases/1/DATA-FLOWS.md
    - .planning/phases/1/RISK-REGISTER.md
    - .planning/phases/1/VERIFICATION.md
  key_links:
    - "DATA-FLOWS.md flow IDs reference THREAT-MODEL.md threat IDs."
    - "THREAT-MODEL.md high-severity threat IDs map to RISK-REGISTER.md mitigations."
    - "VERIFICATION.md contains evidence-based pass/fail for all Phase 1 roadmap checks."
---

# Phase 1 Plan: Threat Model and Data Flow Baseline

## Objective
Build a testable security baseline for local-only operation by documenting:
- how sensitive code/content moves through the repository workflows,
- where trust boundaries and threat surfaces exist,
- which risks are highest priority with concrete mitigation paths.

This plan is strictly limited to Phase 1 baseline analysis and documentation. It does not implement Phase 2+ guardrails.

## Goal-Backward Must-Haves

### Observable Truths (must be true when Phase 1 is done)
1. A maintainer can identify every major sensitive-data flow (source inputs, generated docs, logs, caches/state, exports) in one place.
2. A maintainer can point to explicit trust boundaries and data-flow crossings for each major flow.
3. High-severity risks are prioritized and each has a named mitigation path and a follow-up owner.
4. The baseline can be re-run and produce consistent structure (same sections, same gate checks).

### Required Artifacts
- `.planning/phases/1/PLAN.md` (this executable plan)
- `.planning/phases/1/THREAT-MODEL.md` (STRIDE-oriented local-only threat model)
- `.planning/phases/1/DATA-FLOWS.md` (data-flow inventory + trust boundaries)
- `.planning/phases/1/RISK-REGISTER.md` (prioritized risks mapped to mitigations)
- `.planning/phases/1/VERIFICATION.md` (phase verification evidence + gate outcomes)

### Key Links (critical wiring)
- Data-flow entries in `DATA-FLOWS.md` must reference threat IDs in `THREAT-MODEL.md`.
- High-severity threat IDs must map to mitigation rows in `RISK-REGISTER.md`.
- `VERIFICATION.md` must include pass/fail evidence against roadmap Phase 1 verification criteria.

## Scope Guardrails
- In scope: baseline modeling, flow inventory, risk prioritization, verification evidence.
- Out of scope: enforcing local-only defaults, implementing block/allow guardrails, redaction implementation, regression automation integration (these belong to later phases).

## Execution Tasks

### Task 1: Produce data-flow baseline
**Depends on:** project context (`PROJECT.md`, `REQUIREMENTS.md`, `ROADMAP.md`, `.planning/codebase/*.md`)  
**Deliverables:** `.planning/phases/1/DATA-FLOWS.md`

**Action**
- Enumerate all sensitive data classes: source code, generated docs, logs/diagnostics, caches/state, exports/releases.
- Document lifecycle per class: origin, transformation points, storage locations, read/write actors, egress vectors.
- Define trust boundaries and crossings (local user, local filesystem, tool runtime hooks, external services like GitHub CLI release path).
- Include a baseline data-flow table with: `Flow ID`, `Data Class`, `Source`, `Processor`, `Storage`, `Trust Boundary`, `Potential Egress`, `Notes`.

**Verification**
- Automated gate:
  - `test -f .planning/phases/1/DATA-FLOWS.md`
  - `rg "^## " .planning/phases/1/DATA-FLOWS.md`
  - `rg "Flow ID|Trust Boundary|Potential Egress" .planning/phases/1/DATA-FLOWS.md`
- Pass criteria:
  - File exists and includes at least one flow for each required data class.
  - Every flow has a trust-boundary entry.

**Done**
- `DATA-FLOWS.md` includes all required table columns and the five minimum repository flows.
- Each flow has a unique `Flow ID` and at least one trust-boundary decision.
- Evidence references in the table point to real repository paths/commands.

### Task 2: Build threat model from flows
**Depends on:** Task 1 output (`DATA-FLOWS.md`)  
**Deliverables:** `.planning/phases/1/THREAT-MODEL.md`

**Action**
- Create a local-only threat model using STRIDE categories.
- For each significant flow/boundary from Task 1, define at least one realistic threat scenario.
- Capture threat metadata: `Threat ID`, `Category`, `Asset`, `Entry Point`, `Likelihood`, `Impact`, `Severity`, `Mitigation Path`, `Residual Risk`.
- Ensure model emphasizes known risk areas from codebase concerns (hook command injection surface, hook trust boundary breadth, docs/process drift).

**Verification**
- Automated gate:
  - `test -f .planning/phases/1/THREAT-MODEL.md`
  - `rg "STRIDE|Threat ID|Severity|Mitigation Path" .planning/phases/1/THREAT-MODEL.md`
  - `rg "High|Critical" .planning/phases/1/THREAT-MODEL.md`
- Pass criteria:
  - Each major data-flow boundary has at least one mapped threat.
  - At least one high-severity threat includes a concrete mitigation path.

**Done**
- `THREAT-MODEL.md` includes STRIDE coverage across mapped boundaries from Task 1.
- Threat entries are complete for required metadata fields.
- At least one high-severity threat is traceable to a concrete mitigation and residual risk note.

### Task 3: Prioritize risks and lock verification baseline
**Depends on:** Task 1 and Task 2 outputs  
**Deliverables:** `.planning/phases/1/RISK-REGISTER.md`, `.planning/phases/1/VERIFICATION.md`

**Action**
- Create prioritized risk register from threat model with ranking rationale.
- For high-severity risks, assign owner label (`owner: maintainer` for this repository) and mitigation target phase (Phase 2+ where applicable).
- Write verification baseline that explicitly tests roadmap Phase 1 criteria:
  1) threats documented/reviewable,
  2) major flows have explicit trust boundaries,
  3) high-severity risks have owner + mitigation path.
- Record pass/fail per criterion with evidence links to produced artifacts.

**Verification**
- Automated gate:
  - `test -f .planning/phases/1/RISK-REGISTER.md && test -f .planning/phases/1/VERIFICATION.md`
  - `rg "Priority|Owner|Mitigation|Target Phase" .planning/phases/1/RISK-REGISTER.md`
  - `rg "PASS|FAIL|Evidence" .planning/phases/1/VERIFICATION.md`
- Pass criteria:
  - Every high-severity risk has owner + mitigation path.
  - `VERIFICATION.md` contains explicit pass/fail outcomes for all three Phase 1 roadmap checks.

**Done**
- `RISK-REGISTER.md` includes ranked risks with owner and target phase for each high-severity item.
- `VERIFICATION.md` records PASS/FAIL with artifact links for all three roadmap checks.
- Traceability chain `DATA-FLOWS -> THREAT-MODEL -> RISK-REGISTER -> VERIFICATION` is complete.

## Threat Model Baseline Output Contract
`THREAT-MODEL.md` must include:
1. System context (local-only assumptions and trust model),
2. Assets and boundaries,
3. STRIDE threat matrix,
4. Mitigation mapping and residual-risk notes.

## Data-Flow Baseline Output Contract
`DATA-FLOWS.md` must include:
1. Data classification legend,
2. End-to-end flow inventory table,
3. Trust-boundary map (textual is acceptable),
4. Egress inventory (intentional vs accidental paths).

## Verification and Gates

### Phase Gate A: Completeness
- PASS if all required artifacts exist and each contains required sections.
- FAIL if any artifact missing or required section absent.

### Phase Gate B: Traceability
- PASS if data-flow IDs map to threat IDs and high-severity threats map to risk-register mitigations.
- FAIL if links are broken or unreferenced.

### Phase Gate C: Roadmap Alignment
- PASS if `VERIFICATION.md` explicitly passes all three Phase 1 verification criteria from roadmap.
- FAIL if any criterion lacks evidence or is unresolved.

## Risks, Rollback, and Adjustment Notes
- **Risk:** Over-modeling creates low-value detail and slows Phase 2.
  - **Adjustment:** Keep only actionable threats tied to real repository flows.
- **Risk:** Under-modeling misses key egress paths.
  - **Adjustment:** Re-run flow inventory checklist and cross-check against `.planning/codebase/INTEGRATIONS.md` and `CONCERNS.md`.
- **Risk:** Ambiguous severity ranking.
  - **Adjustment:** Use explicit likelihood x impact rubric and document rationale in `RISK-REGISTER.md`.
- **Rollback Strategy:** If structure is inconsistent or unverifiable, discard Phase 1 artifacts except `PLAN.md`, regenerate artifacts using this plan’s output contracts, and re-run all gates before moving to Phase 2.

## Dependencies Summary
- Task 1 -> Task 2 -> Task 3 (strict sequence due to artifact dependency).
- No parallelization in this phase because threat and risk outputs depend on the completed data-flow baseline.

## Done Definition
Phase 1 is complete only when:
1. All Phase 1 artifacts exist and satisfy output contracts.
2. Verification gates A/B/C pass with recorded evidence.
3. Scope remains strictly baseline/documentation (no Phase 2+ implementation work).
