#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION="${1:-}"
SOURCE_BRANCH="${2:-main}"
UPSTREAM_REMOTE="${HORIZON_UPSTREAM_REMOTE:-upstream}"

if [[ -z "$VERSION" ]]; then
  echo "Usage: ./scripts/upgrade-horizon.sh <version> [source-branch]" >&2
  echo "Example: ./scripts/upgrade-horizon.sh 4.2.0 main" >&2
  exit 1
fi

"$ROOT/scripts/horizon-upstream-fetch.sh" "$VERSION"

UPSTREAM_REF="$UPSTREAM_REMOTE/main"
if git rev-parse "$UPSTREAM_REMOTE/tags/v$VERSION" >/dev/null 2>&1; then
  UPSTREAM_REF="$UPSTREAM_REMOTE/tags/v$VERSION"
elif git rev-parse "$UPSTREAM_REMOTE/tags/$VERSION" >/dev/null 2>&1; then
  UPSTREAM_REF="$UPSTREAM_REMOTE/tags/$VERSION"
elif git rev-parse "horizon-upstream/$VERSION" >/dev/null 2>&1; then
  UPSTREAM_REF="horizon-upstream/$VERSION"
fi

UPGRADE_BRANCH="upgrade/horizon-$VERSION"

if git show-ref --verify --quiet "refs/heads/$UPGRADE_BRANCH"; then
  echo "Branch '$UPGRADE_BRANCH' already exists. Checkout and continue manually, or delete it first." >&2
  exit 1
fi

echo "Creating '$UPGRADE_BRANCH' from $UPSTREAM_REF"
git checkout -b "$UPGRADE_BRANCH" "$UPSTREAM_REF"

echo "Applying manifest customizations from '$SOURCE_BRANCH'..."
"$ROOT/scripts/apply-customizations.sh" "$SOURCE_BRANCH"

echo
echo "Upgrade branch ready: $UPGRADE_BRANCH"
echo "1. Review manifest changes: git status && git diff"
echo "2. Merge Tier 3 files: ./scripts/list-customizations.sh --tier3"
echo "3. Test locally: shopify theme dev"
echo "4. shopify theme check"
echo "5. Open PR into main when stable"
