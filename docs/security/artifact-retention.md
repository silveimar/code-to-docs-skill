# Local artifact retention

Guidance for **local-only** storage of code-to-docs outputs. No remote sync or telemetry is implied (**NFR-1**).

## Typical artifacts

| Location | Role | Retention stance |
|----------|------|------------------|
| `docs-vault/` | Generated documentation mirror | Long-lived locally; never required in git (see `.gitignore`) |
| `docs-vault/_state/` | Analysis indices and session metadata | Safe to delete to reset analysis; regenerates on next run |
| Caches / tmp | Tool-specific | Follow each tool’s docs; prefer deleting before sharing repo copies |

## Cleanup

- After major repo upgrades, consider removing `_state` if analysis appears stale.
- Disk pressure: remove old vault snapshots only after confirming you do not need historical digests.

## Out of scope

Encrypted vaults, enterprise retention policies, and automated cloud backup are **not** part of this milestone — see roadmap backlog notes.
