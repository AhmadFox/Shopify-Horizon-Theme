#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

UPSTREAM_URL="${HORIZON_UPSTREAM_URL:-https://github.com/Shopify/horizon.git}"
UPSTREAM_REMOTE="${HORIZON_UPSTREAM_REMOTE:-upstream}"
VERSION="${1:-}"

if ! git remote get-url "$UPSTREAM_REMOTE" >/dev/null 2>&1; then
  echo "Adding remote '$UPSTREAM_REMOTE' -> $UPSTREAM_URL"
  git remote add "$UPSTREAM_REMOTE" "$UPSTREAM_URL"
fi

echo "Fetching $UPSTREAM_REMOTE..."
git fetch "$UPSTREAM_REMOTE" --tags

if [[ -n "$VERSION" ]]; then
  REF="$UPSTREAM_REMOTE/main"
  if git rev-parse "$UPSTREAM_REMOTE/tags/v$VERSION" >/dev/null 2>&1; then
    REF="$UPSTREAM_REMOTE/tags/v$VERSION"
  elif git rev-parse "$UPSTREAM_REMOTE/tags/$VERSION" >/dev/null 2>&1; then
    REF="$UPSTREAM_REMOTE/tags/$VERSION"
  fi

  BRANCH="horizon-upstream/$VERSION"
  echo "Updating tracking branch '$BRANCH' from $REF"
  git branch -f "$BRANCH" "$REF"
  echo "Done. Vanilla Horizon $VERSION is at branch: $BRANCH"
else
  echo "Done. Latest upstream main: $(git rev-parse --short "$UPSTREAM_REMOTE/main")"
  echo "Tip: run with a version to create horizon-upstream/<version>, e.g.:"
  echo "  ./scripts/horizon-upstream-fetch.sh 4.1.1"
fi
