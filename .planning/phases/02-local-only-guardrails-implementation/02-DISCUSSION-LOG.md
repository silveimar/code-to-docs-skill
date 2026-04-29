# Phase 2: Local-Only Guardrails Implementation - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.  
> Decisions are captured in `02-CONTEXT.md` — this log preserves the alternatives considered.

**Date:** 2026-04-29  
**Phase:** 02-local-only-guardrails-implementation  
**Areas discussed:** Outbound execution policy, Vault/path trust boundaries, Sensitive artifact protection, Guardrail UX/failure behavior  

---

## Outbound execution policy

| Option | Description | Selected |
|--------|-------------|----------|
| Hard guardrail: block network egress unless explicit each time | Strict interactive gate |  |
| Allow network only via narrowly-scoped allowlisted commands | Documented allowlist + constrained surfaces | ✓ |
| Warn prominently but still allow | Soft guardrail |  |
| Let Claude decide | Delegated |  |

**User's choice:** Allow explicit commands only (allowlisted outbound surfaces).  
**Notes:** Publishing flows must not be ambient; allowlist starts from existing outbound scripts such as `scripts/bump.sh`.

---

## Release flow lane separation (`scripts/bump.sh`)

| Option | Description | Selected |
|--------|-------------|----------|
| Single gate for all remote operations | One switch for push + release |  |
| Split: local lane vs publish lane | Separate gating for remote push vs GitHub release | ✓ |
| Policy/docs only | No enforcement changes |  |
| Disable remote operations entirely | Remove/disable remote calls |  |

**User's choice:** Split push vs release (extra gate for publish lane beyond script confirmation).

---

## Vault/path trust boundaries

| Option | Description | Selected |
|--------|-------------|----------|
| Strict under repo root only | Reject external paths |  |
| Allow absolute paths with confirmation/warnings | Flexible paths with explicit warnings | ✓ |
| Fixed default only | Minimal flexibility |  |
| Let Claude decide | Delegated |  |

**User's choice:** Allow any absolute path with warning when outside repo root.

---

## Vault path character policy

| Option | Description | Selected |
|--------|-------------|----------|
| Reject quotes + control + shell metacharacters | Strong input hygiene | ✓ |
| Reject only quotes + newlines | Lighter restriction |  |
| No rejections; escape instead | Escape-first |  |
| Let Claude decide | Delegated |  |

**User's choice:** Reject quotes and control characters (strong rejection rule).

---

## Sensitive artifact protection

| Option | Description | Selected |
|--------|-------------|----------|
| `.gitignore` + docs | Defense-in-depth docs only |  |
| Add local pre-commit guard | Automated staging/commit blocking | ✓ |
| Policy/docs only | Manual discipline |  |
| Let Claude decide combo | Delegated |  |

**User's choice:** Add a local pre-commit guard script/hook.

---

## Redaction vs Phase boundaries

| Option | Description | Selected |
|--------|-------------|----------|
| Minimal sanitization in Phase 2 | Only trivial safe scrubbing in hooks | ✓ |
| No redaction in Phase 2 | Defer fully |  |
| Aggressive redaction now | Blurs Phase 3 scope |  |

**User's choice:** Minimal sanitization in Phase 2; defer fuller redaction to Phase 3.

---

## Guardrail UX / failure behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Fail-closed | Stop immediately with errors | ✓ |
| Fail-closed + explicit env override | Power-user bypass |  |
| Warn-first interactive confirm | Softer |  |
| Let Claude decide | Delegated |  |

**User's choice:** Fail-closed defaults.

---

## Messaging style

| Option | Description | Selected |
|--------|-------------|----------|
| Short actionable errors | Minimal noise, fix-forward | ✓ |
| Verbose debug-friendly | More diagnostic detail |  |
| Let Claude decide | Delegated |  |

**User's choice:** Short actionable messaging.

---

## Claude's Discretion

None selected explicitly — discretion limited to implementation structure inside the locked decisions.

---

## Deferred Ideas

- Comprehensive redaction patterns — Phase 3.
