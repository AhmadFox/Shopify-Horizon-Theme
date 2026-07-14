#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

UPSTREAM_REMOTE="${HORIZON_UPSTREAM_REMOTE:-upstream}"
BASE_BRANCH="${1:-main}"
UPSTREAM_REF="${2:-$UPSTREAM_REMOTE/main}"
TIER3_ONLY=false

for arg in "$@"; do
  case "$arg" in
    --tier3) TIER3_ONLY=true ;;
  esac
done

if ! git rev-parse "$UPSTREAM_REF" >/dev/null 2>&1; then
  echo "Upstream ref '$UPSTREAM_REF' not found. Run ./scripts/horizon-upstream-fetch.sh first." >&2
  exit 1
fi

MANIFEST="$ROOT/customizations/manifest.txt"
MANIFEST_PATHS=()
while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%%#*}"
  line="$(echo "$line" | xargs)"
  [[ -z "$line" ]] && continue
  MANIFEST_PATHS+=("$line")
done < "$MANIFEST"

is_in_manifest() {
  local path="$1"
  local item
  for item in "${MANIFEST_PATHS[@]}"; do
    [[ "$item" == "$path" ]] && return 0
  done
  return 1
}

echo "Comparing $BASE_BRANCH vs $UPSTREAM_REF"
echo

NEW_FILES=()
MANIFEST_FILES=()
TIER3_FILES=()

while IFS= read -r path; do
  if git cat-file -e "$UPSTREAM_REF:$path" 2>/dev/null; then
    if is_in_manifest "$path"; then
      MANIFEST_FILES+=("$path")
    else
      TIER3_FILES+=("$path")
    fi
  else
    NEW_FILES+=("$path")
  fi
done < <(git diff --name-only "$UPSTREAM_REF" "$BASE_BRANCH" | grep -v '^\.cursor/' | sort)

print_list() {
  local title="$1"
  shift
  local -a items=("$@")
  echo "$title (${#items[@]})"
  if [[ ${#items[@]} -eq 0 ]]; then
    echo "  (none)"
  else
    printf '  %s\n' "${items[@]}"
  fi
  echo
}

if [[ "$TIER3_ONLY" == true ]]; then
  print_list "Tier 3 — manual merge" "${TIER3_FILES[@]}"
  exit 0
fi

print_list "New Dkhoun files" "${NEW_FILES[@]}"
print_list "Manifest files (auto-copy on upgrade)" "${MANIFEST_FILES[@]}"
print_list "Tier 3 — manual merge" "${TIER3_FILES[@]}"

TOTAL=$(git diff --name-only "$UPSTREAM_REF" "$BASE_BRANCH" | grep -v '^\.cursor/' | wc -l | xargs)
echo "Total changed paths (excluding .cursor): $TOTAL"
