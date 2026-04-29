#!/usr/bin/env bash
# Block commits of sensitive paths (defense before egress; D-06, D-08).
# Install: git config core.hooksPath scripts (paths relative to repo root) or use .git/hooks/pre-commit below.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${REPO_ROOT}" ]]; then
    exit 0
fi

cd "${REPO_ROOT}"

while IFS= read -r path; do
    [[ -z "${path}" ]] && continue
    case "${path}" in
    docs-vault/* | */docs-vault/* | docs-vault)
        echo "Error: blocked sensitive path (${path}). Unstage: git reset HEAD -- \"${path}\"" >&2
        exit 1
        ;;
    _state/* | */_state/* | _state | */_state)
        echo "Error: blocked sensitive path (${path}). Unstage: git reset HEAD -- \"${path}\"" >&2
        exit 1
        ;;
    research/* | */research/*)
        echo "Error: blocked sensitive path (${path}). Unstage: git reset HEAD -- \"${path}\"" >&2
        exit 1
        ;;
    .claude-plugin/* | */.claude-plugin/*)
        echo "Error: blocked sensitive path (${path}). Unstage: git reset HEAD -- \"${path}\"" >&2
        exit 1
        ;;
    .firecrawl/* | */.firecrawl/*)
        echo "Error: blocked sensitive path (${path}). Unstage: git reset HEAD -- \"${path}\"" >&2
        exit 1
        ;;
    .superpowers/* | */.superpowers/*)
        echo "Error: blocked sensitive path (${path}). Unstage: git reset HEAD -- \"${path}\"" >&2
        exit 1
        ;;
    esac
done < <(git diff --cached --name-only)

exit 0
