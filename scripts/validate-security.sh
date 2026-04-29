#!/usr/bin/env bash
# Aggregate local security checks (Phase 4). Non-zero if any check fails.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

FAILED=0
fail() {
	echo "FAIL: $*" >&2
	FAILED=1
}

echo "== Shell syntax (scripts/ + hooks) =="
while IFS= read -r -d '' f; do
	bash -n "$f" || fail "bash -n $f"
done < <(find scripts skills/code-to-docs-hooks/hooks -name '*.sh' -print0 2>/dev/null)

echo "== Python (redact helper) =="
python3 -m py_compile scripts/redact_public_text.py || fail "py_compile redact_public_text.py"

echo "== Redact smoke (synthetic token) =="
out=$(printf '%s' 'sk-12345678901234567890123456789012' | python3 scripts/redact_public_text.py)
case "${out}" in
*REDACTED*) ;;
*) fail "redact output missing REDACTED" ;;
esac

echo "== Policy docs on disk =="
test -f docs/security/outbound-allowlist.md || fail "missing outbound-allowlist.md"
test -f docs/security/sensitive-content-handling.md || fail "missing sensitive-content-handling.md"
test -f docs/security/artifact-retention.md || fail "missing artifact-retention.md"

echo "== Vault path rejection (setup.sh, unsafe quote) =="
if CODE_TO_DOCS_VAULT='foo"bar' bash skills/code-to-docs-hooks/hooks/setup.sh >/dev/null 2>&1; then
	fail "setup.sh must reject unsafe vault path"
fi

echo "== Done (exit ${FAILED}) =="
exit "${FAILED}"
