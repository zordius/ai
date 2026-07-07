#!/usr/bin/env bash
# Validate [derives]: annotations in PRINCIPLES.md.
# Every slug referenced in a [derives]: line must appear as a [slug]: entry.
#
# Usage: bin/validate-derives.sh [PATH_TO_PRINCIPLES]
# Exit:  0 all OK  |  1 unresolved slugs found  |  2 no slug table yet
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILE="${1:-$SCRIPT_DIR/../PRINCIPLES.md}"

if [ ! -f "$FILE" ]; then
  echo "not found: $FILE" >&2; exit 2
fi

# Collect defined slugs from [slug]: lines  (|| DEFINED="" handles grep exit-1 on no matches)
DEFINED=$(grep '^\[slug\]:' "$FILE" | sed 's/\[slug\]: *//' | tr -d ' ') || DEFINED=""

if [ -z "$DEFINED" ]; then
  echo "no slug table in $FILE — run Phase 1 of the source-tree migration first" >&2
  DERIVES_COUNT=$(grep -c '^\[derives\]:' "$FILE") || DERIVES_COUNT=0
  echo "(found $DERIVES_COUNT [derives]: lines — slugs cannot be validated yet)"
  exit 2
fi

DEFINED_COUNT=$(echo "$DEFINED" | wc -l | tr -d ' ')

# Collect all unique slugs referenced across [derives]: lines
REFERENCED=$(grep '^\[derives\]:' "$FILE" | sed 's/\[derives\]: *//' | tr ',' '\n' | tr -d ' ' | grep -v '^$' | sort -u) || REFERENCED=""

if [ -z "$REFERENCED" ]; then
  echo "OK — no [derives]: annotations found (nothing to validate)"
  exit 0
fi

# Check each referenced slug against the defined set
ERRORS=0
while IFS= read -r slug; do
  [ -z "$slug" ] && continue
  if ! echo "$DEFINED" | grep -qx "$slug"; then
    echo "unresolved: $slug"
    ERRORS=$((ERRORS + 1))
  fi
done <<< "$REFERENCED"

REF_COUNT=$(echo "$REFERENCED" | wc -l | tr -d ' ')

if [ "$ERRORS" -eq 0 ]; then
  echo "OK — $REF_COUNT slug reference(s) validated against $DEFINED_COUNT defined slug(s)"
  exit 0
else
  echo "$ERRORS unresolved slug(s) — add to the [slug]: table or fix the typo" >&2
  exit 1
fi
