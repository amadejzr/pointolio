#!/bin/bash
set -euo pipefail

# validate-changelog.sh
# Validates that CHANGELOG.md has an entry for the given version
# Usage: ./validate-changelog.sh <version>

VERSION="${1:-}"

if [ -z "$VERSION" ]; then
    echo "::error::Usage: $0 <version>"
    exit 1
fi

# Check if CHANGELOG.md exists
if [ ! -f "CHANGELOG.md" ]; then
    echo "::error::❌ CHANGELOG.md file not found"
    echo "::error::Please create a CHANGELOG.md with an entry for version $VERSION"
    exit 1
fi

echo "Looking for CHANGELOG entry for version: $VERSION"

# Escape dots for regex
VERSION_ESCAPED=$(echo "$VERSION" | sed 's/\./\\./g')

# Extract changelog content
CHANGELOG_RAW=$(awk -v ver="$VERSION_ESCAPED" '
    /^##[[:space:]]*\[?'"$VERSION_ESCAPED"'\]?/ { found=1; next }
    found && /^##[[:space:]]/ { exit }
    found { print }
' CHANGELOG.md)

CHANGELOG_CONTENT=$(echo "$CHANGELOG_RAW" | sed '/^[[:space:]]*$/d')

# Check if section exists
if [ -z "$CHANGELOG_RAW" ]; then
    echo "::error::❌ No CHANGELOG section found for version $VERSION"
    echo "::error::"
    echo "::error::Add to CHANGELOG.md:"
    echo "::error::  ## [$VERSION] - $(date +%Y-%m-%d)"
    echo "::error::  ### Added"
    echo "::error::  - Feature description"
    exit 1
fi

# Check if there's actual content
if [ -z "$CHANGELOG_CONTENT" ]; then
    echo "::error::❌ CHANGELOG section for version $VERSION is empty"
    echo "::error::Please add details about the changes"
    exit 1
fi

LINE_COUNT=$(echo "$CHANGELOG_CONTENT" | wc -l | tr -d '[:space:]')

if [ "$LINE_COUNT" -lt 1 ]; then
    echo "::error::❌ CHANGELOG has no meaningful content"
    exit 1
fi

echo "✅ Found CHANGELOG entry with $LINE_COUNT lines of content"
echo ""
echo "$CHANGELOG_CONTENT"
