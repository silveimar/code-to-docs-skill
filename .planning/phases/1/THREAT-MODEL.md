# Phase 1 Threat Model (Local-Only Baseline)

## 1) System context
- System is a local skill repository with markdown contracts and shell hooks.
- Default trust posture is local-only; network egress is allowed only by explicit operator action.
- Primary sensitive assets are analyzed source content, generated docs/state, and hook/runtime configuration.

## 2) Assets and trust boundaries
| Asset | Sensitivity | Boundary Touchpoints | Related flows |
|---|---|---|---|
| Source repository content | High | TB-1, TB-3 | DF-01, DF-05 |
| Generated docs and state (`docs-vault/`) | High | TB-2, TB-3 | DF-01, DF-02, DF-05 |
| Hook configuration (`.claude/settings.json`) | High (integrity) | TB-1, TB-2 | DF-03 |
| Tool event payloads and terminal output | Medium/High | TB-2 | DF-02, DF-04 |
| Release artifacts and tags | Medium/High | TB-4 | DF-06 |

## 3) STRIDE threat matrix
| Threat ID | STRIDE Category | Asset | Entry Point | Flow IDs | Likelihood | Impact | Severity | Mitigation Path | Residual Risk |
|---|---|---|---|---|---|---|---|---|---|
| TH-001 | Tampering / Elevation of Privilege | Hook config integrity | `setup.sh` path interpolation and JSON command generation | DF-03 | Medium | High | High | Phase 2 hardening: strict vault-path validation + robust escaping and hook integrity validation before write | Medium until path validation is enforced |
| TH-002 | Information Disclosure | Source + generated content | Over-broad analysis/output scope during doc generation | DF-01 | Medium | High | High | Phase 2 policy guardrails: explicit include/exclude boundaries and sensitive-output guard prompts | Medium due to operator-driven scope variability |
| TH-003 | Information Disclosure | Runtime metadata and logs | Hook stdout summaries/reminders printed in active session | DF-02, DF-04 | High | Medium | High | Phase 2 redaction policy + minimized hook output + warning banner for sensitive terminals | Medium; manual copy/screen capture still possible |
| TH-004 | Repudiation / Integrity Drift | Analysis state and docs integrity | State/doc drift between references and generated artifacts | DF-02, DF-05 | Medium | Medium | Medium | Phase 2/4 consistency checks and review checklist enforcing canonical references | Low/Medium after checks are automated |
| TH-005 | Denial of Service | Hook setup/runtime reliability | Malformed `.claude/settings.json` merge/remove behavior | DF-03 | Medium | Medium | Medium | Add schema validation and safe rollback in setup/teardown lifecycle | Low after validation guard |
| TH-006 | Spoofing / Repudiation | Diff provenance in update workflow | Ambiguous short commit hashes in stale-check/diff context | DF-05 | Low/Medium | Medium | Medium | Store full commit hashes and verify diff origin before update prompts | Low |
| TH-007 | Information Disclosure | Sensitive content leaving local boundary | Release script sends artifacts/metadata externally | DF-06 | Medium | High | High | Enforce explicit opt-in release gate and pre-release sensitive content checklist | Medium (intentional outbound path remains) |
| TH-008 | Elevation of Privilege / Misuse | External publish privileges | Compromised or misused GitHub CLI auth context during release | DF-06 | Low/Medium | High | Medium/High | Least-privilege GH auth profile and explicit confirmation step before release publish | Low/Medium |

## 4) Mitigation mapping and residual-risk notes
| Threat ID | Priority | Mitigation target phase | Verification expectation |
|---|---|---|---|
| TH-001 | P1 | Phase 2 | Setup flow rejects unsafe vault paths; generated hook commands are JSON-safe |
| TH-002 | P1 | Phase 2 | Local-only defaults and explicit outbound policy documented/enforced |
| TH-003 | P1 | Phase 3 | Redaction guidance applied to hook outputs and logs |
| TH-004 | P2 | Phase 4 | Repeatable drift/consistency checks pass |
| TH-005 | P2 | Phase 2 | Setup/teardown schema validation prevents corrupt config writes |
| TH-006 | P2 | Phase 2 | Full-hash stale-check behavior documented and validated |
| TH-007 | P1 | Phase 2 | Release flow remains explicit opt-in and includes checklist |
| TH-008 | P2 | Phase 2 | Release auth guidance enforces least privilege |

## Traceability notes
- Flow IDs originate in `.planning/phases/1/DATA-FLOWS.md`.
- High-severity threats (TH-001, TH-002, TH-003, TH-007) are mapped to concrete risk rows and mitigations in `.planning/phases/1/RISK-REGISTER.md`.
