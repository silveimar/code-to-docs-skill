# Outbound / network-capable scripts (allowlist)

This repository’s **default posture is fail-closed** for network egress (**D-01**, **D-08**): only documented entry points may perform remote Git / GitHub operations. There is no repo-wide network syscall wrapper; **enforcement** is **this policy** plus **gated scripts** (starting with `scripts/bump.sh`). Unknown scripts are **not** supported outbound entry points (**D-02**).

## Allowlisted script

| Script | Remote / network behavior | Rationale |
|--------|---------------------------|-----------|
| `scripts/bump.sh` | Optional **publish lane** only: `git push`, `git push` of tag, `gh release create` | Maintainer release workflow; must not run without explicit publish gate (**D-03**). |

## Prerequisites (publish lane)

- Network connectivity to Git remotes and GitHub API.
- `git` with push access to the configured `origin`.
- **GitHub CLI** (`gh`) installed and authenticated (`gh auth login`), suitable for `gh release create`.
- Repository identifier used by the script: see `REPO=` in `scripts/bump.sh` (maintainer constant).

## Publish-lane contract (**D-03**)

**Local lane (default)** performs **no** `git push`, **no** `gh` calls, and **no** other remote operations: version bump, optional commit, **local tag only**.

**Publish lane** runs remote push and `gh release create` **only if all** of the following hold:

1. Interactive confirmation answers **y** at the `Proceed? [y/N]` prompt (same as local lane).
2. **Second gate** — either:
   - environment variable **`CODE_TO_DOCS_PUBLISH=1`** (must be set to `1`; unset or `0` does not enable publish), **or**
   - the **`--publish`** flag is passed on the command line (see `scripts/bump.sh` usage).

Examples:

```bash
# Local only (no remote)
./scripts/bump.sh patch

# Publish after bump (env gate)
CODE_TO_DOCS_PUBLISH=1 ./scripts/bump.sh minor

# Publish after bump (flag gate)
./scripts/bump.sh --publish patch
```

If the publish lane is enabled but `gh` is missing or not authenticated, the script **exits non-zero** (fail-closed). Push and `gh` failures are **not** masked in the publish lane (**D-01**, **D-09**).

## References

- Decisions **D-01–D-03**: `.planning/phases/02-local-only-guardrails-implementation/02-CONTEXT.md`
- Implementation: `scripts/bump.sh`
