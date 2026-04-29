#!/usr/bin/env bash
# Run shellcheck on the same shell script set as validate-security.sh (bash -n).
# SHL-01/SHL-03: keep scope and flags aligned with CI.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

if ! command -v shellcheck >/dev/null 2>&1; then
	echo "ERROR: shellcheck is not in PATH." >&2
	echo "Install: macOS: brew install shellcheck | Debian/Ubuntu: sudo apt install shellcheck" >&2
	exit 127
fi

FILES=()
while IFS= read -r -d '' f; do
	FILES+=("$f")
done < <(find scripts skills/code-to-docs-hooks/hooks -name '*.sh' -print0 2>/dev/null)

if [ "${#FILES[@]}" -eq 0 ]; then
	echo "No *.sh files found under scripts/ or skills/code-to-docs-hooks/hooks/"
	exit 0
fi

exec shellcheck --severity=warning "${FILES[@]}"
