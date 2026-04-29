#!/usr/bin/env bash
# Ephemeral repo: staging docs-vault/* must be blocked by pre-commit-guard.sh (Phase 4 regression).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GUARD="${ROOT}/scripts/pre-commit-guard.sh"
TMP=$(mktemp -d)
cleanup() { rm -rf "${TMP}"; }
trap cleanup EXIT

cd "${TMP}"
git init -q
git config user.email "regression@local"
git config user.name "regression"
mkdir -p docs-vault
echo fixture >docs-vault/.regression-fixture
git add docs-vault/.regression-fixture

set +e
bash "${GUARD}"
ec=$?
set -e

if [[ "${ec}" -ne 1 ]]; then
	echo "FAIL: pre-commit-guard.sh expected exit 1 for staged docs-vault path, got ${ec}" >&2
	exit 1
fi

echo "OK: pre-commit guard blocks staged docs-vault path (exit 1 as expected)."
