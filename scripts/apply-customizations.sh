#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SOURCE_BRANCH="${1:-main}"
MANIFEST="$ROOT/customizations/manifest.txt"

if [[ ! -f "$MANIFEST" ]]; then
  echo "Missing manifest: $MANIFEST" >&2
  exit 1
fi

if ! git rev-parse "$SOURCE_BRANCH" >/dev/null 2>&1; then
  echo "Source branch '$SOURCE_BRANCH' not found." >&2
  exit 1
fi

APPLIED=0
SKIPPED=0

while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%%#*}"
  path="$(echo "$line" | xargs)"
  [[ -z "$path" ]] && continue

  if git cat-file -e "$SOURCE_BRANCH:$path" 2>/dev/null; then
    mkdir -p "$(dirname "$path")"
    git show "$SOURCE_BRANCH:$path" > "$path"
    echo "Applied: $path"
    APPLIED=$((APPLIED + 1))
  else
    echo "Skipped (missing on $SOURCE_BRANCH): $path"
    SKIPPED=$((SKIPPED + 1))
  fi
done < "$MANIFEST"

echo
echo "Applied $APPLIED file(s), skipped $SKIPPED."
echo "Next: run ./scripts/list-customizations.sh --tier3 and merge RTL/performance edits manually."
