# PR CI and local validation (v1.1)

This document describes **automated** checks on pull requests and the **same commands** to run locally. It implements the **DOC-01** / **NFR-** traceability for milestone v1.1.

## When CI runs

- **Event:** `pull_request`  
- **Branches:** `main` (see workflow)  
- **Workflow file:** `.github/workflows/security-ci.yml`  
- **Permissions:** `contents: read` only (no `id-token`, packages, or write scopes for these jobs)

## What CI runs (order)

1. **Checkout** — `actions/checkout@v4` (GitHub-hosted; standard Actions egress only).
2. **`./scripts/validate-security.sh`** — Aggregates shell syntax (`bash -n`), Python redact helper checks, policy file presence, vault path rejection test (same as local).
3. **Install shellcheck** — `sudo apt-get update && sudo apt-get install -y shellcheck` on the Ubuntu runner (distribution mirrors only).
4. **`./scripts/run-shellcheck.sh`** — `shellcheck --severity=warning` on all `*.sh` under `scripts/` and `skills/code-to-docs-hooks/hooks/` (same scope as the bash-syntax pass).

Any step exiting non-zero fails the job.

## Local parity

Run the same entrypoints from the repository root:

```bash
./scripts/validate-security.sh
./scripts/run-shellcheck.sh
```

Install **shellcheck** if missing: macOS `brew install shellcheck`; Debian/Ubuntu `sudo apt install shellcheck`. The wrapper prints this hint with exit `127` when `shellcheck` is not in `PATH`.

### Linux vs macOS

Scripts are portable bash/Python. The **only** deliberate environment difference is how **shellcheck** is installed (package manager). CI uses Ubuntu’s `apt`; local developers use their OS packages. Behavior of `validate-security.sh` and `run-shellcheck.sh` is identical once `shellcheck` exists.

## Outbound / network posture (NFR-01)

- **Validation scripts** (`validate-security.sh`, `run-shellcheck.sh`, hooks exercised by them) do not add network calls beyond what Phase v1.0 already defined.
- **CI** adds:
  - Normal **GitHub Actions** usage (checkout, runner telemetry as per GitHub).
  - **`apt-get`** to Ubuntu archives for the `shellcheck` package — documented here and in `outbound-allowlist.md`.
- CI does **not** enable `scripts/bump.sh` publish lanes or other allowlisted remote operations.

## Related

- `docs/security/outbound-allowlist.md` — Allowlisted maintainer egress; CI subsection.
- `docs/security/validation-checklist.md` — Manual checklist including CI row.
- Phase verification: `.planning/phases/05-pr-ci-workflow-linux-validation-path/VERIFICATION.md`, `.planning/phases/06-shellcheck-integration/VERIFICATION.md`.
