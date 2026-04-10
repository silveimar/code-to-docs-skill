#!/usr/bin/env bash
set -euo pipefail

# bump.sh — Bump version, create GitHub release, update plugin manifest and local install.
#
# Usage:
#   ./scripts/bump.sh patch    # 0.1.0 → 0.1.1
#   ./scripts/bump.sh minor    # 0.1.0 → 0.2.0
#   ./scripts/bump.sh major    # 0.1.0 → 1.0.0
#   ./scripts/bump.sh 0.3.0    # explicit version

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN_JSON="$REPO_ROOT/.claude-plugin/plugin.json"
SKILLS_ROOT="$REPO_ROOT/skills"
LOCAL_SKILLS_ROOT="$HOME/.claude/skills"
REPO="RCellar/code-to-docs-skill"

# --- Parse arguments ---

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <patch|minor|major|X.Y.Z>"
    exit 1
fi

BUMP_TYPE="$1"

# --- Read current version ---

CURRENT_VERSION=$(grep -o '"version": *"[^"]*"' "$PLUGIN_JSON" | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

echo "Current version: $CURRENT_VERSION"

# --- Compute new version ---

case "$BUMP_TYPE" in
    patch)
        NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))"
        ;;
    minor)
        NEW_VERSION="$MAJOR.$((MINOR + 1)).0"
        ;;
    major)
        NEW_VERSION="$((MAJOR + 1)).0.0"
        ;;
    [0-9]*)
        NEW_VERSION="$BUMP_TYPE"
        ;;
    *)
        echo "Error: Invalid bump type '$BUMP_TYPE'. Use patch, minor, major, or X.Y.Z"
        exit 1
        ;;
esac

echo "New version: $NEW_VERSION"

# --- Confirm ---

read -rp "Proceed? [y/N] " confirm
if [[ "$confirm" != [yY] ]]; then
    echo "Aborted."
    exit 0
fi

# --- Update plugin.json ---

sed -i "s/\"version\": *\"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/" "$PLUGIN_JSON"
echo "Updated $PLUGIN_JSON"

# --- Update local skill install ---

for dir in code-to-docs update digest hooks references; do
    mkdir -p "$LOCAL_SKILLS_ROOT/$dir"
    cp -r "$SKILLS_ROOT/$dir"/* "$LOCAL_SKILLS_ROOT/$dir/"
done
echo "Updated local skills at $LOCAL_SKILLS_ROOT/{code-to-docs,update,digest,hooks,references}"

# --- Commit if there are tracked changes, tag, push ---

cd "$REPO_ROOT"

git add "$PLUGIN_JSON"
if [[ -n "$(git diff --cached --name-only)" ]]; then
    git commit -m "chore: bump version to v$NEW_VERSION"
    echo "Committed version bump"
else
    echo "No tracked changes to commit (plugin.json may be gitignored — this is expected)"
fi

git tag "v$NEW_VERSION"
git push 2>/dev/null || true
git push origin "v$NEW_VERSION"

echo "Pushed tag v$NEW_VERSION"

# --- Generate release notes from commits since last tag ---

PREV_TAG=$(git tag --sort=-v:refname | grep -v "v$NEW_VERSION" | head -1)

if [[ -n "$PREV_TAG" ]]; then
    CHANGELOG=$(git log "$PREV_TAG"..HEAD --pretty=format:"- %s" --no-merges)
else
    CHANGELOG=$(git log --pretty=format:"- %s" --no-merges | head -20)
fi

if [[ -z "$CHANGELOG" ]]; then
    CHANGELOG="- Version bump (no code changes since last tag)"
fi

# --- Create GitHub release ---

gh release create "v$NEW_VERSION" \
    --repo "$REPO" \
    --title "v$NEW_VERSION" \
    --notes "$(cat <<EOF
## code-to-docs v$NEW_VERSION

### Changes since $PREV_TAG

$CHANGELOG

### Installation

\`\`\`
/plugin marketplace add $REPO
/plugin install code-to-docs@code-to-docs-skill
\`\`\`
EOF
)"

echo ""
echo "Done! Released v$NEW_VERSION"
echo "  GitHub: https://github.com/$REPO/releases/tag/v$NEW_VERSION"
echo "  Plugin: $PLUGIN_JSON → v$NEW_VERSION"
echo "  Local:  $LOCAL_SKILLS_ROOT/{code-to-docs,update,digest,hooks,references} → updated"
