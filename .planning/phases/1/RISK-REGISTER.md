# Phase 1 Risk Register

## Severity rubric
- **Likelihood:** Low / Medium / High based on exploitability and occurrence probability in normal repo operation.
- **Impact:** Low / Medium / High based on confidentiality, integrity, and workflow disruption.
- **Priority order:** Highest severity first, then higher likelihood.

## Prioritized risks
| Risk ID | Threat IDs | Affected Flow IDs | Risk Statement | Likelihood | Impact | Severity | Priority | Owner | Mitigation | Target Phase | Verification Hook |
|---|---|---|---|---|---|---|---|---|---|---|---|
| R-001 | TH-001 | DF-03 | Unsafe hook setup path handling can lead to malformed or unsafe command entries in project hook settings. | Medium | High | High | P1 | maintainer | Add strict vault-path validation and JSON-safe escaping/integrity checks for hook command generation. | Phase 2 | Verify setup rejects unsafe path patterns and preserves valid settings JSON. |
| R-002 | TH-002 | DF-01 | Generated docs may include overly sensitive source details when scope boundaries are loose. | Medium | High | High | P1 | maintainer | Enforce local-only scope guardrails and sensitive-content output boundaries in generation workflow. | Phase 2 | Confirm prompts/templates define exclusion rules and default-safe scope. |
| R-003 | TH-003 | DF-02, DF-04 | Hook output can leak sensitive metadata/content into terminal transcripts or shared logs. | High | Medium | High | P1 | maintainer | Add redaction/minimization standards for hook stdout and warn about terminal sensitivity. | Phase 3 | Run hook events and verify no sensitive payload fragments are printed. |
| R-004 | TH-007 | DF-06 | Explicit release flow can exfiltrate sensitive artifacts if run without preflight checks. | Medium | High | High | P1 | maintainer | Add explicit release preflight checklist and ensure outbound policy is opt-in with review gate. | Phase 2 | Confirm release workflow includes required confirmation/checklist before publish. |
| R-005 | TH-004 | DF-02, DF-05 | State/docs drift reduces trust in generated analysis and weakens reviewability. | Medium | Medium | Medium | P2 | maintainer | Introduce docs/state consistency checks tied to canonical references. | Phase 4 | Validate consistency check catches intentional mismatch. |
| R-006 | TH-005 | DF-03 | Hook setup/teardown schema drift can break local workflow automation. | Medium | Medium | Medium | P2 | maintainer | Add settings schema validation and rollback-on-failure semantics in hook setup tooling. | Phase 2 | Simulate malformed config and verify safe failure without corruption. |
| R-007 | TH-006 | DF-05 | Short-hash ambiguity can cause stale-check and diff provenance errors. | Low/Medium | Medium | Medium | P2 | maintainer | Use full commit hashes in stale-check and update metadata. | Phase 2 | Verify stale-check uses full hash and resolves unambiguous diff. |
| R-008 | TH-008 | DF-06 | Over-privileged GitHub CLI credentials increase blast radius of release misuse. | Low/Medium | High | Medium/High | P2 | maintainer | Document and enforce least-privilege auth profile for release operations. | Phase 2 | Validate release guide requires least-privilege account/token scope. |

## High-severity ownership and mitigation check
| Risk ID | Severity | Owner present | Mitigation present | Target phase present |
|---|---|---|---|---|
| R-001 | High | Yes | Yes | Yes |
| R-002 | High | Yes | Yes | Yes |
| R-003 | High | Yes | Yes | Yes |
| R-004 | High | Yes | Yes | Yes |

## Traceability chain
| Flow ID | Threat IDs | Risk IDs |
|---|---|---|
| DF-01 | TH-002 | R-002 |
| DF-02 | TH-003, TH-004 | R-003, R-005 |
| DF-03 | TH-001, TH-005 | R-001, R-006 |
| DF-04 | TH-003 | R-003 |
| DF-05 | TH-004, TH-006 | R-005, R-007 |
| DF-06 | TH-007, TH-008 | R-004, R-008 |
