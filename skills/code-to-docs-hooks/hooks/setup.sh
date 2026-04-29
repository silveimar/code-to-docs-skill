#!/usr/bin/env bash
# code-to-docs: Hook setup script
# Installs SessionStart and PostToolUse hooks into the project's .claude/settings.json
#
# Usage:
#   ./setup.sh [vault-path]
#
# vault-path defaults to ./docs-vault (same as code-to-docs --output default).
# Set CODE_TO_DOCS_VAULT env var for non-standard vault locations.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

DIGEST_HOOK="$SCRIPT_DIR/digest-on-start.sh"
UPDATE_HOOK="$SCRIPT_DIR/update-hint-on-commit.sh"
PROJECT_SETTINGS=".claude/settings.json"

VAULT_INPUT="${1:-${CODE_TO_DOCS_VAULT:-./docs-vault}}"

if [[ ! -f "$DIGEST_HOOK" ]]; then
    echo "Error: Cannot find $DIGEST_HOOK"
    echo "Run this script from the code-to-docs hooks directory or ensure the skill is installed."
    exit 1
fi

# Ensure hooks are executable
chmod +x "$DIGEST_HOOK" "$UPDATE_HOOK"

# Ensure .claude directory exists
mkdir -p .claude

# D-05: validate vault path before embedding (fail-closed)
# D-04/D-09: resolve absolute path; warn if outside repo root
VAULT_ABS="$(VAULT_INPUT="$VAULT_INPUT" REPO_ROOT="$REPO_ROOT" python3 <<'PY'
import os
import sys

repo = os.environ["REPO_ROOT"]
raw = os.environ["VAULT_INPUT"]
os.chdir(repo)
p = os.path.expanduser(raw)
if not os.path.isabs(p):
    p = os.path.abspath(p)
else:
    p = os.path.normpath(p)
print(p)
PY
)"

if ! VAULT_ABS="$VAULT_ABS" python3 <<'PY'
import os
import sys

p = os.environ["VAULT_ABS"]
if not p.strip():
    print("Error: vault path is empty.", file=sys.stderr)
    sys.exit(1)
forbidden = "\"'`$;&|()<>*?\n\r\t"
if any(ch in p for ch in forbidden):
    print("Error: vault path contains unsafe characters (quotes/metacharacters/control chars). Remediation: use a plain path like ./docs-vault.", file=sys.stderr)
    sys.exit(1)
PY
then
    exit 1
fi

case "$VAULT_ABS" in
"$REPO_ROOT"/*) ;;
*)
    echo "Warning: vault root is outside the repository ($REPO_ROOT). Hook commands will still use this path; ensure it is trusted." >&2
    ;;
esac

# Build the hooks JSON fragment with structured data + json.dump (D-05 / TH-001)
HOOKS_TMPFILE=$(mktemp)
trap 'rm -f "$HOOKS_TMPFILE"' EXIT

export HOOKS_TMPFILE VAULT_ABS DIGEST_HOOK UPDATE_HOOK REPO_ROOT PROJECT_SETTINGS

python3 <<'PY'
import json
import os
import shlex

vault = os.environ["VAULT_ABS"]
digest = os.environ["DIGEST_HOOK"]
update = os.environ["UPDATE_HOOK"]
cmd_digest = "CODE_TO_DOCS_VAULT=%s bash %s" % (shlex.quote(vault), shlex.quote(digest))
cmd_update = "CODE_TO_DOCS_VAULT=%s bash %s" % (shlex.quote(vault), shlex.quote(update))

fragment = {
    "hooks": {
        "SessionStart": [
            {
                "matcher": "startup",
                "hooks": [
                    {
                        "type": "command",
                        "command": cmd_digest,
                        "source": "code-to-docs",
                        "timeout": 10,
                    }
                ],
            }
        ],
        "PostToolUse": [
            {
                "matcher": "Bash",
                "hooks": [
                    {
                        "type": "command",
                        "command": cmd_update,
                        "source": "code-to-docs",
                        "timeout": 5,
                    }
                ],
            }
        ],
    }
}

out = os.environ["HOOKS_TMPFILE"]
with open(out, "w") as f:
    json.dump(fragment, f, indent=2)
PY

# Merge with existing settings or create new
if [[ -f "$PROJECT_SETTINGS" ]]; then
    python3 <<'PY'
import json
import os

proj = os.path.join(os.environ["REPO_ROOT"], os.environ["PROJECT_SETTINGS"])
hooks_path = os.environ["HOOKS_TMPFILE"]

existing = json.load(open(proj))
new_hooks = json.load(open(hooks_path))

if "hooks" not in existing:
    existing["hooks"] = {}

for event, handlers in new_hooks["hooks"].items():
    if event not in existing["hooks"]:
        existing["hooks"][event] = []
    existing_sources = set()
    for h in existing["hooks"][event]:
        for hook in h.get("hooks", []):
            if hook.get("source") == "code-to-docs":
                existing_sources.add(event)
    if event not in existing_sources:
        existing["hooks"][event].extend(handlers)

json.dump(existing, open(proj, "w"), indent=2)
print("Merged code-to-docs hooks into existing " + proj)
PY
else
    python3 <<'PY'
import json
import os

proj = os.path.join(os.environ["REPO_ROOT"], os.environ["PROJECT_SETTINGS"])
hooks_path = os.environ["HOOKS_TMPFILE"]
existing = json.load(open(hooks_path))
json.dump(existing, open(proj, "w"), indent=2)
print("Created " + proj + " with code-to-docs hooks")
PY
fi

vault_display="$(basename "$VAULT_ABS")"
echo ""
echo "Hooks installed:"
echo "  SessionStart → digest vault summary on session start"
echo "  PostToolUse  → update hint after git commits"
echo ""
echo "Vault path: $vault_display"
echo ""
echo "To remove hooks: run teardown.sh from this directory"
echo "To customize: edit $PROJECT_SETTINGS directly"
